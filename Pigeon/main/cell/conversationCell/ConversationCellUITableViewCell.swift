//
//  ConversationCellUITableViewCell.swift
//  Pigeon
//
//  Created by Oveys Safarnejad on 3/2/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit

class ConversationCellUITableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var contactPicture: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var lastPmPreview: UILabel!
    @IBOutlet weak var lastPmTime: UILabel!
    @IBOutlet weak var unreadMessages: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contactPicture.layer.cornerRadius = self.contactPicture.frame.size.width/2;
        self.contactPicture.layer.masksToBounds = true;
        self.unreadMessages.layer.cornerRadius = self.unreadMessages.frame.size.width/2;
        self.unreadMessages.layer.masksToBounds = true;
        self.contactName.text = "";
        self.lastPmPreview.text = "";
        self.lastPmTime.text = "";
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(conversation : ConversationMapping) {
        
        findImage(imageURL: conversation.conversationPicture)
        self.contactName.text = conversation.contact.appName
        //FIXME:- lastSeen should be lastPmDate
        self.lastPmTime.text = conversation.lastSeenDate
        updateUnreadMessagesIcon(count: conversation.unreadCount)
        self.lastPmPreview.text = conversation.messages.last!.body
        
    }
    
    func findImage(imageURL : String) {
        
        let url = URL(string: imageURL)!
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                
                let image = UIImage(data : data) ?? UIImage(named: "user.png")
                self.contactPicture.image = image
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func updateUnreadMessagesIcon(count: Int) {
        self.unreadMessages.isHidden = count == 0;
        self.unreadMessages.text = String(count)
    }
    
}
