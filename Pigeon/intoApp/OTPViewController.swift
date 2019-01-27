//
//  OTPViewController.swift
//  Pigeon
//
//  Created by Safarnejad on 1/17/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit
import SwiftyRSA
import SwCrypt

class OTPViewController: UIViewController , UIGestureRecognizerDelegate , UITextFieldDelegate {
    
    
    
    @IBOutlet weak var otpTextfield: UITextField!
    @IBOutlet weak var otpLabel: UILabel!
    
    var passedPhoneNumber : String!
    var sendBtn: UIBarButtonItem!
    var aesSecretKey : String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUp()
    }
    
    // MARK:- TextFields
    @objc func textFieldDidChange(_ otpTextField: UITextField) {
        
        if let text = otpTextField.text {
            if otpTextfield == self.otpTextfield {
                if validateOTP(text) {
                    sendBtn.isEnabled = true
                } else {
                    sendBtn.isEnabled = false
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= 5
    }
    
    
    // MARK:- Keyboard effect
    @objc func viewTapped(sender: UITapGestureRecognizer? = nil) {
        
        otpTextfield.resignFirstResponder()
    }
    
    
    // MARK:- utility
    @objc func sendBtnTapped() {
        
        
        let cypherParamsJson = createRequestJson()
        
        guard  let url = URL(string: Urls.BaseURL.BASE + Urls.URI.OTP_VALIDATION) else {
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
                                    if self.openResponce(response: dictionary) {
                                        
                                        DispatchQueue.main.async { [unowned self] in
                                            let appMain = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppMainTabBar")
                                            self.navigationController?.present(appMain, animated: true, completion: nil)
                                        }
                                        
                                    } else {
                                        
                                        DispatchQueue.main.async { [unowned self] in
                                            let completeInfoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CompleteInfoViewController") as! CompleteInfoViewController
                                            self.navigationController?.pushViewController(completeInfoVC, animated: true)
                                        }
                                        
                                    }
                                }
                            }
                            
                        } catch {
                            
                        }
                    }
                } else /* status code != 200 */ {
                    
                    DispatchQueue.main.async { [unowned self] in
                        let alertController = UIAlertController(title: "Oops!", message: "Wrong OTP!", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) -> Void in
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            }.resume()
    }
    
    func validateOTP(_ otpCode : String) -> Bool {
        
        let OTP_REGEX = "[0-9]{5}"
        let otp = NSPredicate(format: "SELF MATCHES %@", OTP_REGEX)
        let result =  otp.evaluate(with: otpCode)
        return result
    }
    
    func setUp() {
        
        sendBtn = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendBtnTapped))
        sendBtn.isEnabled = false
        otpLabel.text = "OTP has been sent to the\n +98 \(passedPhoneNumber!), Type it below and Enjoy"
        otpTextfield.keyboardType = .asciiCapableNumberPad
        navigationItem.rightBarButtonItem = sendBtn
        otpTextfield.delegate = self
        otpTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let gestuere = UITapGestureRecognizer(target: self, action: #selector(viewTapped(sender:)))
        gestuere.delegate = self
        self.view.addGestureRecognizer(gestuere)
        otpTextfield.attributedPlaceholder = NSAttributedString(string: "- - - - -", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 0.0/255.0, green: 173.0/255.0, blue: 235.0/255.0, alpha: 0.5)])
    }
    
    // generate key pairs for client and save them in defaults.
//    func generateRSAKeys() {
//
//        let keyPair = try! SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
//        let privateKey = keyPair.privateKey
//        let publicKey = keyPair.publicKey
//
//        UserDefaults.standard.set(try! SwKeyConvert.PublicKey.derToPKCS8PEM(publicKey.data()),
//                                  forKey: "Client-PublicKey")
//
//        UserDefaults.standard.set(try! SwKeyConvert.PrivateKey.derToPKCS1PEM(privateKey.data()),
//                                  forKey: "Client-PrivateKey")
//
//    }
//
//    func generateAESKey() {
//        aesSecretKey = AES256CBC.generatePassword()
//    }
    
    func createRequestJson() -> Data {
        let cryptography = Cryptography()
        cryptography.generateRSAKeys()
        let plainParameters : [String : String] = [
            "publickey" : "\(UserDefaults.standard.value(forKey: "Client-PublicKey")!)",
            "otp"    : "\(otpTextfield.text!)",
            "number" : "0\(UserDefaults.standard.string(forKey: "Mobile")!)"
        ]
        let paramJsonData = try? JSONSerialization.data(withJSONObject: plainParameters)
        cryptography.generateAESKey()
        let encryptedDataWithAES = AES256CBC.encryptString(String(bytes: paramJsonData!, encoding: .utf8)!, password: UserDefaults.standard.string(forKey: "AES-Key")!)
        
        let clearAESSecret = try! ClearMessage(string: UserDefaults.standard.string(forKey: "AES-Key")!, using: .utf8)
        let encryptedAESSecret = try! clearAESSecret.encrypted(with: try PublicKey(base64Encoded: UserDefaults.standard.string(forKey: "Server-Key")!), padding: .PKCS1)
        let encryptedAESSecretString = encryptedAESSecret.base64String
        
        
        let cypherParameters : [String : String] = [
            "secret" : "\(encryptedAESSecretString)",
            "data"   : "\(encryptedDataWithAES!)"
        ]
        return try! JSONSerialization.data(withJSONObject: cypherParameters)
    }
    
    func openResponce(response: [String: String]) -> Bool {
        
        
        do{
            let encrypted = try EncryptedMessage(base64Encoded: response["secret"]!)
            let privateKey = try PrivateKey(pemEncoded: UserDefaults.standard.value(forKey: "Client-PrivateKey")! as! String)
            let clearAESSecret = try encrypted.decrypted(with: privateKey, padding: .PKCS1).string(encoding: .utf8)
            
            
            let decryptedData = AES256CBC.decryptString(response["data"]!, password: clearAESSecret)
            let json = try JSONSerialization.jsonObject(with: (decryptedData?.data(using: .utf8))!, options: []) as? [String: String]
            
            if json!["is_registered"] == "true" {
                return true
            } else {
                return false
            }
            
        } catch {
            
        }
        
        return false
    }
    
}
