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

class ConversationMapping {

    private var _conversationId : String!
    private var _conversationType : ConversationType!
    private var _isMuted : Bool!
    private var _isPinned : Bool!
    private var _lastSeenDate : String!
    private var _lastUpdate : String!
    private var _lastMessageId : String!
    private var _noMoreMessages : Bool!
    private var _unreadCount : Int!
    private var _hiddenConversation : Bool!
    private var _lastMessageState : LastMessageState!
    private var _draftMessage : String!
    private var _messages : [Message]!
    private var _contact : ContactMapping!
    
    var conversationId : String {
        get {
            return _conversationId
        }
        set(id) {
            _conversationId = id
        }
    }
    
    var conversationType : ConversationType {
        get {
            return _conversationType
        }
        set(conversationType) {
            _conversationType = conversationType
        }
    }
    
    var isMuted : Bool {
        get {
            return _isMuted
        }
        set(isMuted) {
            _isMuted = isMuted
        }
    }
    
    var isPinned : Bool {
        get {
            return _isPinned
        }
        set(isPinned) {
            _isPinned = isPinned
        }
    }
    
    var lastSeenDate : String {
        get {
            return _lastSeenDate
        }
        set(lastSeenDate) {
            _lastSeenDate = lastSeenDate
        }
    }
    
    var lastUpdate : String {
        get {
            return _lastUpdate
        }
        set(lastUpdate) {
            _lastUpdate = lastUpdate
        }
    }
    
    var lastMessageId : String {
        get {
            return _lastMessageId
        }
        set(lastMessageId) {
            _lastMessageId = lastMessageId
        }
    }
    
    var noMoreMessage : Bool {
        get {
            return _noMoreMessages
        }
        set(noMoreMessage) {
            _noMoreMessages = noMoreMessage
        }
    }
    
    var unreadCount : Int {
        get {
            return _unreadCount
        }
        set(id) {
            _unreadCount = unreadCount
        }
    }
    
    var hiddenConversation : Bool {
        get {
            return _hiddenConversation
        }
        set(hiddenConversation) {
            _hiddenConversation = hiddenConversation
        }
    }
    
    var lastMessageState : LastMessageState {
        get {
            return _lastMessageState
        }
        set(lastMessageState) {
            _lastMessageState = lastMessageState
        }
    }
    
    var draftMessage : String {
        get {
            return _draftMessage
        }
        set(draftMessage) {
            _draftMessage = draftMessage
        }
    }
    
    var messages : [Message] {
        get {
            return _messages
        }
        set(messages) {
            _messages = messages
        }
    }
    
    var contact : ContactMapping {
        get {
            return _contact
        }
        set(contact) {
            _contact = contact
        }
    }
    
    
    
    
    
    init(conversationId : String , conversationType : ConversationType , isMuted : Bool , isPinned : Bool , lastSeenDate : String , lastUpdate : String , lastMessageId : String , noMoreMessages : Bool , unreadCount : Int , hiddenConversation : Bool , lastMessageState : LastMessageState , draftMessage : String , messages : [Message] , contact : ContactMapping) {
        
        self._conversationId = conversationId
        self._conversationType = conversationType
        self._isMuted = isMuted
        self._isPinned = isPinned
        self._lastSeenDate = lastSeenDate
        self._lastUpdate = lastUpdate
        self._lastMessageId = lastMessageId
        self._noMoreMessages = noMoreMessages
        self._unreadCount = unreadCount
        self._hiddenConversation = hiddenConversation
        self._lastMessageState = lastMessageState
        self._draftMessage = draftMessage
        self._messages = messages
        self._contact = contact
    }


}
