//
//  DetailEventViewController.swift
//  CampusApp
//
//  Created by bwong on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var event: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = event.summary
        descriptionLabel.text = event.description
        
        print(event)
    }
}
