//
//  RegisterPNViewController.swift
//  Pigeon
//
//  Created by Safarnejad on 1/16/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit
import SwCrypt
import SwiftyRSA

class RegisterPNViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var mobileTextfield: UITextField!
    var nextBtn: UIBarButtonItem!
    var clientGeneratedPublicKey : Any!
    var clientGeneratedPrivateKey :  Any!
    var serverPublicKey : Any!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    // MARK:- TextFields
    @objc func textFieldDidChange(_ mobile: UITextField) {
        
        if let text = mobile.text {
            if mobile == self.mobileTextfield {
                if validatePhoneNumber(text) {
                    nextBtn.isEnabled = true
                } else {
                    nextBtn.isEnabled = false
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= 10
    }
    
    
    // MARK:- Keyboard effect
    @objc func viewTapped(sender: UITapGestureRecognizer? = nil) {
        mobileTextfield.resignFirstResponder()
    }
    
    // MARK:- Utility
    func validatePhoneNumber(_ mobile : String) -> Bool {
        let PHONE_REGEX = "[9][0-9]{9}"
        let phone = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phone.evaluate(with: mobile)
        return result
    }
    
    @objc func nextTapped() {
        
        UserDefaults.standard.set(mobileTextfield.text!, forKey: "Mobile")
        
        let parameters : [String : String] = [
            "number"    : "\(mobileTextfield.text!)"
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        guard  let url = URL(string: Urls.BaseURL.BASE + Urls.URI.PHONE_VALIDATION) else {
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
                                let serverPublicKey = dictionary["serverPublicKey"]!
                                UserDefaults.standard.set(serverPublicKey, forKey: "Server-Key")
                                do {
                                    
                                    DispatchQueue.main.async { [unowned self] in
                                        let otpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
                                        otpVC.passedPhoneNumber = self.mobileTextfield.text!
                                        self.navigationController?.pushViewController(otpVC, animated: true)
                                    }
                                
                                } catch {
                                    
                                    DispatchQueue.main.async { [unowned self] in
                                        let alertController = UIAlertController(title: "Oops!", message: "An Error Occured! Try Latter! ", preferredStyle: .alert)
                                        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) -> Void in
                                        }))
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                    
                                }
                            }
                        } catch {
                            
                        }
                    }
                } else if httpResponse.statusCode == 403 {
                    
                    DispatchQueue.main.async { [unowned self] in
                        let alertController = UIAlertController(title: "Sorry", message: "Mobile Isn't Registered In Server!", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) -> Void in
                            self.mobileTextfield.text = ""
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                } else {
                    
                    DispatchQueue.main.async { [unowned self] in
                        let alertController = UIAlertController(title: "Sorry", message: "No Reply From Server, Try Again!", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) -> Void in
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                }
            }
            }.resume()
    }
    
    func setUp() {
        nextBtn = UIBarButtonItem(title: "Next", style: .plain, target: self,
                   action: #selector(nextTapped))
        nextBtn.isEnabled = false
        navigationItem.rightBarButtonItem = nextBtn
        mobileTextfield.delegate = self
        mobileTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let gestuere = UITapGestureRecognizer(target: self, action: #selector(viewTapped(sender:)))
        gestuere.delegate = self
        self.view.addGestureRecognizer(gestuere)
        mobileTextfield.keyboardType = .asciiCapableNumberPad
        mobileTextfield.attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 0.0/255.0, green: 173.0/255.0, blue: 235.0/255.0, alpha: 0.5)])
    }
    
    
    //    func sendMessageToServer() {
    //
    //        let test: String = "this is a test"
    //        let clear = try! ClearMessage(string: test, using: .utf8)
    //        let encrypted = try! clear.encrypted(with: serverPublicKey as! PublicKey, padding: .PKCS1)
    //        let enc = encrypted.base64String
    //
    //
    //        let parameters : [String : String] = [
    //            "result" : "\(enc)"
    //        ]
    //        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
    //        guard  let url = URL(string: "http://192.168.100.4:3030/decrypt") else {
    //            return
    //        }
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "POST"
    //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    //        request.httpBody = jsonData
    //        let session = URLSession.shared
    //
    //        session.dataTask(with: request) { (data, response, error) in
    //
    //        }.resume()
    //    }
}
