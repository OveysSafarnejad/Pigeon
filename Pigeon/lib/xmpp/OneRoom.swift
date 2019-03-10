//
//  OneMUC.swift
//  OneChat
//
//  Created by Paul on 03/03/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

typealias OneRoomCreationCompletionHandler = (_ sender: XMPPRoom) -> Void

protocol OneRoomDelegate {
    //func onePresenceDidReceivePresence()
}

class OneRoom: NSObject {
    
    var delegate: OneRoomDelegate?

    var didCreateRoomCompletionBlock: OneRoomCreationCompletionHandler?
    
    // MARK: Singleton
    class var sharedInstance : OneRoom {
        struct OneRoomSingleton {
            static let instance = OneRoom()
        }
        return OneRoomSingleton.instance
    }
    
    class func createRoom(_ roomName: String, delegate: AnyObject? = nil, completionHandler completion:@escaping OneRoomCreationCompletionHandler) {
        
        
        sharedInstance.didCreateRoomCompletionBlock = completion
        let domain =  OneChat.sharedInstance.xmppStream!.myJID!.domain
        let roomJID = XMPPJID(string: "\(roomName)@muclight.\(domain)")
        let xmppRoom = XMPPRoomLight(roomLightStorage: nil, jid: roomJID!, roomname: roomName, dispatchQueue: DispatchQueue.main)
        xmppRoom.activate(OneChat.sharedInstance.xmppStream!)
        xmppRoom.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoom.createRoomLight(withMembersJID: [XMPPJID(string: "ijpxs3blss@localhost")!])
        
        
        
        //        let id = OneChat.sharedInstance.xmppStream?.generateUUID
        //        let iq = DDXMLElement(name: "iq")
        //        iq.addAttribute(withName: "id", stringValue: id!)
        //        iq.addAttribute(withName: "to", stringValue: "\(roomName)@muclight.\(domain)")
        //        iq.addAttribute(withName: "type", stringValue: "set")
        //        let query = DDXMLElement(name: "query")
        //        let configuraton = DDXMLElement(name: "configuration")
        //        configuraton.addChild(DDXMLElement(name: "roomname", stringValue: "testBYoveys"))
        //        let occupants = DDXMLElement(name: "occupants")
        //        let users = DDXMLElement(name: "user", stringValue: (XMPPJID(string: "ijpxs3blss@localhost")?.bare)!)
        //        users.addAttribute(withName: "affiliation", stringValue: "member")
        //        occupants.addChild(users)
        //        query.addChild(configuraton)
        //        query.addChild(occupants)
        //        xmppRoom.setConfiguration([configuraton])
        
        //        iq.addChild(query)
        //        OneChat.sharedInstance.xmppStream?.send(iq)
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
        //            //
        //            //           xmppRoom.configureRoom(usingOptions: nil)
        //            //           xmppRoom.fetchConfigurationForm()
        //            //           xmppRoom.fetchBanList()
        //            //           xmppRoom.fetchMembersList()
        //            //           xmppRoom.fetchModeratorsList()
        //            //
        //            xmppRoom.getConfiguration()
        //        }

    }

    
}


extension OneRoom: XMPPRoomLightDelegate {
    
    public func xmppRoomLight(_ sender: XMPPRoomLight, didCreateRoomLight iq: XMPPIQ) {
        print("didCreateRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didFailToCreateRoomLight iq: XMPPIQ) {
        print("didFailToCreateRoomLight")
    }
    
    public func xmppRoomLight(_ sender: XMPPRoomLight, didFailToSetConfiguration iq: XMPPIQ) {
        print("didFailToSetConfigurationRoomLight")
    }
    
    public func xmppRoomLight(_ sender: XMPPRoomLight, didSetConfiguration iqResult: XMPPIQ) {
        print("didSetConfigurationRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didAddUsers iqResult: XMPPIQ) {
        print("didAddUsersRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didFailToAddUsers iq: XMPPIQ) {
        print("didFailToAddUsersRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didLeaveRoomLight iq: XMPPIQ) {
        print("didLeaveRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didReceive message: XMPPMessage) {
        print("didReceiveMessageRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didFailToLeaveRoomLight iq: XMPPIQ) {
        print("didFailToLeaveRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, roomDestroyed message: XMPPMessage) {
         print("roomDestroyedRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didDestroyRoomLight iqResult: XMPPIQ) {
         print("didDestroyRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didFailToDestroyRoomLight iq: XMPPIQ) {
        print("didFailToDestroyRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didFetchMembersList iqResult: XMPPIQ) {
        print("didFetchMembersListRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didFailToFetchMembersList iq: XMPPIQ) {
        print("didFailToFetchMembersListRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didFailToGetConfiguration iq: XMPPIQ) {
        print("didFailToGetConfigurationRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didGetConfiguration iqResult: XMPPIQ) {
        print("didGetConfigurationRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, configurationChanged message: XMPPMessage) {
        print("configurationChangedRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didChangeAffiliations iqResult: XMPPIQ) {
        print("didChangeAffiliationsRoomLight")
    }
    
    func xmppRoomLight(_ sender: XMPPRoomLight, didFailToChangeAffiliations iq: XMPPIQ) {
        print("didFailToChangeAffiliationsRoomLight")
    }
   
}

