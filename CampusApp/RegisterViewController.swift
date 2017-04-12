//
//  RegisterVC.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import Parse
import PKHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailField: RoundTextField!
    @IBOutlet weak var usernameField: RoundTextField!
    @IBOutlet weak var passwordField: RoundTextField!
    @IBOutlet weak var firstNameField: RoundTextField!
    @IBOutlet weak var lastNameField: RoundTextField!
    @IBOutlet weak var phoneNumberField: RoundTextField!
    
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
    
    
    /* ====================================================================================================
     MARK: - Register new account
     ====================================================================================================== */
    @IBAction func registerButtonTapped(_ sender: AnyObject) {
        if let username = usernameField.text, let password = passwordField.text {
            if !username.isEmpty && !password.isEmpty {
                HUD.show(.progress)
                
                let newUser = PFUser()
                newUser.username = username
                newUser.password = password
                
                if let email = emailField.text, !email.isEmpty {
                    if isValidEmail(email) {
                        newUser[C.Parse.User.Keys.email] = emailField.text
                    } else {
                        HUD.hide(animated: false)
                        UIWindow.showMessage(title: "Error",
                                             message: "Invalid email format")
                        return
                    }
                }
                
                if let image = UIImage(named: "profile_blank"),
                    let data = UIImageJPEGRepresentation(image, 0.6),
                    let file = PFFile(name: "picture.jpg", data: data) {
                    
                    newUser[C.Parse.User.Keys.avatar] = file
                }
                
                newUser[C.Parse.User.Keys.firstName] = firstNameField.text
                newUser[C.Parse.User.Keys.lastName] = lastNameField.text
                
                if let firstName = firstNameField.text, let lastName = lastNameField.text {
                    newUser[C.Parse.User.Keys.fullName] = (firstName + " " + lastName).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                newUser[C.Parse.User.Keys.phoneNumber] = phoneNumberField.text
                
                newUser.signUpInBackground { (success: Bool, error: Error?) in
                    if success {
                        DispatchQueue.main.async {
                            let vc = MainTabBarController()
                            self.present(vc, animated: true) {
                                HUD.hide(animated: true)
                            }
                        }
                    } else if let error = error as? NSError {
                        HUD.hide(animated: false)
                        
                        switch error.code {
                        case 202:
                            UIWindow.showMessage(title: "Error",
                                                 message: error.localizedDescription)
                        default:
                            UIWindow.showMessage(title: "Error",
                                                 message: error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Private helper methods
     ====================================================================================================== */
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    /* ==================================================================================================== */
}
