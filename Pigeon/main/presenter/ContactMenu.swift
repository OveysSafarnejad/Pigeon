//
//  Contact.swift
//  Pigeon
//
//  Created by Safarnejad on 2/6/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit
import Contacts
import CoreData


class ContactMenu: UIViewController {
    
    private var contactsNumbers : [String] = []
    private var contactWithAccount : [ContactMapping] = []
    
    var contactActor = ContactActor()
    let store = CNContactStore()
    var accessGrant : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("contact")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.contactActor.requestAccessToStore() 
    }

    
}
