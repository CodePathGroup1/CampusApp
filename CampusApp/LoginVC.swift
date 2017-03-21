//
//  LoginVC.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: RoundTextField!
    @IBOutlet weak var passwordField: RoundTextField!
    
    @IBOutlet weak var loginButton: RoundButton!
    @IBOutlet weak var registerButton: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /* ====================================================================================================
     MARK: - Dismiss keyboard when tapping background or pressing enter
     ====================================================================================================== */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    @IBAction func backgroundTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    /* ==================================================================================================== */
}
