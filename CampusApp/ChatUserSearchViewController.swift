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
    
    private var originalLoadedUsers = [User]()
    private var filteredUsers = [User]()
    
    
    /* ====================================================================================================
     MARK: - Lifecycle Methods
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.estimatedRowHeight = 76
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.loadUsers()
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UISearchBar Delegate Methods
     ====================================================================================================== */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            filteredUsers = originalLoadedUsers.filter { user -> Bool in
                if let fullName = user.fullName {
                    return (fullName.range(of: searchText) == nil)
                }
                return false
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
            cell.bindData(user: filteredUsers[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let otherUsers = [filteredUsers[indexPath.row]]
        
        Conversation.startConversation(otherUsers: otherUsers) { conversationID in
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ChatConversationViewController") as? ChatConversationViewController {
                vc.conversationID = conversationID
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Private Helper Methods
     ====================================================================================================== */
    private func loadUsers() {
        if let currentUser = PFUser.current(), let currentUsername = currentUser.username {
            let query = PFQuery(className: C.Parse.User.className)
            query.whereKey(C.Parse.User.Keys.username, notEqualTo: currentUsername)
            query.order(byAscending: C.Parse.User.Keys.fullName)
            query.findObjectsInBackground { pfObjects, error in
                if let pfObjects = pfObjects as? [PFUser] {
                    self.originalLoadedUsers = pfObjects.map { pfObject in
                        return User(pfObject: pfObject)
                    }
                    self.filteredUsers = self.originalLoadedUsers
                    self.tableView.reloadData()
                } else {
                    HUD.flash(.label(error?.localizedDescription ?? "Network error"))
                }
            }
        }
    }
    /* ==================================================================================================== */
}
