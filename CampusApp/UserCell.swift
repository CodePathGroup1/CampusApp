//
//  AttendeeCell.swift
//  CampusApp
//
//  Created by Thomas Zhu on 4/9/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import ParseUI
import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var userAvatarPFImageView: PFImageView!
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isHidden = false
        
        self.userAvatarPFImageView.layer.cornerRadius = 15
        self.userAvatarPFImageView.clipsToBounds = true
    }
    
    func bindData(with attendee: PFUser) {
        self.userAvatarPFImageView.file = attendee[C.Parse.User.Keys.avatar] as? PFFile
        self.userAvatarPFImageView.loadInBackground()
        
        if let fullName = attendee[C.Parse.User.Keys.fullName] as? String, !fullName.isEmpty {
            self.userFullNameLabel.text = fullName
        } else if let username = attendee.username {
            self.userFullNameLabel.text = username
        } else {
            self.isHidden = true
        }
    }
}
