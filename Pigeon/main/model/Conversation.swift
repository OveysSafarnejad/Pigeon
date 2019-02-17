//
//  Conversation.swift
//  Pigeon
//
//  Created by Safarnejad on 1/26/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import Foundation
import UIKit

enum ConversationType : String {
    
    case chat = "personal"
    case group = "group"
    case channel = "channel"
}

enum LastMessageState : String {
    case sent
    case sending
    case seen
    case not_send
    case not_seen
}

class ConversationMapping  {
    
    var conversationId : String!
    var conversationType : ConversationType!
    var isMuted : Bool!
    var isPinned : Bool!
    var lastSeenDate : String!
    var lastUpdate : String!
    var lastMessageId : String!
    var noMoreMessages : Bool!
    var unreadCount : Int!
    var hiddenConversation : Bool!
    var lastMessageState : LastMessageState!
    var draftMessage : String!
    var messages : [Message]!
    var contact : Contact!
    
    
    
    
    
    init(conversationId : String , conversationType : ConversationType , isMuted : Bool , isPinned : Bool , lastSeenDate : String , lastUpdate : String , lastMessageId : String , noMoreMessages : Bool , unreadCount : Int , hiddenConversation : Bool , lastMessageState : LastMessageState , draftMessage : String , messages : [Message] , contact : Contact) {
        
        self.conversationId = conversationId
        self.conversationType = conversationType
        self.isMuted = isMuted
        self.isPinned = isPinned
        self.lastSeenDate = lastSeenDate
        self.lastUpdate = lastUpdate
        self.lastMessageId = lastMessageId
        self.noMoreMessages = noMoreMessages
        self.unreadCount = unreadCount
        self.hiddenConversation = hiddenConversation
        self.lastMessageState = lastMessageState
        self.draftMessage = draftMessage
        self.messages = messages
        self.contact = contact
    }

}
