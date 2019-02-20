//
//  Urls.swift
//  Pigeon
//
//  Created by Safarnejad on 1/21/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import Foundation

struct Urls {
    
    struct BaseURL {
        static let BASE = "http://192.168.100.7:2525"
    }
    
    struct URI {
        static let PHONE_VALIDATION = "/checkNumber"
        static let OTP_VALIDATION = "/verify"
        static let IMAGE_PATH = "/img"
        static let INFORMATION = "/info"
        static let CONTACT = "/contacts"
    }
}
