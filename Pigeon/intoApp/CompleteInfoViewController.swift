//
//  CompleteInfoViewController.swift
//  Pigeon
//
//  Created by Safarnejad on 1/19/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyRSA
import Contacts

class CompleteInfoViewController: UIViewController,  UITextFieldDelegate , UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var familyTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    private var contactsNumbers : [String] = []
    private var contactWithAccount : [ContactMapping] = []
    
    var doneBtn: UIBarButtonItem?
    //    let doneBtn = UIBarButtonItem(title: "Enjoy!", style: .plain, target: self, action: #selector(doneBtnTapped))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    // MARK:- TextFields
    @objc func textFieldDidChange(_ textField: UITextField) {
        if !(nameTextField.text?.isEmpty)! || !(familyTextField.text?.isEmpty)! {
            doneBtn!.isEnabled = true
        } else {
            doneBtn!.isEnabled = false
        }
    }
    
    // MARK:- Image Picker
    @objc func pictureTapped(sender: UITapGestureRecognizer? = nil) {
        
        viewTapped()
        let alert:UIAlertController=UIAlertController(title: "Profile Picture Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let gallaryAction = UIAlertAction(title: "Open Gallary", style: UIAlertAction.Style.default){
            UIAlertAction in self.openGallary()
        }
        let deleteImageAction = UIAlertAction(title: "Remove", style: UIAlertAction.Style.destructive){
            UIAlertAction in self.removePic()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        let defaultProfileImage = UIImage(named: "user.png")
        if (!(profileImageView.image?.isEqual(defaultProfileImage))!){
            alert.addAction(deleteImageAction)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func openGallary() {
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func removePic() {
        
        profileImageView.image = UIImage(named: "user.png")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.contentMode = .scaleToFill
            profileImageView.image = pickedImage
            profileImageView.clipsToBounds = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK:- Keyboard effect
    @objc func viewTapped(sender: UITapGestureRecognizer? = nil) {
        
        nameTextField.resignFirstResponder()
        familyTextField.resignFirstResponder()
    }
    
    
    //MARK:- Utility
    func setUp() {
        doneBtn = UIBarButtonItem(title: "Enjoy!", style: .plain, target: self, action: #selector(doneBtnTapped))
        doneBtn!.isEnabled = false
        navigationItem.rightBarButtonItem = doneBtn
        nameTextField.delegate = self
        familyTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        familyTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let gestuere = UITapGestureRecognizer(target: self, action: #selector(viewTapped(sender:)))
        gestuere.delegate = self
        self.view.addGestureRecognizer(gestuere)
        profileImageView.layer.cornerRadius = self.view.frame.width * 0.3/2
        let pictureGesture = UITapGestureRecognizer(target: self, action: #selector(pictureTapped));        self.profileImageView.addGestureRecognizer(pictureGesture)
        profileImageView.isUserInteractionEnabled = true
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 0.0/255.0, green: 173.0/255.0, blue: 235.0/255.0, alpha: 0.5)])
        familyTextField.attributedPlaceholder = NSAttributedString(string: "Family", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 0.0/255.0, green: 173.0/255.0, blue: 235.0/255.0, alpha: 0.5)])
    }
    
    
    
    func uploadProfilePicture(image: UIImage) {
        
        let imgData = image.jpegData(compressionQuality: 0.1)
        let parameters = ["number" : "0" + UserDefaults.standard.string(forKey: "Mobile")!]
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData!, withName: "fileset",fileName: "file.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: Urls.BaseURL.BASE + Urls.URI.IMAGE_PATH) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })

                upload.responseJSON { response in
                    print(response.result.value!)
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    func sendInformationForRegistry() {
        
        uploadProfilePicture(image: self.profileImageView.image!)
        
        let cypherParamsJson = createRequestJson()
        guard  let url = URL(string: Urls.BaseURL.BASE + Urls.URI.INFORMATION) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = cypherParamsJson
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                                
                                if dictionary["secret"] != nil && dictionary["data"] != nil {
                                    let encrypted = try EncryptedMessage(base64Encoded: dictionary["secret"]!)
                                    let privateKey = try PrivateKey(pemEncoded: UserDefaults.standard.value(forKey: "Client-PrivateKey")! as! String)
                                    let clearAESSecret = try encrypted.decrypted(with: privateKey, padding: .PKCS1).string(encoding: .utf8)
                                    let decryptedData = AES.decryptString(dictionary["data"]!, password: clearAESSecret)
                                    let xmppResult = try JSONSerialization.jsonObject(with: (decryptedData?.data(using: .utf8))!, options: []) as? [String: String]
                                    
                                    if xmppResult!["username"] != nil && xmppResult!["password"] != nil {
                                        UserDefaults.standard.set(xmppResult!["username"], forKey: "XMPPUser")
                                        UserDefaults.standard.set(xmppResult!["password"], forKey: "XMPPPassword")
                                        
                                        //FIXME:- need to sync contact with server
                                        
                                        self.manageContact()
                                        
                                        
                                        
                                        
                                        DispatchQueue.main.async {
                                            let appMain = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppMainTabBar")
                                            self.navigationController?.present(appMain, animated: true, completion: nil)
                                        }
                                    } else{
                                       
                                        DispatchQueue.main.async { [unowned self] in
                                            self.errorHandler(title: "Sorry!", message: "Can not connect to messaging service.")
                                        }
                                    }
                                }
                            }
                        } catch {
                            
                        }
                    }
 
                } else {
                    
                    DispatchQueue.main.async { [unowned self] in
                        self.errorHandler(title: "Error!", message: "Registration failed.")
                    }
                }
            }
            }.resume()
        
        
    }
    
    func createRequestJson() -> Data {
        let plainParameters : [String : String] = [
            "name"   : "\(nameTextField.text!)",
            "family" : "\(familyTextField.text!)",
            "number" : "0\(UserDefaults.standard.string(forKey: "Mobile")!)",
            "publickey" : "\(UserDefaults.standard.value(forKey: "Client-PublicKey")!)"
        ]
        let paramJsonData = try? JSONSerialization.data(withJSONObject: plainParameters)
        let encryptedDataWithAES = AES.encryptString(String(bytes: paramJsonData!, encoding: .utf8)!, password: UserDefaults.standard.string(forKey: "AES-Key")!)
        
        let clearAESSecret = try! ClearMessage(string: UserDefaults.standard.string(forKey: "AES-Key")!, using: .utf8)
        let encryptedAESSecret = try! clearAESSecret.encrypted(with: try PublicKey(base64Encoded: UserDefaults.standard.string(forKey: "Server-Key")!), padding: .PKCS1)
        let encryptedAESSecretString = encryptedAESSecret.base64String
        
        
        let cypherParameters : [String : String] = [
            "secret" : "\(encryptedAESSecretString)",
            "data"   : "\(encryptedDataWithAES!)"
        ]
        return try! JSONSerialization.data(withJSONObject: cypherParameters)
    }
    
    @objc func doneBtnTapped() {
        sendInformationForRegistry()
    }
    
    
    func errorHandler(title:String , message:String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) -> Void in
        }))
        self.present(alertController, animated: true, completion: nil)
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
                            if(!self.exist(number: editing)) {
                                self.contactsNumbers.append(editing)
                            }
                            
                        }
                    })
                } catch {
                    print(error)
                }
            } else {
                
                let alertController = UIAlertController(title: "Sorry!", message: "can't access to contacts. please allow pigeon to access you contacts in setting.", preferredStyle: .alert)
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
                                        
                                        let singleContact = ContactMapping()
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
                                        
                                        UserDefaults.standard.set(self.contactWithAccount, forKey: "Contacts")
                                        
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
            return json!
            
        } catch {
            return []
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
