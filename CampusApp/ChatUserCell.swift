//
//  ChatUserCell.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/25/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import ParseUI

class ChatUserCell: UITableViewCell {

    @IBOutlet weak var avatarPFImageView: PFImageView!
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarPFImageView.layer.cornerRadius = 15
        avatarPFImageView.clipsToBounds = true
    }
    
    func bindData(pfUser: PFUser) {
        
        let user = User(pfObject: pfUser)
        
        avatarPFImageView.file = user.avatarPFFile
        avatarPFImageView.loadInBackground()
        
        if let fullName = user.fullName, !fullName.isEmpty {
            userFullNameLabel.text = user.fullName
        } else if let user = user.pfObject as? PFUser, let username = user.username, !username.isEmpty {
            userFullNameLabel.text = username
        } else if let objectId = user.pfObject.objectId {
            userFullNameLabel.text = objectId
        }
    }
}
