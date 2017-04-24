//
//  ProfileViewController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 4/11/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse
import ParseUI
import PKHUD
import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    @IBOutlet weak var avatarPFImageView: PFImageView!
    
    @IBOutlet weak var usernameField: RoundTextField!
    @IBOutlet weak var currentPasswordField: RoundTextField!
    @IBOutlet weak var newPasswordField: RoundTextField!
    
    @IBOutlet weak var emailField: RoundTextField!
    
    @IBOutlet weak var firstNameField: RoundTextField!
    @IBOutlet weak var lastNameField: RoundTextField!
    
    @IBOutlet weak var phoneNumberField: RoundTextField!
    
    /* ====================================================================================================
     MARK: - Lifecycle Methods
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_arrow"),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationItem.title = "PROFILE"
        
        logoutButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "JosefinSans-Bold", size: 17.0)!,
                                             NSForegroundColorAttributeName: UIColor.white],
                                            for: .normal)
        
        loadCurrentUserProfile()
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Tap Actions
     ====================================================================================================== */
    @IBAction func avatarTapped(_ sender: AnyObject) {
        
    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        if let currentUser = PFUser.current() {
            view.endEditing(true)
            
            if let avatarPFFile = avatarPFImageView.file {
                currentUser[C.Parse.User.Keys.avatar] = avatarPFFile
            }
            
            if let email = emailField.text, !email.isEmpty {
                currentUser[C.Parse.User.Keys.email] = email
            }
            
            if let firstName = firstNameField.text, !firstName.isEmpty {
                currentUser[C.Parse.User.Keys.firstName] = firstName
            }
            
            if let lastName = lastNameField.text, !lastName.isEmpty {
                currentUser[C.Parse.User.Keys.lastName] = lastName
            }
            
            if let phoneNumber = phoneNumberField.text, !phoneNumber.isEmpty {
                currentUser[C.Parse.User.Keys.phoneNumber] = phoneNumber
            }
            
            HUD.show(.progress)
            
            let uiFeedbackBlock = {
                DispatchQueue.main.async {
                    self.loadCurrentUserProfile()
                    
                    HUD.hide(animated: true)
                }
            }
            
            currentUser.saveInBackground { succeeded, error in
                if succeeded {
                    if let enteredCurrentPassword = self.currentPasswordField.text, !enteredCurrentPassword.isEmpty,
                        let newPassword = self.newPasswordField.text, !newPassword.isEmpty {
                        if let username = currentUser.username {
                            PFUser.logInWithUsername(inBackground: username,
                                                     password: enteredCurrentPassword) { user, error in
                                                        if let user = user {
                                                            user.password = newPassword
                                                            user.saveInBackground { succeeded, error in
                                                                if succeeded {
                                                                    PFUser.logOutInBackground { error in
                                                                        if let error = error {
                                                                            UIWindow.showMessage(title: "Error",
                                                                                                 message: error.localizedDescription)
                                                                        } else {
                                                                            self.logout()
                                                                        }
                                                                    }
                                                                } else {
                                                                    HUD.hide(animated: false)
                                                                    UIWindow.showMessage(title: "Error",
                                                                                         message: error?.localizedDescription ?? "Unknown Error")
                                                                }
                                                            }
                                                        } else {
                                                            HUD.hide(animated: false)
                                                            UIWindow.showMessage(title: "Error",
                                                                                 message: "Invalid current password")
                                                        }
                            }
                        } else {
                            uiFeedbackBlock()
                        }
                    } else {
                        uiFeedbackBlock()
                    }
                } else {
                    HUD.hide(animated: false)
                    UIWindow.showMessage(title: "Error",
                                         message: error?.localizedDescription ?? "Unknown Error")
                }
            }
        }
    }
    
    @IBAction func signoutButtonTapped(_ sender: AnyObject) {
        self.logout()
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UITextField Delegate Methods
     ====================================================================================================== */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Private Helper Methods
     ====================================================================================================== */
    private func loadCurrentUserProfile() {
        if let currentUser = PFUser.current() {
            HUD.show(.label("Loading profile..."))
            
            if let avatarPFImageFile = currentUser[C.Parse.User.Keys.avatar] as? PFFile {
                avatarPFImageView.file = avatarPFImageFile
                avatarPFImageView.loadInBackground()
            } else {
                let image = UIImage(named: "profile_blank")
                avatarPFImageView.image = image
            }
            
            usernameField.text = currentUser.username
            
            if let email = currentUser[C.Parse.User.Keys.email] as? String, !email.isEmpty {
                emailField.text = email
            }
            
            if let firstName = currentUser[C.Parse.User.Keys.firstName] as? String, !firstName.isEmpty {
                firstNameField.text = firstName
            }
            
            if let lastName = currentUser[C.Parse.User.Keys.lastName] as? String, !lastName.isEmpty {
                lastNameField.text = lastName
            }
            
            if let phoneNumber = currentUser[C.Parse.User.Keys.phoneNumber] as? String, !phoneNumber.isEmpty {
                phoneNumberField.text = phoneNumber
            }
            
            HUD.hide(animated: true)
        }
    }
    
    private func logout() {
        HUD.show(.progress)
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            PFUser.logOutInBackground { _ in
                DispatchQueue.main.async {
                    self.present(vc, animated: true) {
                        HUD.hide(animated: true)
                    }
                }
            }
        }
    }
    /* ==================================================================================================== */
}
