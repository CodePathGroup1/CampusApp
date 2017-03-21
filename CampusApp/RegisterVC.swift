//
//  RegisterVC.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    /* ====================================================================================================
        MARK: - Dismiss keyboard when tapping background or pressing enter
     ====================================================================================================== */
    @IBAction func backgroundTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    /* ==================================================================================================== */
}
