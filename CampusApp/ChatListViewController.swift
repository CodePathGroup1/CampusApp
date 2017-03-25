//
//  ChatListViewController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import Parse

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let conversations: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Associate EventCell xib to this table view
        let nib = UINib(nibName: "ChatCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ChatCell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
}
