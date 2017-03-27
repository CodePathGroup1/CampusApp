//
//  LoginVC.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import Parse
import PKHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: RoundTextField!
    @IBOutlet weak var passwordField: RoundTextField!
    
    @IBOutlet weak var loginButton: RoundButton!
    @IBOutlet weak var registerButton: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: remove this once development is finished
        emailField.text = "codepath@codepath.com"
        passwordField.text = "codepath"
    }
    
    
    /* ====================================================================================================
     MARK: - Dismiss keyboard when tapping background
     ====================================================================================================== */
    @IBAction func backgroundTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
    MARK: - Log in
     ====================================================================================================== */
    @IBAction func loginButtonTapped(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            if !email.isEmpty && !password.isEmpty {
                HUD.show(.progress)
                
                PFUser.logInWithUsername(inBackground: email, password: password) { (user: PFUser?, error: Error?) -> Void in
                    if let _ = user {
                        HUD.hide(animated: true)
                        self.showViewController(storyboardIdentifier: "Event", viewControllerIdentifier: "EventNavigationController")
                    } else {
                        HUD.flash(.error)
                        print(error?.localizedDescription ?? "Unknown error")
                    }
                }
            }
        }
    }
    /* ==================================================================================================== */
}
