//
//  LoginVC.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import FacebookCore
import FacebookLogin
import Parse
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
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile, .email], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                HUD.flash(.label(error.localizedDescription))
            case .cancelled:
                break  // Do nothing
            case .success(_, _, let accessToken):
                let request = GraphRequest(graphPath: "me",
                                           parameters: ["fields": "email,first_name,last_name"],
                                           accessToken: accessToken,
                                           httpMethod: .GET,
                                           apiVersion: GraphAPIVersion.defaultVersion)
                request.start { response, result in
                    switch result {
                    case .success(let response):
                        guard
                            let dictionary = response.dictionaryValue,
                            let username = dictionary["email"] as? String else {
                                fatalError("Request user data failed")
                        }
                        
                        let query = PFQuery(className: C.Parse.User.className)
                        query.whereKey(C.Parse.User.Keys.username, equalTo: username)
                        query.limit = 1
                        query.findObjectsInBackground { pfObjects, error in
                            if let pfUser = pfObjects?.first as? PFUser {
                                pfUser.password = accessToken.authenticationToken
                                pfUser.saveInBackground { succeeded, error in
                                    if succeeded {
                                        self.showViewController(storyboardIdentifier: "Event", viewControllerIdentifier: "EventNavigationController")
                                    } else {
                                        HUD.flash(.label(error?.localizedDescription ?? "Unknown error"))
                                    }
                                }
                                
                            } else {
                                let newUser = PFUser()
                                newUser.username = username
                                newUser.password = accessToken.authenticationToken
                                
                                let fullName: String = {
                                    var nameParts: [String] = []
                                    if let firstName = dictionary["first_name"] as? String {
                                        nameParts.append(firstName)
                                    }
                                    if let lastName = dictionary["last_name"] as? String {
                                        nameParts.append(lastName)
                                    }
                                    return nameParts.joined(separator: " ")
                                }()
                                
                                newUser[C.Parse.User.Keys.fullName] = (fullName.isEmpty ? username : fullName)
                                
                                newUser.signUpInBackground { (success: Bool, error: Error?) in
                                    if success {
                                        self.showViewController(storyboardIdentifier: "Event", viewControllerIdentifier: "EventNavigationController")
                                    } else if let error = error as? NSError {
                                        switch error.code {
                                        case 202:
                                            HUD.flash(.label("User name is taken"))
                                        default:
                                            HUD.flash(.error)
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                                
                            }
                        }
                    case .failed(let error):
                        HUD.flash(.label(error.localizedDescription))
                    }
                }
            }
        }
    }
    /* ==================================================================================================== */
}
