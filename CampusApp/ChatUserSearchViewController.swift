//
//  ChatUserSearchViewController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/25/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse
import PKHUD
import UIKit

class ChatUserSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var originalLoadedUsers = [PFUser]()
    private var filteredUsers = [PFUser]()
    
    var completion: ((PFObject) -> Void)?
    
    /* ====================================================================================================
     MARK: - Lifecycle Methods
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_arrow"),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationItem.title = "SEARCH USER"
        
        self.searchBar.delegate = self
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.estimatedRowHeight = 46
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.loadUsers()
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UISearchBar Delegate Methods
     ====================================================================================================== */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            filteredUsers = originalLoadedUsers.filter { pfUser -> Bool in
                let fullName: String? = {
                    if let fullName = pfUser[C.Parse.User.Keys.fullName] as? String, !fullName.isEmpty {
                        return fullName
                    } else if let username = pfUser.username, !username.isEmpty {
                        return username
                    } else if let objectId = pfUser.objectId {
                        return objectId
                    }
                    return nil
                }()
                
                return (fullName?.lowercased().range(of: searchText.lowercased()) != nil)
            }
        } else {
            filteredUsers = originalLoadedUsers
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        filteredUsers = originalLoadedUsers
        tableView.reloadData()
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UITableView Delegate Methods
     ====================================================================================================== */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: C.Identifier.Cell.chatUserCell, for: indexPath) as? ChatUserCell {
            cell.bindData(pfUser: filteredUsers[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let otherUsers = [filteredUsers[indexPath.row]]
        
        HUD.show(.label("Loading conversation..."))
        
        Conversation.startConversation(otherUsers: otherUsers) { conversation in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: C.Identifier.Segue.chatConversationViewController.new, sender: conversation)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Segues
     ====================================================================================================== */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == C.Identifier.Segue.chatConversationViewController.new {
                if let vc = segue.destination as? ChatConversationViewController {
                    if let conversation = sender as? PFObject {
                        vc.conversation = conversation
                        vc.completion = completion
                        
                        HUD.hide(animated: true)
                    }
                }
            }
        }
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Private Helper Methods
     ====================================================================================================== */
    private func loadUsers() {
        if let currentUser = PFUser.current(), let currentUsername = currentUser.username {
            HUD.show(.label("Loading users..."))
            
            let query = PFQuery(className: C.Parse.User.className)
            query.whereKey(C.Parse.User.Keys.username, notEqualTo: currentUsername)
            query.order(byAscending: C.Parse.User.Keys.fullName)
            query.findObjectsInBackground { pfObjects, error in
                if let pfObjects = pfObjects as? [PFUser] {
                    self.originalLoadedUsers = pfObjects
                    self.filteredUsers = pfObjects
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                        HUD.hide(animated: true)
                    }
                } else {
                    HUD.hide(animated: false)
                    UIWindow.showMessage(title: "Error",
                                         message: error?.localizedDescription ?? "Network Error")
                }
            }
        }
    }
    /* ==================================================================================================== */
}
