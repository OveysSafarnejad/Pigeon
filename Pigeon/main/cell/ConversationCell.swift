//
//  ConversationCell.swift
//  Pigeon
//
//  Created by Safarnejad on 1/26/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {

    @IBOutlet weak var ConvPicture: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var lastPMTime: UILabel!
    @IBOutlet weak var lastPMPreview: UILabel!
    @IBOutlet weak var notification: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.ConvPicture.layer.cornerRadius = self.ConvPicture.frame.size.width/2;
        self.ConvPicture.layer.masksToBounds = true;
        self.notification.layer.cornerRadius = self.notification.frame.size.width/2;
        self.notification.layer.masksToBounds = true;
        self.contactName.text = "";
        self.lastPMPreview.text = "";
        self.lastPMTime.text = "";
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK:- Utility
    func configureCell(conversation : Conversation) {
        
//        self.ConvPicture.image = conversation.convPicture
//        self.contactName.text = conversation.contactName
//        self.lastPMPreview.text = conversation.pmPreview
//        updateTimeLabelWithDate(lastPmDate: conversation.lastPMTime)
//        updateUnreadMessagesIcon(count: conversation.notification)
    }
    
    func updateTimeLabelWithDate(lastPmDate : NSDate) {
        
        let dateFormater = DateFormatter(coder: NSCoder())
        dateFormater!.timeStyle = .short
        dateFormater!.dateStyle = .none
        dateFormater?.doesRelativeDateFormatting = false
        self.lastPMTime.text = dateFormater?.string(from: lastPmDate as Date)
    }
    
    func updateUnreadMessagesIcon(count: String) {
        //self.notification.hidden = count == 0;
        self.notification.text = count
    }

}
