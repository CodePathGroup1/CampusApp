//
//  AttendeeListViewController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 4/9/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse
import ParseUI
import PKHUD
import UIKit

class AttendeeListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var event: ParseEvent!
    
    private var attendees: [PFUser] = []
    
    /* ====================================================================================================
     MARK: - Lifecycle Methods
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up tableView delegation
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 46
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Associate EventCell xib to this table view
        let nib = UINib(nibName: "UserCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "UserCell")
        
        loadAttendees()
    }
    /* ==================================================================================================== */

    
    /* ====================================================================================================
     MARK: - TableView Delegate Methods
     ====================================================================================================== */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell {
            let attendee = attendees[indexPath.row]
            cell.bindData(with: attendee)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let attendee = attendees[indexPath.row]
        
        if let currentUser = PFUser.current(), currentUser.objectId != attendee.objectId {
            Conversation.startConversation(otherUsers: [attendee]) { conversation in
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "ChatConversationViewController") as? ChatConversationViewController {
                        vc.conversation = conversation
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendees.count
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Private Helper Methods
     ====================================================================================================== */
    private func loadAttendees() {
        HUD.flash(.progress)
        
        if let relation = event.pfObject?.relation(forKey: C.Parse.Event.Keys.attendees) {
            if let query = relation.query() as? PFQuery<PFUser> {
                query.findObjectsInBackground { pfUsers, error in
                    if let pfUsers = pfUsers {
                        self.attendees = pfUsers
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            HUD.hide(animated: true)
                        }
                    } else {
                        HUD.flash(.label(error?.localizedDescription ?? "Failed to retrieve attendees"))
                    }
                }
            }
        }
    }
    /* ==================================================================================================== */
}
