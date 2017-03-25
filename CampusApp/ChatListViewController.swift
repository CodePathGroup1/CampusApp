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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadConversations()
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Segue
     ====================================================================================================== */
    @IBAction func newConversationButtonPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: C.Identifier.Segue.chatConversationViewController, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == C.Identifier.Segue.chatConversationViewController {
            if let vc = segue.destination as? ChatConversationViewController {
                if let conversationID = sender as? String {
                    vc.conversationID = conversationID
                } else {
                    vc.conversationID = nil
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
        let conversation = conversations[indexPath.row]
        if let conversationID = conversation.objectId {
            performSegue(withIdentifier: C.Identifier.Segue.chatConversationViewController, sender: conversationID)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Helper Methods
     ====================================================================================================== */
    private func loadConversations() {
        let query = PFQuery(className: C.Parse.Conversation.className)
        query.whereKey(C.Parse.Conversation.Keys.user, equalTo: PFUser.current())
        query.includeKey(C.Parse.Conversation.Keys.lastUser)
        query.order(byDescending: C.Parse.Conversation.Keys.lastMessageTimestamp)
        query.findObjectsInBackground { pfObjects, error in
            if let pfObjects = pfObjects {
                self.conversations = pfObjects
                self.tableView.reloadData()
            } else {
                HUD.flash(.label(error?.localizedDescription ?? "Network error"))
            }
        }
        
    }
    /* ==================================================================================================== */
}
