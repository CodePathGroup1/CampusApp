//
//  LoginVC.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import FBSDKCoreKit
import Parse
import ParseFacebookUtilsV4
import PKHUD
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: RoundTextField!
    @IBOutlet weak var passwordField: RoundTextField!
    
    @IBOutlet weak var loginButton: RoundButton!
    @IBOutlet weak var facebookLoginView: UIView!
    
    @IBOutlet weak var registerButton: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLoginView.layer.cornerRadius = 15
        facebookLoginView.clipsToBounds = true
        
        // TODO: remove this once development is finished
        usernameField.text = "codepath"
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
        if let username = usernameField.text, let password = passwordField.text {
            if !username.isEmpty && !password.isEmpty {
                HUD.show(.progress)
                
                PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) -> Void in
                    if let _ = user {
                        HUD.hide(animated: true)
                        self.showViewController(storyboardIdentifier: "Event", viewControllerIdentifier: "EventNavigationController")
                    } else {
                        HUD.flash(.label(error?.localizedDescription ?? "Unknown error"))
                    }
                }
            }
        }
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        // Facebook permissions: https://developers.facebook.com/docs/facebook-login/permissions/
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile", "email"]) { user, error in
            HUD.show(.progress)
            
            if let user = user {
                if user.isNew {
                    if let request = FBSDKGraphRequest(graphPath: "me",
                                                       parameters: ["fields":"name"]) {
                        _ = request.start { connection, result, error in
                            if let username = user.username,
                                let result = result as? [String: AnyObject],
                                let name = result["name"] as? String {
                                
                                user[C.Parse.User.Keys.username] = username
                                user[C.Parse.User.Keys.fullName] = name
                                
                                user.saveInBackground { succeeded, error in
                                    if succeeded {
                                        HUD.hide(animated: true)
                                        self.showViewController(storyboardIdentifier: "Event", viewControllerIdentifier: "EventNavigationController")
                                    } else {
                                        print(error?.localizedDescription ?? "Unknown error")
                                    }
                                }
                            }
                        }
                    }
                } else {
                    HUD.hide(animated: true)
                    self.showViewController(storyboardIdentifier: "Event", viewControllerIdentifier: "EventNavigationController")
                }
            } else {
                HUD.flash(.error)
                print(error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    /* ==================================================================================================== */
}
