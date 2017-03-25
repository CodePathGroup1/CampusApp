//
//  ChatCell.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import JSQMessagesViewController

class ChatCell: UITableViewCell {

    @IBOutlet weak var avatarPFImageView: PFImageView!
    @IBOutlet weak var sendersDescriptionLabel: UILabel!
    @IBOutlet weak var lastMessageTimestampLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarPFImageView.layer.cornerRadius = 30
        self.avatarPFImageView.clipsToBounds = true
    }

    func bindData(with conversation: PFObject) {
        let lastUser = conversation[C.Parse.Conversation.Keys.lastUser] as? PFUser
        avatarPFImageView.file = lastUser?[C.Parse.User.Keys.avatar] as? PFFile
        avatarPFImageView.loadInBackground()
        
        sendersDescriptionLabel.text = conversation[C.Parse.Conversation.Keys.sendersDescription] as? String
        lastMessageLabel.text = conversation[C.Parse.Conversation.Keys.lastMessage] as? String
        
        if let lastMessageTimestamp = conversation[C.Parse.Conversation.Keys.lastMessageTimestamp] as? Date {
            let dateDescription = JSQMessagesTimestampFormatter.shared().relativeDate(for: lastMessageTimestamp)
            if dateDescription == "Today" {
                lastMessageTimestampLabel.text = JSQMessagesTimestampFormatter.shared().time(for: lastMessageTimestamp)
            } else {
                lastMessageTimestampLabel.text = dateDescription
            }
        } else {
            lastMessageTimestampLabel.text = ""
        }
    }
}
