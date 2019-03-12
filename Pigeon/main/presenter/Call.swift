//
//  Call.swift
//  Pigeon
//
//  Created by Safarnejad on 2/6/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit

class Call: UIViewController {

    @IBOutlet weak var listTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("call")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        
        if let result = UserDefaults.standard.value(forKey: "ConversationListBares") {
            listTextView.text = ""
            let bares : [String] = result as! [String]
            for x in bares {
                listTextView.text =  listTextView.text + x
            }
        
        }
    }
}
