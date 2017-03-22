//
//  ViewController.swift
//  CampusApp
//
//  Created by Aristotle on 2017-02-27.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import Parse
import PKHUD

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var events: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up tableView delegation
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Associate EventCell xib to this table view
        let nib = UINib(nibName: "EventCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "EventCell")
        
        loadEvents()
    }
    
    @IBAction func logoutButtonTapped(_ sender: AnyObject) {
        HUD.flash(.progress)
        
        PFUser.logOutInBackground { _ in
            self.dismiss(animated: true) {
                HUD.hide(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventCell {
            let event = events[indexPath.row]
            
            func configure(label: UILabel, content: String?) {
                if let content = content, !content.isEmpty {
                    label.isHidden = false
                    label.text = content
                } else {
                    label.isHidden = true
                }
            }
            
            configure(label: cell.titleLabel, content: event.summary)
            configure(label: cell.startDateTimeLabel, content: event.startDateTime?.shortDateTimeFormat)
            configure(label: cell.detailLabel, content: event.description)
            
            return cell
        }
        
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EventDetailViewController", sender: events[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "EventDetailViewController" {
            if let event = sender as? Event {
                if let destinationVC = segue.destination as? EventDetailViewController {
                    destinationVC.event = event
                }
            }
        }
    }
    
    private func loadEvents() {
        var loadedCalendarCount = 0
        let totalCalendarCount = GoogleCalendarClient.calendarIDs.count
        HUD.flash(.label("Loading: \(loadedCalendarCount / totalCalendarCount) %"))
        
        for calendarID in GoogleCalendarClient.calendarIDs {
            GoogleCalendarClient.shared.getPublicEvents(calendarID: calendarID,
                                                        success: { json in
                                                            loadedCalendarCount += 1
                                                            HUD.flash(.label("Loading: \(loadedCalendarCount / totalCalendarCount) %"))
                                                            
                                                            let newEvents = json.map { eventJSON -> Event in
                                                                return Event(json: eventJSON)
                                                            }.filter { event -> Bool in  // Filter out repeat events
                                                                return event.startDateTime != nil
                                                            }
                                                            
                                                            self.events.append(contentsOf: newEvents)
                                                            
                                                            if loadedCalendarCount == totalCalendarCount {
                                                                self.events.sort(by: { (event1, event2) -> Bool in
                                                                    return event1.startDateTime!.timeIntervalSinceNow < event2.startDateTime!.timeIntervalSinceNow
                                                                })
                                                                self.tableView.reloadData()
                                                                HUD.hide(animated: true)
                                                            }},
                                                        failure: { error in
                                                            print(error) }
            )
        }
    }
}

