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

    @IBOutlet weak var cellBackground: UIView!
    
    @IBOutlet weak var avatarPFImageView: PFImageView!
    @IBOutlet weak var sendersDescriptionLabel: UILabel!
    @IBOutlet weak var lastMessageTimestampLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackground.layer.cornerRadius = 4.0
        cellBackground.clipsToBounds = true
        
        cellBackground.layer.shadowColor = UIColor.black.cgColor
        cellBackground.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        cellBackground.layer.shadowOpacity = 0.10
        cellBackground.layer.shadowRadius = 1.0
        cellBackground.layer.masksToBounds = false
        
        self.avatarPFImageView.layer.cornerRadius = 17
        self.avatarPFImageView.clipsToBounds = true
    }

    
    /* ====================================================================================================
     MARK: - Bind Data to ChatCell
     ====================================================================================================== */
    func bindData(with pfObject: PFObject) {
        if let userObject = pfObject[C.Parse.Conversation.Keys.lastUser] as? PFUser {
            let user = User(pfObject: userObject)
            
            if let avatarPFFile = user.avatarPFFile {
                avatarPFImageView.file = avatarPFFile
                avatarPFImageView.loadInBackground()
            }
            
            if let fullName = user.fullName, !fullName.isEmpty {
                sendersDescriptionLabel.text = fullName
            } else if let username = userObject.username {
                sendersDescriptionLabel.text = username
            } else {
                sendersDescriptionLabel.text = nil
            }
        }
        
        if let lastMessageObject = pfObject[C.Parse.Conversation.Keys.lastMessage] as? PFObject {
            let lastMessage = Message(pfObject: lastMessageObject)
            
            lastMessageLabel.text = lastMessage.text
            
            if let lastMessageTimestamp = lastMessage.pfObject?.createdAt {
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
    /* ==================================================================================================== */
}
