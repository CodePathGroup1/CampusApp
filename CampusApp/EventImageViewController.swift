//
//  EventImageViewController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 4/10/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit

class EventImageViewController: UIViewController {

    @IBOutlet weak var eventImageView: UIImageView!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventImageView.image = image
        eventImageView.isUserInteractionEnabled = true
    }

    @IBAction func imageTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
