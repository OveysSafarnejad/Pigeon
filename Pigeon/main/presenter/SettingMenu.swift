//
//  SettingMenuViewController.swift
//  Pigeon
//
//  Created by Safarnejad on 2/6/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit

class SettingMenu: UIViewController ,UITableViewDelegate , UITableViewDataSource {
    

    
    
    @IBOutlet weak var settingGroupedTableView: UITableView!
    let settingMenu : [String] = ["Appearance" ,"Privacy" ,"Data" ,"Notification" ,"Language"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
    }
    
    //MARK:- Tableview delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return 5
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath.section == 0) {

        } else if (indexPath.section == 1) {
            
            if let cell = self.settingGroupedTableView.dequeueReusableCell(withIdentifier: "SettingMenuCell", for: indexPath) as? SettingMenuGeneralCell {
                
                return cell.configureCell(menu: settingMenu[indexPath.row])
    
            } else {
                return ConversationCellUITableViewCell()
            }
            
        } else {

        }
        return ConversationCellUITableViewCell()

    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func setTableView() {
        settingGroupedTableView.delegate = self
        settingGroupedTableView.dataSource = self
        settingGroupedTableView.separatorStyle = .none
        self.settingGroupedTableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 10.0))
        self.settingGroupedTableView.backgroundColor = .clear
    }
    
}
