//
//  XMPPPresence.swift
//  Pigeon
//
//  Created by Safarnejad on 1/22/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import Foundation
import XMPPFramework

// MARK: Protocol
public protocol XMPPPresenceDelegate {
    func xmppPresenceDidReceivePresence()
}

open class XMPPPresence: NSObject {
    var delegate: XMPPPresenceDelegate?
    
    // MARK: Singleton
    
    class var sharedInstance : XMPPPresence {
        struct XMPPPresenceSingleton {
            static let instance = XMPPPresence()
        }
        return XMPPPresenceSingleton.instance
    }
    
    // MARK: Functions
    
    class func goOnline() {
        let presence = XMPPPresence()
        let domain = XMPPChat.sharedInstance.xmppStream!.myJID!.domain
        
        if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
            let priority: DDXMLElement = DDXMLElement(name: "priority", stringValue: "24")
            presence.addChild(priority)
        }
        
        XMPPChat.sharedInstance.xmppStream?.send(presence)
    }
    
    class func goOffline() {
        var _ = XMPPPresence(type: "unavailable")
    }
}

extension XMPPPresence: XMPPStreamDelegate {
    
    public func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        print("did received presence : \(presence)")
    }
}

