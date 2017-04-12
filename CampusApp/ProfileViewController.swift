//
//  ProfileViewController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 4/11/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse
import ParseUI
import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var avatarPFImageView: PFImageView!
    
    @IBOutlet weak var usernameField: RoundTextField!
    @IBOutlet weak var currentPasswordField: RoundTextField!
    @IBOutlet weak var newPasswordField: RoundTextField!
    
    @IBOutlet weak var emailField: RoundTextField!
    
    @IBOutlet weak var firstNameField: RoundTextField!
    @IBOutlet weak var lastNameField: RoundTextField!
    
    @IBOutlet weak var phoneNumberField: RoundTextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    /* ====================================================================================================
     MARK: - Lifecycle Methods
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Button Actions
     ====================================================================================================== */
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        
    }
    
    @IBAction func avatarTapped(_ sender: AnyObject) {
        
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UITableView Delegate Methods
     ====================================================================================================== */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Private Helper Methods
     ====================================================================================================== */
    private func loadCurrentUserProfile() {
        
    }
    /* ==================================================================================================== */
}
