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
    
    /* ====================================================================================================
    MARK: - Log in
     ====================================================================================================== */
    @IBAction func loginButtonTapped(_ sender: AnyObject) {
        if let username = usernameField.text, let password = passwordField.text {
            HUD.show(.progress)
            
            PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) -> Void in
                if let _ = user {
                    HUD.hide(animated: true)
                    self.showViewController(storyboardIdentifier: "Main", viewControllerIdentifier: "EventNavigationVC")
                } else {
                    HUD.flash(.error)
                    print(error?.localizedDescription ?? "Unknown error")
                }
            }
        }
    }
    /* ==================================================================================================== */
}
