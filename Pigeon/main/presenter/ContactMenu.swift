//
//  Contact.swift
//  Pigeon
//
//  Created by Safarnejad on 2/6/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit
import Contacts


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
        manageContact()
    }
    
    
    func requestAccessToStore () {
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access" , error)
                return
            }
            
            if(granted) {
                self.accessGrant = granted
            } else {
                
                let alertController = UIAlertController(title: "Sorry!", message: "can't access to contacts. please allow pigeon to access you contacts in setting.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) -> Void in
                }))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    func manageContact() {
        
        if(self.accessGrant) {
            
            let keys = [CNContactGivenNameKey , CNContactFamilyNameKey , CNContactPhoneNumbersKey]
            
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            do {
                try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                    for number in contact.phoneNumbers {
                        var editing = number.value.stringValue.replacingOccurrences(of: " ", with: "")
                        editing = editing.replacingOccurrences(of: "-", with: "")
                        editing = editing.replacingOccurrences(of: "(", with: "")
                        editing = editing.replacingOccurrences(of: ")", with: "")
                        editing = editing.deletingPrefix("0")
                        editing = editing.deletingPrefix("+98")
                        if(!self.exist(number: editing)) {
                            self.contactsNumbers.append(editing)
                        }
                        
                    }
                })
            } catch {
                print(error)
            }
        }
        if (self.contactsNumbers.count != 0){
            self.contactActor.syncContactList(contactNumbers: self.contactsNumbers)
        }
    }


func exist(number : String) -> Bool {
    var exist = false
    for finded in contactsNumbers {
        if number == finded {
            exist = true
            break
        }
    }
    return exist
}

}
