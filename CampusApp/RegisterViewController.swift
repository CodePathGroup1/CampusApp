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
        if let email = emailField.text, let password = passwordField.text {
            if !email.isEmpty && !password.isEmpty {
                HUD.show(.progress)
                
                guard isValidEmail(email) else {
                    HUD.flash(.label("Invalid email format"))
                    return
                }
                
                let newUser = PFUser()
                newUser.username = email
                newUser.password = password
                
                newUser.signUpInBackground { (success: Bool, error: Error?) in
                    if success {
                        HUD.hide(animated: true)
                        self.showViewController(storyboardIdentifier: "Event", viewControllerIdentifier: "EventNavigationVC")
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
    }
    /* ==================================================================================================== */
    
    /* ====================================================================================================
     MARK: - Private helper methods
     ====================================================================================================== */
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        return result
    }
    /* ==================================================================================================== */
}
