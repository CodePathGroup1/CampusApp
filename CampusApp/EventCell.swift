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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startDateTimeLabel: UILabel!
    @IBOutlet weak var endDateTimeLabel: UILabel!
    @IBOutlet weak var detailLabel: TopAlignedLabel!
    @IBOutlet weak var favoriteButton: FaveButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        favoriteButton.delegate = self
    }
}
