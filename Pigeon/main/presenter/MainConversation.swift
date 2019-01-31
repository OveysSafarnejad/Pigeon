//
//  MainConversation.swift
//  Pigeon
//
//  Created by Safarnejad on 1/26/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit


class MainConversation: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var mainConversationTableView: UITableView!
    var conversations : [Conversation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //FIXME: send request to server for fetch conversations by xmpp params saved on user defaults
        //
        
        
        if !OneChat.sharedInstance.isConnected() {
        
            OneChat.sharedInstance.connect(username: UserDefaults.standard.string(forKey: "XMPPUser")! + Constants.LoginPostfix.USERNAME_POSTFIX, password: UserDefaults.standard.string(forKey: "XMPPPassword")!) { (stream, error) -> Void in
                if let _ = error {
                    let alertController = UIAlertController(title: "Sorry", message: "An error occured when connecting!: \(String(describing: error))", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                        //do something
                    }))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    
                    
                    OneRoom.createRoom("javadRoom", completionHandler: { (XMPPRoom) in
                        
                    })
                }
            }
        }
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.mainConversationTableView.reloadData()
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
    
}
