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
        
        // avatarPFImageView = 60 x 60
        self.avatarPFImageView.layer.cornerRadius = 30
        self.avatarPFImageView.clipsToBounds = true
    }

    
    /* ====================================================================================================
     MARK: - Bind Data to ChatCell
     ====================================================================================================== */
    func bindData(with pfObject: PFObject) {
        let conversation = Conversation(pfObject: pfObject)
        
        let lastUser = conversation.lastUser
        avatarPFImageView.file = lastUser?[C.Parse.User.Keys.avatar] as? PFFile
        avatarPFImageView.loadInBackground()
        
        sendersDescriptionLabel.text = conversation.sendersDescription
        lastMessageLabel.text = conversation.lastMessage
        
        if let lastMessageTimestamp = conversation.lastMessageTimestamp {
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
    /* ==================================================================================================== */
}
