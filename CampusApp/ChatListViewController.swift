//
//  ChatListViewController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import Parse
import PKHUD

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var conversations: [PFObject] = []
    
    var completion: ((String) -> Void)?
    
    /* ====================================================================================================
     MARK: - Lifecycle Methdos
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UITableView delegation
        tableView.dataSource = self
        tableView.delegate = self
        
        // Associate EventCell xib to this table view
        let nib = UINib(nibName: "ChatCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: C.Identifier.Cell.chatCell)
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadConversations()
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Segue
     ====================================================================================================== */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == C.Identifier.Segue.chatConversationViewController.old {
                if let vc = segue.destination as? ChatConversationViewController {
                    if let indexPath = sender as? IndexPath {
                        vc.conversation = conversations[indexPath.row]
                        vc.completion = { conversation in
                            self.conversations[indexPath.row] = conversation
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }
                    }
                }
            } else if identifier == C.Identifier.Segue.chatConversationViewController.new {
                if let vc = segue.destination as? ChatUserSearchViewController {
                    vc.completion = { conversation in
                        self.conversations.append(conversation)
                        
                        
                        if self.conversations.count == 1 {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        } else {
                            let indexPath = IndexPath(row: self.conversations.count - 1, section: 0)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }
                    }
                }
            }
        }
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UITableView Delegate Methods
     ====================================================================================================== */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: C.Identifier.Cell.chatCell, for: indexPath) as? ChatCell {
            let conversation = conversations[indexPath.row]
            cell.bindData(with: conversation)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: C.Identifier.Segue.chatConversationViewController.old, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Helper Methods
     ====================================================================================================== */
    private func loadConversations() {
        if let currentUser = PFUser.current() {
            let query = PFQuery(className: C.Parse.Conversation.className)
            query.whereKey(C.Parse.Conversation.Keys.users, containsAllObjectsIn: [currentUser])
            query.includeKey(C.Parse.Conversation.Keys.lastMessage)
            query.includeKey(C.Parse.Conversation.Keys.lastUser)
            query.order(byDescending: C.Parse.Conversation.Keys.lastMessageTimestamp)
            query.findObjectsInBackground { pfObjects, error in
                if let pfObjects = pfObjects {
                    self.conversations = pfObjects
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    HUD.flash(.label(error?.localizedDescription ?? "Network error"))
                }
            }
        }
    }
    /* ==================================================================================================== */
}
