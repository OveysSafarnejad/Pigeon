//
//  ProfileForSettingCell.swift
//  Pigeon
//
//  Created by Oveys Safarnejad on 3/5/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit

class ProfileForSettingCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func configureCell() -> ProfileForSettingCell{
        //FIXME:- set this profile according to real profile image
        self.fullNameLabel.text = UserDefaults.standard.string(forKey: "XMPPUser")
        self.mobileLabel.text = UserDefaults.standard.string(forKey: "Mobile")
        return self
    }
    
}
