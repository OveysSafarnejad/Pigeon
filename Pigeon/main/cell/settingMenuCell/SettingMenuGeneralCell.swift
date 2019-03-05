//
//  SettingMenuGeneralCell.swift
//  Pigeon
//
//  Created by Oveys Safarnejad on 3/4/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit

class SettingMenuGeneralCell: UITableViewCell {

    
    @IBOutlet weak var settingMenuTitle: UILabel!
    @IBOutlet weak var settingMenuDetail: UILabel!
    @IBOutlet weak var settingMenuImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(menu : String) -> SettingMenuGeneralCell {
        
        self.settingMenuTitle.text = menu
        self.settingMenuDetail.text = ""
        self.settingMenuImage.image = UIImage(named: "SettingMenu-" + menu + ".png")
        return self
    }

}
