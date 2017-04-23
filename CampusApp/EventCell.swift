//
//  EventCell.swift
//  CampusApp
//
//  Created by bwong on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import FaveButton

class EventCell: UITableViewCell {
    
    @IBOutlet weak var cellBackground: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startDateTimeLabel: UILabel!
    @IBOutlet weak var endDateTimeLabel: UILabel!
    @IBOutlet weak var detailLabel: TopAlignedLabel!
    @IBOutlet weak var favoriteButton: FaveButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackground.layer.cornerRadius = 5.0
        cellBackground.clipsToBounds = true
        
        cellBackground.layer.shadowColor = UIColor.black.cgColor
        cellBackground.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        cellBackground.layer.shadowOpacity = 0.10
        cellBackground.layer.shadowRadius = 1.0
        cellBackground.layer.masksToBounds = false
        
        favoriteButton.delegate = self
    }
}
