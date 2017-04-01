//
//  NewEventViewController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/31/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import Parse

class NewEventViewController: UIViewController {

    
    @IBOutlet weak var titleTextField: RoundTextField!
    @IBOutlet weak var startDateTimeTextField: RoundTextField!
    @IBOutlet weak var endDateTimeTextField: RoundTextField!
    @IBOutlet weak var campusTextField: RoundTextField!
    @IBOutlet weak var buildingTextField: RoundTextField!
    @IBOutlet weak var roomTextField: RoundTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
}
