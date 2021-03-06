//
//  ContactActor.swift
//  Pigeon
//
//  Created by Oveys Safarnejad on 3/13/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import Foundation
import Contacts
import SwiftyRSA
import SwCrypt
import CoreData

class ContactActor: UIViewController {
    
    
    
    
    var contactsNumbers : [String] = []
    var contactWithAccount : [ContactMapping] = []
    
    let store = CNContactStore()
    var accessGrant : Bool = false
    
    func requestAccessToStore() {
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access" , error)
                return
            }
            
            if(granted) {
                self.accessGrant = granted
                self.manageContact()
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
            self.syncContactList(contactNumbers: self.contactsNumbers)
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
    
    
    func syncContactList(contactNumbers : [String]) {
        
        let parameters : [String : Any] = [
            "numbers" : contactNumbers,
            "domain" : "\(UserDefaults.standard.string(forKey: "Domain")!)",
            "publickey" : "\(UserDefaults.standard.value(forKey: "Client-PublicKey")!)"
        ]
        
        
        let paramJsonData = try? JSONSerialization.data(withJSONObject: parameters)
        let encryptedDataWithAES = AES.encryptString(String(bytes: paramJsonData!, encoding: .utf8)!, password: UserDefaults.standard.string(forKey: "AES-Key")!)
        
        let clearAESSecret = try! ClearMessage(string: UserDefaults.standard.string(forKey: "AES-Key")!, using: .utf8)
        let encryptedAESSecret = try! clearAESSecret.encrypted(with: try PublicKey(base64Encoded: UserDefaults.standard.string(forKey: "Server-Key")!), padding: .PKCS1)
        let encryptedAESSecretString = encryptedAESSecret.base64String
        
        
        let cypherParameters : [String : String] = [
            "secret" : "\(encryptedAESSecretString)",
            "data"   : "\(encryptedDataWithAES!)"
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: cypherParameters)
        guard  let url = URL(string: Urls.BaseURL.BASE + Urls.URI.CONTACT) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            
                            if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                                if dictionary["secret"] != nil && dictionary["data"] != nil {
                                    let res = self.openResponse(response: dictionary)
                                    
                                    if(res.count > 0) {
                                        
                                        var singleContact = ContactMapping()
                                        for temp in res {
                                            
                                            singleContact.username = temp["username"] as! String + "@" + UserDefaults.standard.string(forKey: "Domain")!
                                            singleContact.mobile = temp["number"] as! String
                                            singleContact.status = temp["status"] as! String
                                            singleContact.appName = temp["appName"] as! String
                                            
                                            if (self.findRealName(mobile: singleContact.mobile) != ""){
                                                singleContact.contactName = self.findRealName(mobile: singleContact.mobile)
                                            } else {
                                                singleContact.contactName = singleContact.appName
                                            }
                                            
                                            self.contactWithAccount.append(singleContact)
                                            singleContact = ContactMapping()
                                        }
                                        
                                        self.saveContactsToContext(contacts: self.contactWithAccount)
                                        
                                        
                                    } else {
                                        print("none of the phone contacts has account")
                                    }
                                }
                            }
                            
                        } catch {
                            print("error print in catch block")
                        }
                    }
                } else /*response code is not 200*/ {
                    print("response code is not 200")
                    print(httpResponse.statusCode)
                }
            }
            
            }.resume()
    }
    
    func findRealName(mobile : String) -> String {
        
        var contactName = ""
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access" , error)
                return
            }
            
            if(granted) {
                
                let keys = [CNContactGivenNameKey , CNContactFamilyNameKey , CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        for number in contact.phoneNumbers {
                            if (number.value.stringValue.contains(mobile)){
                                
                                contactName = contact.givenName + " " + contact.familyName
                            }
                        }
                    })
                } catch {
                    print(error)
                }
                
            } else {
                
                let alertController = UIAlertController(title: "Sorry!", message: "can't access to contacts.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) -> Void in
                }))
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
        return contactName
    }
    
    
    func saveContactsToContext(contacts : [ContactMapping]) {
        
        //FIXME:- don't allow to duplicate contacts in core data
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        for contact in contacts {
            
            let saving = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context)
            saving.setValue(contact.contactName, forKey: "name")
            saving.setValue(contact.appName, forKey: "app_name")
            saving.setValue(contact.mobile, forKey: "mobile")
            saving.setValue(contact.status, forKey: "status")
            saving.setValue(contact.username, forKey: "username")
            
            do {
                try context.save()
            } catch {
                print("Error saving: \(error)")
            }
        }
        
        //        let fetchRequest =
        //            NSFetchRequest<NSManagedObject>(entityName: "Contact")
        //
        //        do {
        //            var fetchedContacts = try context.fetch(fetchRequest)
        //
        //            for fetched in fetchedContacts {
        //
        //                print(fetched.value(forKey: "name"))
        //
        //            }
        //
        //        } catch let error as NSError {
        //            print("Could not fetch. \(error), \(error.userInfo)")
        //        }
    }
    
    
    
    func openResponse(response: [String : String]) -> [Dictionary<String , Any>] {
        do {
            let encrypted = try EncryptedMessage(base64Encoded: response["secret"]!)
            let privateKey = try PrivateKey(pemEncoded: UserDefaults.standard.value(forKey: "Client-PrivateKey")! as! String)
            let clearAESSecret = try encrypted.decrypted(with: privateKey, padding: .PKCS1).string(encoding: .utf8)
            let decryptedData = AES.decryptString(response["data"]!, password: clearAESSecret)
            let json = try JSONSerialization.jsonObject(with: (decryptedData?.data(using: .utf8))!, options: []) as? [Dictionary<String,Any>]
            return json!
            
        } catch {
            return []
        }
    }
}
