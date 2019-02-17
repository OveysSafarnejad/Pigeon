//
//  OneChat.swift
//  OneChat
//
//  Created by Paul on 23/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework
import CoreData

public typealias XMPPStreamCompletionHandler = (_ shouldTrustPeer: Bool?) -> Void
public typealias OneChatAuthCompletionHandler = (_ stream: XMPPStream, _ error: DDXMLElement?) -> Void
public typealias OneChatConnectCompletionHandler = (_ stream: XMPPStream, _ error: DDXMLElement?) -> Void

public protocol OneChatDelegate {
    func oneStream(_ sender: XMPPStream?, socketDidConnect socket: GCDAsyncSocket?)
    func oneStreamDidConnect(_ sender: XMPPStream)
    func oneStreamDidAuthenticate(_ sender: XMPPStream)
    func oneStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement)
    func oneStreamDidDisconnect(_ sender: XMPPStream, withError error: NSError)
}

open class OneChat: NSObject {
    
    var delegate: OneChatDelegate?
    var window: UIWindow?
    
    open var xmppStream: XMPPStream?
    
    var xmppReconnect: XMPPReconnect?
    var xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppMuc : XMPPMUC?
    var xmppRoster: XMPPRoster?
    open var xmppLastActivity: XMPPLastActivity?
    var xmppvCardStorage: XMPPvCardCoreDataStorage?
    var xmppvCardTempModule: XMPPvCardTempModule?
    open var xmppvCardAvatarModule: XMPPvCardAvatarModule?
    var xmppCapabilitiesStorage: XMPPCapabilitiesCoreDataStorage?
    var xmppMessageDeliveryRecipts: XMPPMessageDeliveryReceipts?
    var xmppCapabilities: XMPPCapabilities?
    var user : XMPPUserCoreDataStorageObject?
    var chats: OneChats?
    let presenceTest = OnePresence()
    let messageTest = OneMessage()
    let rosterTest = OneRoster()
    let lastActivityTest = OneLastActivity()
    
    var customCertEvaluation: Bool?
    var isXmppConnected: Bool?
    var password: String?
    
    var streamDidAuthenticateCompletionBlock: OneChatAuthCompletionHandler?
    var streamDidConnectCompletionBlock: OneChatConnectCompletionHandler?
    
    // MARK: Singleton
    open class var sharedInstance : OneChat {
        struct OneChatSingleton {
            static let instance = OneChat()
        }
        return OneChatSingleton.instance
    }
    
    // MARK: Functions
    open class func stop() {
        sharedInstance.teardownStream()
    }
    
    open class func start(_ archiving: Bool? = false, delegate: OneChatDelegate? = nil, completionHandler completion:@escaping OneChatAuthCompletionHandler) {
        
        
        sharedInstance.setupStream()
        if archiving! {
            OneMessage.sharedInstance.setupArchiving()
        }
        if let delegate: OneChatDelegate = delegate {
            sharedInstance.delegate = delegate
        }
        OneRoster.sharedInstance.fetchedResultsController()?.delegate = OneRoster.sharedInstance
        sharedInstance.streamDidAuthenticateCompletionBlock = completion
    }
    
    open func setupStream() {
        
        xmppStream = XMPPStream()
        
        #if !TARGET_IPHONE_SIMULATOR
        xmppStream!.enableBackgroundingOnSocket = true
        #endif

        
        xmppReconnect = XMPPReconnect()
        
        
        //xmppRosterStorage = XMPPRosterCoreDataStorage()
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        xmppMuc = XMPPMUC()
        xmppRoster!.autoFetchRoster = true;
        xmppRoster!.autoAcceptKnownPresenceSubscriptionRequests = true;
        xmppvCardStorage = XMPPvCardCoreDataStorage.sharedInstance()
        xmppvCardTempModule = XMPPvCardTempModule(vCardStorage: xmppvCardStorage!)
        xmppvCardAvatarModule = XMPPvCardAvatarModule(vCardTempModule: xmppvCardTempModule!)
        
        xmppCapabilitiesStorage = XMPPCapabilitiesCoreDataStorage.sharedInstance()
        xmppCapabilities = XMPPCapabilities(capabilitiesStorage: xmppCapabilitiesStorage!)
        
        xmppCapabilities!.autoFetchHashedCapabilities = true;
        xmppCapabilities!.autoFetchNonHashedCapabilities = false;
        
        xmppMessageDeliveryRecipts = XMPPMessageDeliveryReceipts(dispatchQueue: DispatchQueue.main)
        xmppMessageDeliveryRecipts!.autoSendMessageDeliveryReceipts = true
        xmppMessageDeliveryRecipts!.autoSendMessageDeliveryRequests = true
        
        xmppLastActivity = XMPPLastActivity()
        
        // Activate xmpp modules
        xmppReconnect!.activate(xmppStream!)
        xmppRoster!.activate(xmppStream!)
        xmppvCardTempModule!.activate(xmppStream!)
        xmppvCardAvatarModule!.activate(xmppStream!)
        xmppCapabilities!.activate(xmppStream!)
        xmppMessageDeliveryRecipts!.activate(xmppStream!)
        xmppLastActivity!.activate(xmppStream!)
        xmppMuc!.activate(xmppStream!)
        
        // Add ourself as a delegate to anything we may be interested in
        xmppStream!.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoster!.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        xmppStream!.addDelegate(messageTest, delegateQueue: DispatchQueue.main)
        xmppRoster!.addDelegate(messageTest, delegateQueue: DispatchQueue.main)
        
        xmppStream!.addDelegate(rosterTest, delegateQueue: DispatchQueue.main)
        xmppRoster!.addDelegate(rosterTest, delegateQueue: DispatchQueue.main)
        
        xmppStream!.addDelegate(presenceTest, delegateQueue: DispatchQueue.main)
        xmppRoster!.addDelegate(presenceTest, delegateQueue: DispatchQueue.main)
        
        xmppLastActivity!.addDelegate(lastActivityTest, delegateQueue: DispatchQueue.main)
        xmppStream?.hostName = Constants.ServerInfo.SERVER_HOST
        xmppStream?.hostPort = Constants.ServerInfo.SERVER_PORT
        
        xmppMuc?.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        customCertEvaluation = true
    }
    
    fileprivate func teardownStream() {
        
        xmppStream!.removeDelegate(self)
        xmppRoster!.removeDelegate(self)
        xmppLastActivity!.removeDelegate(lastActivityTest)
        
        xmppLastActivity!.deactivate()
        xmppReconnect!.deactivate()
        xmppRoster!.deactivate()
        xmppvCardTempModule!.deactivate()
        xmppvCardAvatarModule!.deactivate()
        xmppCapabilities!.deactivate()
        OneMessage.sharedInstance.xmppMessageArchiving!.deactivate()
        xmppStream!.disconnect()
        
        OneMessage.sharedInstance.xmppMessageStorage = nil;
        xmppStream = nil;
        xmppReconnect = nil;
        xmppRoster = nil;
        //xmppRosterStorage = nil;
        xmppvCardStorage = nil;
        xmppvCardTempModule = nil;
        xmppvCardAvatarModule = nil;
        xmppCapabilities = nil;
        xmppCapabilitiesStorage = nil;
        xmppLastActivity = nil;
    }
    
    // MARK: Connect / Disconnect
    open func connect(username: String, password: String, completionHandler completion:@escaping OneChatConnectCompletionHandler) {
        
        self.password = password
        xmppStream?.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        xmppStream?.myJID = XMPPJID(string: username)
        
        if isConnected() {
            streamDidConnectCompletionBlock = completion
            self.streamDidConnectCompletionBlock!(self.xmppStream!, nil)
            return
        }
        
        try! xmppStream!.connect(withTimeout: XMPPStreamTimeoutNone)
        streamDidConnectCompletionBlock = completion
    }
    
    
    open func isConnected() -> Bool {
        return xmppStream!.isConnected
    }
    
    open func disconnect() {
        OnePresence.goOffline()
        xmppStream?.disconnect()
    }
    
    // Mark: Private function
    
    fileprivate func setValue(_ value: String, forKey key: String) {
        if value.count > 0 {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    // Mark: UITableViewCell helpers
    
    open func configurePhotoForCell(_ cell: UITableViewCell, user: XMPPUserCoreDataStorageObject) {
        // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
        // We only need to ask the avatar module for a photo, if the roster doesn't have it.
        if user.photo != nil {
            cell.imageView!.image = user.photo!;
        } else {
            let photoData = xmppvCardAvatarModule?.photoData(for: user.jid)
            
            if let photoData = photoData {
                cell.imageView!.image = UIImage(data: photoData)
            } else {
                cell.imageView!.image = UIImage(named: "defaultPerson")
            }
        }
    }
}

// MARK: XMPPStream Delegate

extension OneChat: XMPPStreamDelegate {
    
    public func xmppStream(_ sender: XMPPStream, socketDidConnect socket: GCDAsyncSocket) {
        delegate?.oneStream(sender, socketDidConnect: socket)
    }
    
    public func xmppStream(_ sender: XMPPStream, willSecureWithSettings settings: NSMutableDictionary) {
        let expectedCertName: String? = xmppStream?.myJID!.domain
        
        if expectedCertName != nil {
            settings[kCFStreamSSLPeerName as String] = expectedCertName
        }
        if customCertEvaluation! {
            settings[GCDAsyncSocketManuallyEvaluateTrust] = true
        }
    }

    public func xmppStream(_ sender: XMPPStream, didReceiveTrust trust: SecTrust, completionHandler:
        @escaping XMPPStreamCompletionHandler) {
        let bgQueue = DispatchQueue.global(qos: .default)
        
        bgQueue.async(execute: { () -> Void in
            var result: SecTrustResultType = .deny
            let status = SecTrustEvaluate(trust, &result)
            
            if status == noErr {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        })
    }
    
    public func xmppStreamDidSecure(_ sender: XMPPStream) {
        //did secure
    }

    public func xmppStreamDidConnect(_ sender: XMPPStream) {
        isXmppConnected = true
        
        do {
            try xmppStream!.authenticate(withPassword: password!)
        } catch _ {
            //Handle error
        }
    }

    public func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        streamDidAuthenticateCompletionBlock!(sender, nil)
        streamDidConnectCompletionBlock!(sender, nil)
        OnePresence.goOnline()
    }
    
    public func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        streamDidAuthenticateCompletionBlock!(sender, error)
        streamDidConnectCompletionBlock!(sender, error)
    }
    
    public func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        delegate?.oneStreamDidDisconnect(sender, withError: error! as NSError)
    }
    
    
    public func xmppStreamDidRegister(_ sender: XMPPStream) {
        
    }
    
    public func xmppStream(_ sender: XMPPStream, didNotRegister error: DDXMLElement) {
        
    }
}
