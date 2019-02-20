//
//  Cryptogra.swift
//  Pigeon
//
//  Created by Safarnejad on 1/25/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import Foundation
import SwiftyRSA
import SwCrypt

class Cryptography {
    
    func generateRSAKeys() {
        
        let keyPair = try! SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
        let privateKey = keyPair.privateKey
        let publicKey = keyPair.publicKey
        
        var replaced = try! SwKeyConvert.PublicKey.derToPKCS8PEM(publicKey.data()).replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
        replaced = replaced.replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
        replaced = String(replaced.filter { !" \n".contains($0) })
        
        UserDefaults.standard.set(replaced, forKey: "Client-PublicKey")
        
        UserDefaults.standard.set(try! SwKeyConvert.PrivateKey.derToPKCS1PEM(privateKey.data()),
                                  forKey: "Client-PrivateKey")
    }

    func generateAESKey() -> String {
        
        UserDefaults.standard.set(AES.generatePassword(), forKey: "AES-Key")
        return UserDefaults.standard.string(forKey: "AES-Key")!
    }
    
}
