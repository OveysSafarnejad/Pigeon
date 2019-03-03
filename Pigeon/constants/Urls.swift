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
        static let BASE = "http://46.100.54.218:8084"
    }
    
    struct URI {
        static let PHONE_VALIDATION = "/checkNumber"
        static let OTP_VALIDATION = "/verify"
        static let IMAGE_PATH = "/img"
        static let INFORMATION = "/info"
        static let CONTACT = "/contacts"
    }
}
