//
//  XMPPRoster.swift
//  Pigeon
//
//  Created by Safarnejad on 1/22/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import Foundation
import XMPPFramework

public protocol XMPPRosterDelegate {
    func XMPPRosterContentChanged(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
}

open class XMPPRoster: NSObject, NSFetchedResultsControllerDelegate {
    open var delegate: XMPPRosterDelegate?
    open var fetchedResultsControllerVar: NSFetchedResultsController<NSFetchRequestResult>?
    
    // MARK: Singletonsen
    
    open class var sharedInstance : XMPPRoster {
        struct XMPPRosterSingleton {
            static let instance = XMPPRoster()
        }
        return XMPPRosterSingleton.instance
    }
    
    open class var buddyList: NSFetchedResultsController<NSFetchRequestResult> {
        get {
            if sharedInstance.fetchedResultsControllerVar != nil {
                return sharedInstance.fetchedResultsControllerVar!
            }
            return sharedInstance.fetchedResultsController()!
        }
    }
    
    // MARK: Core Data
    
    func managedObjectContext_roster() -> NSManagedObjectContext {
        return XMPPChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext
    }
    
    fileprivate func managedObjectContext_capabilities() -> NSManagedObjectContext {
        return XMPPChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext
    }
    
    open func fetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        if fetchedResultsControllerVar == nil {
            let moc = XMPPRoster.sharedInstance.managedObjectContext_roster() as NSManagedObjectContext?
            let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
            let sd1 = NSSortDescriptor(key: "sectionNum", ascending: true)
            let sd2 = NSSortDescriptor(key: "displayName", ascending: true)
            
            let sortDescriptors = [sd1, sd2]
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            fetchRequest.entity = entity
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.fetchBatchSize = 10
            
            fetchedResultsControllerVar = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: "sectionNum", cacheName: nil)
            fetchedResultsControllerVar?.delegate = self
            
            do {
                try fetchedResultsControllerVar!.performFetch()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
            //  if fetchedResultsControllerVar?.performFetch() == nil {
            //Handle fetch error
            //}
        }
        
        return fetchedResultsControllerVar!
    }
    
    open class func userFromRosterAtIndexPath(indexPath: IndexPath) -> XMPPUserCoreDataStorageObject {
        return sharedInstance.fetchedResultsController()!.object(at: indexPath) as! XMPPUserCoreDataStorageObject
    }
    
    open class func userFromRosterForJID(jid: String) -> XMPPUserCoreDataStorageObject? {
        let userJID = XMPPJID(string: jid)
        
        if let user = XMPPChat.sharedInstance.xmppRosterStorage.user(for: userJID, xmppStream: XMPPChat.sharedInstance.xmppStream, managedObjectContext: sharedInstance.managedObjectContext_roster()) {
            return user
        } else {
            return nil
        }
    }
    
    open class func removeUserFromRosterAtIndexPath(indexPath: IndexPath) {
        let user = userFromRosterAtIndexPath(indexPath: indexPath)
        sharedInstance.fetchedResultsControllerVar?.managedObjectContext.delete(user)
        
        sharedInstance.fetchedResultsControllerVar = nil;
        sharedInstance.fetchedResultsController()
    }
    
    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.XMPPRosterContentChanged(controller)
    }
}

extension XMPPRoster: XMPPRosterDelegate {
    
    public func xmppRoster(_ sender: XMPPRoster, didReceiveBuddyRequest presence:XMPPPresence) {
        //was let user
        _ = XMPPChat.sharedInstance.xmppRosterStorage.user(for: presence.from, xmppStream: XMPPChat.sharedInstance.xmppStream, managedObjectContext: managedObjectContext_roster())
    }
    
    public func xmppRosterDidEndPopulating(_ sender: XMPPRoster?) {
        let jidList = XMPPChat.sharedInstance.xmppRosterStorage.jids(for: XMPPChat.sharedInstance.xmppStream!)
        print("List=\(jidList)")
        
    }
    
    public func sendBuddyRequestTo(_ username: String) {
        let presence: DDXMLElement = DDXMLElement.element(withName: "presence") as! DDXMLElement
        presence.addAttribute(withName: "type", stringValue: "subscribe")
        presence.addAttribute(withName: "to", stringValue: username)
        presence.addAttribute(withName: "from", stringValue: (XMPPChat.sharedInstance.xmppStream?.myJID!.bare)!)
        
        XMPPChat.sharedInstance.xmppStream?.send(presence)
    }
    
    public func acceptBuddyRequestFrom(_ username: String) {
        let presence: DDXMLElement = DDXMLElement.element(withName: "presence") as! DDXMLElement
        presence.addAttribute(withName: "to", stringValue: username)
        presence.addAttribute(withName: "from", stringValue: (XMPPChat.sharedInstance.xmppStream?.myJID!.bare)!)
        presence.addAttribute(withName: "type", stringValue: "subscribed")
        
        XMPPChat.sharedInstance.xmppStream?.send(presence)
    }
    
    public func declineBuddyRequestFrom(_ username: String) {
        let presence: DDXMLElement = DDXMLElement.element(withName: "presence") as! DDXMLElement
        presence.addAttribute(withName: "to", stringValue: username)
        presence.addAttribute(withName: "from", stringValue: (XMPPChat.sharedInstance.xmppStream?.myJID!.bare)!)
        presence.addAttribute(withName: "type", stringValue: "unsubscribed")
        
        XMPPChat.sharedInstance.xmppStream?.send(presence)
    }
}

extension XMPPRoster: XMPPStreamDelegate {
    
    public func xmppStream(_ sender: XMPPStream, didReceive ip: XMPPIQ) -> Bool {
        if let msg = ip.attribute(forName: "from") {
            if msg.stringValue == "conference.process-one.net"  {
                
            }
        }
        return false
    }
}

