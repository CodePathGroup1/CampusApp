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

class RegisterVC: UIViewController {

    @IBOutlet weak var usernameField: RoundTextField!
    @IBOutlet weak var passwordField: RoundTextField!
    
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
            HUD.show(.progress)
            
            let newUser = PFUser()
            newUser.username = username
            newUser.password = password
            
            newUser.signUpInBackground { (success: Bool, error: Error?) in
                if success {
                    HUD.hide(animated: true)
                    self.showViewController(storyboardIdentifier: "Main", viewControllerIdentifier: "EventNavigationVC")
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
    /* ==================================================================================================== */
}
