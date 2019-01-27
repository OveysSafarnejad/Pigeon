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

class CompleteInfoViewController: UIViewController,  UITextFieldDelegate , UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var familyTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
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
                                
                                print(dictionary)
                            }
                        } catch {
                            
                        }
                    }
                    
                    DispatchQueue.main.async {
                        let appMain = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppMainTabBar")
                        self.navigationController?.present(appMain, animated: true, completion: nil)
                    }
                    
                } else {
                   
                    DispatchQueue.main.async { [unowned self] in
                        let alertController = UIAlertController(title: "Error!", message: "Registration failed.", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) -> Void in
                        }))
                        self.present(alertController, animated: true, completion: nil)
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
    
    @objc func doneBtnTapped() {
        sendInformationForRegistry()
    }
}
