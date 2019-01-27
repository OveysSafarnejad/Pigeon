//
//  Message.swift
//  Pigeon
//
//  Created by Safarnejad on 1/22/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import XMPPFramework

public typealias XMPPChatMessageCompletionHandler = (_ stream: XMPPStream, _ message: XMPPMessage) -> Void

// MARK: Protocols

public protocol XMPPMessageDelegate : NSObjectProtocol {
    func oneStream(_ sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject)
    func oneStream(_ sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject)
}

open class XMPPMessage: NSObject {
    open weak var delegate: XMPPMessageDelegate?
    
    open var xmppMessageStorage: XMPPMessageArchivingCoreDataStorage?
    var xmppMessageArchiving: XMPPMessageArchiving?
    var didSendMessageCompletionBlock: XMPPChatMessageCompletionHandler?
    
    // MARK: Singleton
    
    open class var sharedInstance : XMPPMessage {
        struct XMPPMessageSingleton {
            static let instance = XMPPMessage()
        }
        
        return XMPPMessageSingleton.instance
    }
    
    // MARK: private methods
    
    func setupArchiving() {
        xmppMessageStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        xmppMessageArchiving = XMPPMessageArchiving(messageArchivingStorage: xmppMessageStorage)
        
        xmppMessageArchiving?.clientSideMessageArchivingOnly = true
        xmppMessageArchiving?.activate(XMPPChat.sharedInstance.xmppStream!)
        xmppMessageArchiving?.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    // MARK: public methods
    
    open class func sendMessage(_ message: String, thread:String, to receiver: String, completionHandler completion:@escaping XMPPChatMessageCompletionHandler) {
        let body = DDXMLElement.element(withName: "body") as! DDXMLElement
        let messageID = XMPPChat.sharedInstance.xmppStream?.generateUUID
        
        body.stringValue = message
        
        let threadElement = DDXMLElement.element(withName: "thread") as! DDXMLElement
        threadElement.stringValue = thread
        
        let completeMessage = DDXMLElement.element(withName: "message") as! DDXMLElement
        
        completeMessage.addAttribute(withName: "id", stringValue: messageID!)
        completeMessage.addAttribute(withName: "type", stringValue: "chat")
        completeMessage.addAttribute(withName: "to", stringValue: receiver)
        completeMessage.addChild(body)
        completeMessage.addChild(threadElement)
        
        sharedInstance.didSendMessageCompletionBlock = completion
        XMPPChat.sharedInstance.xmppStream?.send(completeMessage)
    }
    
    open class func sendIsComposingMessage(_ recipient: String, thread: String,completionHandler completion:@escaping XMPPChatMessageCompletionHandler) {
        if recipient.characters.count > 0 {
            let message = DDXMLElement.element(withName: "message") as! DDXMLElement
            message.addAttribute(withName: "type", stringValue: "chat")
            message.addAttribute(withName: "to", stringValue: recipient)
            
            let composing = DDXMLElement.element(withName: "composing", stringValue: "http://jabber.org/protocol/chatstates") as! DDXMLElement
            composing.namespaces = [DDXMLElement.namespace(withName: "" , stringValue: "http://jabber.org/protocol/chatstates") as! DDXMLNode];
            message.addChild(composing)
            
            let threadElement = DDXMLElement.element(withName: "thread") as! DDXMLElement
            threadElement.stringValue = thread
            message.addChild(threadElement)
            
            print(message)
            
            sharedInstance.didSendMessageCompletionBlock = completion
            XMPPChat.sharedInstance.xmppStream?.send(message)
        }
    }
    
    open func loadArchivedMessagesFrom(jid: String, thread: String) -> NSMutableArray {
        let moc = xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        let predicateFormat = "bareJidStr like %@ ANd thread like %@"
        let predicate = NSPredicate(format: predicateFormat, jid, thread)
        let retrievedMessages = NSMutableArray()
        var sortedRetrievedMessages = Array<Any>()
        
        request.predicate = predicate
        request.entity = entityDescription
        
        do {
            let results = try moc?.fetch(request)
            
            for message in results! {
                var element: DDXMLElement!
                do {
                    element = try DDXMLElement(xmlString: (message as AnyObject).messageStr)
                } catch _ {
                    element = nil
                }
                
                let body: String
                let sender: String
                let date: Date
                
                date = (message as AnyObject).timestamp
                
                if (message as! XMPPMessageArchiving_Message_CoreDataObject).body != nil {
                    body = (message as AnyObject).body
                } else {
                    body = ""
                }
                
                if element.attributeStringValue(forName: "to") == jid {
                    let displayName = XMPPChat.sharedInstance.xmppStream?.myJID
                    sender = displayName!.bare
                } else {
                    sender = jid
                }
                
                let fullMessage = JSQMessage(senderId: sender, senderDisplayName: sender, date: date, text: body)!
                retrievedMessages.add(fullMessage)
                
                
                let descriptor:NSSortDescriptor = NSSortDescriptor(key: "date", ascending: true);
                
                sortedRetrievedMessages = retrievedMessages.sortedArray(using: [descriptor]);
                
            }
        } catch _ {
            //catch fetch error here
        }
        return NSMutableArray(array: sortedRetrievedMessages)
    }
    
    open func deleteMessagesFrom(jid: String, messages: NSArray) {
        messages.enumerateObjects({ (message, idx, stop) -> Void in
            let moc = self.xmppMessageStorage?.mainThreadManagedObjectContext
            let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
            let request = NSFetchRequest<NSFetchRequestResult>()
            let predicateFormat = "messageStr like %@ "
            let predicate = NSPredicate(format: predicateFormat, message as! String)
            
            request.predicate = predicate
            request.entity = entityDescription
            
            do {
                let results = try moc?.fetch(request)
                
                for messageAny in results! {
                    
                    let message = messageAny as AnyObject
                    
                    var element: DDXMLElement!
                    do {
                        element = try DDXMLElement(xmlString: message.messageStr)
                    } catch _ {
                        element = nil
                    }
                    
                    if element.attributeStringValue(forName: "messageStr") == message as! String {
                        moc?.delete(message as! NSManagedObject)
                    }
                }
            } catch _ {
                //catch fetch error here
            }
        })
    }
}

extension XMPPMessage: XMPPStreamDelegate {
    
    public func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        if let completion = XMPPMessage.sharedInstance.didSendMessageCompletionBlock {
            completion(sender, message)
        }
        //XMPPMessage.sharedInstance.didSendMessageCompletionBlock!(sender, message)
    }
    
    public func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        
        var user = XMPPChat.sharedInstance.xmppRosterStorage.user(for: message.from, xmppStream: XMPPChat.sharedInstance.xmppStream, managedObjectContext: XMPPRoster.sharedInstance.managedObjectContext_roster())
        
        if !XMPPChats.knownUserForJid(jidStr:(user?.jidStr)!) {
            XMPPChats.addUserToChatList(jidStr: (user?.jidStr)!)
        }
        
        if message.isChatMessageWithBody {
            XMPPMessage.sharedInstance.delegate?.oneStream(sender, didReceiveMessage: message, from: user!)
        } else {
            
            print(message)
            //was composing
            if let _ = message.forName("composing") {
                XMPPMessage.sharedInstance.delegate?.oneStream(sender, userIsComposing: user!)
            }
        }
        
        
    }
}

