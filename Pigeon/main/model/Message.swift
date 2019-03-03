//
//  Message.swift
//  Pigeon
//
//  Created by Safarnejad on 1/29/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import Foundation

class MessageMapping  {
    
    private var _pmDateAndTime : String!
    private var _body : String!
    
    
    var pmDateAndTime : String {
        get {
            return _pmDateAndTime
        }
        set(pmDateAndTime) {
            _pmDateAndTime = pmDateAndTime
        }
    }
    
    var body : String {
        get {
            return _body
        }
        set(body) {
            _body = body
        }
    }
    
    init(pmDatAndTime : String , body : String) {
        self._pmDateAndTime = pmDatAndTime
        self._body = body
    } 
}
