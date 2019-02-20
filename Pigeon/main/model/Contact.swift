//
//  Contact.swift
//  Pigeon
//
//  Created by Safarnejad on 1/29/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import Foundation


class ContactMapping  {

    private var _contactName : String!
    private var _appName : String!
    private var _username : String!
    private var _status : String!
    private var _mobile : String!
    
    var contactName :String {
        get {
            return _contactName
        }
        set(contactName){
            _contactName = contactName
        }
    }
    
    var appName :String {
        get {
            return _appName
        }
        set(appName){
            _appName = appName
        }
    }
    
    
    var username :String {
        get {
            return _username
        }
        set(username){
            _username = username
        }
    }
    
    var mobile :String {
        get {
            return _mobile
        }
        set(mobile){
            _mobile = mobile
        }
    }
    
    
    var status :String {
        get {
            return _status
        }
        set(status){
            _status = status
        }
    }
    
    
    init(contactName :String ,appName :String ,username :String ,mobile :String ,status :String) {
        _contactName = contactName
        _appName = appName
        _username = username
        _mobile = mobile
        _status = status
    }
    
    init() {
        
    }
  
}
