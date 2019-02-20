//
//  MainConversation.swift
//  Pigeon
//
//  Created by Safarnejad on 1/26/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit
import XMPPFramework
import Contacts
import SwiftyRSA
import SwCrypt


class MainConversation: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var mainConversationTableView: UITableView!
    private var conversations : [Conversation] = []
    private var contactsNumbers : [String] = []
    private var contactWithAccount : [ContactMapping] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("chat")
        manageContact()
        
        
        //FIXME: send request to server for fetch conversations by xmpp params saved on user defaults
        
        if !OneChat.sharedInstance.isConnected() {
            
            OneChat.sharedInstance.connect(username: UserDefaults.standard.string(forKey: "XMPPUser")! + "@" + UserDefaults.standard.string(forKey: "Domain")!, password: UserDefaults.standard.string(forKey: "XMPPPassword")!) { (stream, error) -> Void in
                
                if let _ = error {
                    let alertController = UIAlertController(title: "Sorry", message: "An error occured when connecting!: \(String(describing: error))", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                        //do something
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.mainConversationTableView.reloadData()
        
        //        OneRoom.createRoom("javadRoom", completionHandler: { (XMPPRoom) in
        //
        //        })
    }
    
    //MARK- tableview data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell : ConversationCell = self.mainConversationTableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath)  as? ConversationCell {
            
            cell.configureCell(conversation: conversations[indexPath.row])
            return cell
            
        } else {
            return ConversationCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    func setTableView() {
        mainConversationTableView.delegate = self
        mainConversationTableView.dataSource = self
        mainConversationTableView.separatorStyle = .none
        //self.tableData = [[NSMutableArray alloc] init];
        self.mainConversationTableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 10.0))
        self.mainConversationTableView.backgroundColor = .clear
    }
    
    
    private func manageContact() {
        
        
        //FIXME:- how we can guarentee the app can access phonebook?
        
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
                            var editing = number.value.stringValue.replacingOccurrences(of: " ", with: "")
                            editing = editing.replacingOccurrences(of: "-", with: "")
                            editing = editing.replacingOccurrences(of: "(", with: "")
                            editing = editing.replacingOccurrences(of: ")", with: "")
                            editing = editing.deletingPrefix("0")
                            editing = editing.deletingPrefix("+98")
                            self.contactsNumbers.append(editing)
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
        
        if (self.contactsNumbers.count != 0){
            syncContactList()
        }
        
    }
    
    private func syncContactList() {
        
        let parameters : [String : String] = [
            "numbers" : "\(self.contactsNumbers)",
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
                                            
                                            print(temp)
                                            
                                            singleContact.username = temp["username"] as! String
                                            singleContact.mobile = temp["number"] as! String
                                            singleContact.status = temp["status"] as! String
                                            singleContact.appName = temp["appName"] as! String
                                            
                                            if (self.findRealName(mobile: singleContact.mobile) != ""){
                                                singleContact.contactName = self.findRealName(mobile: singleContact.mobile)
                                            } else {
                                                singleContact.contactName = singleContact.appName
                                            }
                                            
                                            self.contactWithAccount.append(singleContact)
                                        }
                                        
                                    }else {
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
                                
                                contactName = contact.givenName + contact.familyName
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
    
    
    func openResponse(response: [String : String]) -> [Dictionary<String , Any>] {
        do {
            let encrypted = try EncryptedMessage(base64Encoded: response["secret"]!)
            let privateKey = try PrivateKey(pemEncoded: UserDefaults.standard.value(forKey: "Client-PrivateKey")! as! String)
            let clearAESSecret = try encrypted.decrypted(with: privateKey, padding: .PKCS1).string(encoding: .utf8)
            let decryptedData = AES.decryptString(response["data"]!, password: clearAESSecret)
            let json = try JSONSerialization.jsonObject(with: (decryptedData?.data(using: .utf8))!, options: []) as? [Dictionary<String,Any>]
            print(json)
            return json!
            
        } catch {
            return []
        }
    }
    
    
}


extension String {
    
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
