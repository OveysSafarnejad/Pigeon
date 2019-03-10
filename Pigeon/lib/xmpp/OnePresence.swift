//
//  OnePresence.swift
//  OneChat
//
//  Created by Paul on 27/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

// MARK: Protocol
public protocol OnePresenceDelegate {
    func onePresenceDidReceivePresence()
}

open class OnePresence: NSObject {
    var delegate: OnePresenceDelegate?
    
    
    
    // MARK: Singleton
    class var sharedInstance : OnePresence {
        struct OnePresenceSingleton {
            static let instance = OnePresence()
        }
        return OnePresenceSingleton.instance
    }
    
    // MARK: Functions
    
    class func goOnline() {
        
        let presence = XMPPPresence(type: "available")
        OneChat.sharedInstance.xmppStream?.send(presence)
    }
    
    class func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        OneChat.sharedInstance.xmppStream?.send(presence)
    }
}

extension OnePresence: XMPPStreamDelegate {
    
    public func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        print("did receive presence")
        print(presence)
        print("\n\n")
    }
    
    public func xmppStream(_ sender: XMPPStream, didSend presence: XMPPPresence) {
        print("did send presence")
        print(presence)
        print("\n\n")
    }
    
    public func xmppStream(_ sender: XMPPStream, didSend iq: XMPPIQ) {
        print("did send iq")
        print(iq)
        print("\n\n")
    }
    
    public func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        print("did receive iq")
        print(iq)
        print("\n\n")
        return true
    }
}
