//
//  LoginVC.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse
import ParseFacebookUtilsV4
import PKHUD
import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: RoundTextField!
    @IBOutlet weak var passwordField: RoundTextField!
    
    @IBOutlet weak var loginButton: RoundButton!
    @IBOutlet weak var facebookLoginView: UIView!
    
    @IBOutlet weak var registerButton: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLoginView.layer.cornerRadius = 15
        facebookLoginView.clipsToBounds = true
        
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
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        // Facebook permissions: https://developers.facebook.com/docs/facebook-login/permissions/
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile"]) { user, error in
            HUD.show(.progress)
            
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                }
                HUD.hide(animated: true)
                self.showViewController(storyboardIdentifier: "Event", viewControllerIdentifier: "EventNavigationController")
            } else {
                HUD.flash(.error)
                print(error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    /* ==================================================================================================== */
}
