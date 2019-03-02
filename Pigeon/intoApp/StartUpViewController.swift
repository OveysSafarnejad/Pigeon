//
//  StartUpViewController.swift
//  Pigeon
//
//  Created by Safarnejad on 1/15/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit
import Contacts

class StartUpViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var iconImage: UIImageView!
    var contactsNumbers : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setUp() {
        registerButton.layer.cornerRadius = registerButton.frame.height/2
        registerButton.clipsToBounds = true
        loginButton.layer.cornerRadius = loginButton.frame.height/2
        loginButton.clipsToBounds = true
    }
    
    //MARK:- Actions
    @IBAction func registerButtonTouchUpInside(_ sender: Any) {
        
        let registerPNVC = UIStoryboard.init(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "RegisterPNViewController")
        self.navigationController?.pushViewController(registerPNVC, animated: true)
    }
}
