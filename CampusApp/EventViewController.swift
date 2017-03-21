//
//  ViewController.swift
//  CampusApp
//
//  Created by Aristotle on 2017-02-27.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoogleCalendarClient.shared.getPublicEvents(calendarID: "mail.ccsf.edu_2o3osj4laq9iapttl8tpc5igbc@group.calendar.google.com",
                                                    success: { json in
                                                        print(json)
                                                        print("succeeded")
        },
                                                    failure: { error in
                                                        print(error)
        })
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        
        return cell
    }

}

