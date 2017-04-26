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
    
    var newMessageReceived = false {
        didSet {
            if presentationController?.presentedViewController is ChatListViewController && newMessageReceived {
                loadConversations()
            }
        }
    }
    
    /* ====================================================================================================
     MARK: - Lifecycle Methdos
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_arrow"),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationItem.title = "CHAT"
        
        // UITableView delegation
        tableView.dataSource = self
        tableView.delegate = self
        
        // Associate EventCell xib to this table view
        let nib = UINib(nibName: "ChatCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: C.Identifier.Cell.chatCell)
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentationController?.presentedViewController is ChatListViewController && newMessageReceived {
            loadConversations()
        }
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
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            } else if identifier == C.Identifier.Segue.chatConversationViewController.new {
                if let vc = segue.destination as? ChatUserSearchViewController {
                    vc.completion = { conversation in
                        if self.conversations.index(where: { return $0.objectId == conversation.objectId }) == nil {
                            self.conversations.append(conversation)
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
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
    func loadConversations() {
        if let currentUser = PFUser.current() {
            if presentationController?.presentedViewController is ChatListViewController {
                HUD.show(.label("Loading chat..."))
            }
            
            let query = PFQuery(className: C.Parse.Conversation.className)
            query.whereKey(C.Parse.Conversation.Keys.users, containsAllObjectsIn: [currentUser])
            query.includeKeys([C.Parse.Conversation.Keys.lastMessage, C.Parse.Conversation.Keys.lastUser])
            query.order(byDescending: C.Parse.Conversation.Keys.lastMessageTimestamp)
            query.findObjectsInBackground { pfObjects, error in
                if let pfObjects = pfObjects {
                    self.conversations = pfObjects.reduce([]) { result, conversation in
                        if let _ = conversation[C.Parse.Conversation.Keys.lastUser] {
                            return result + [conversation]
                        } else {
                            conversation.deleteInBackground()
                            return result
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.isHidden = self.conversations.isEmpty
                        self.tableView.reloadData()
                        
                        self.newMessageReceived = false
                        
                        HUD.hide(animated: true)
                    }
                } else {
                    HUD.hide(animated: false)
                    UIWindow.showMessage(title: "Error",
                                         message: error?.localizedDescription ?? "Network error")
                }
            }
        }
    }
    /* ==================================================================================================== */
}
