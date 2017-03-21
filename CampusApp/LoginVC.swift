//
//  LoginVC.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var usernameField: RoundTextField!
    @IBOutlet weak var passwordField: RoundTextField!
    
    @IBOutlet weak var loginButton: RoundButton!
    @IBOutlet weak var registerButton: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /* ====================================================================================================
     MARK: - Dismiss keyboard when tapping background
     ====================================================================================================== */
    @IBAction func backgroundTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    /* ==================================================================================================== */
}
