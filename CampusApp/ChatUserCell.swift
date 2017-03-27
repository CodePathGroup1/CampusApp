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
        
        avatarPFImageView.layer.cornerRadius = 30
        avatarPFImageView.clipsToBounds = true
    }
    
    func bindData(user: User) {
//        avatarPFImageView.file = user.avatarPFFile
        avatarPFImageView.loadInBackground()
        
        userFullNameLabel.text = user.fullName
    }
}
