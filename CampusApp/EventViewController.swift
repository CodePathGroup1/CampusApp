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
    
    private var events: [ParseEvent] = []
    
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
        
        // TODO: Remove this
//        createSampleData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    // TODO: Remove this
    private func createSampleData() {
        var pfObject: PFObject
            
        pfObject = PFObject(className: "Campus")
        pfObject["name"] = "Chinatown"
        pfObject.saveInBackground()
        
        pfObject = PFObject(className: "Campus")
        pfObject["name"] = "Ocean"
        pfObject.saveInBackground()
        
        pfObject = PFObject(className: "Building")
        pfObject["campus_id"] = "rhex3QYTkA"     // Chinatown
        pfObject["name"] = "Ni Hao"
        pfObject.saveInBackground()
        
        pfObject = PFObject(className: "Building")
        pfObject["campus_id"] = "qOWe1AWNnZ"     // Ocean
        pfObject["name"] = "Cloud"
        pfObject.saveInBackground()
    }
    
    @IBAction func logoutButtonTapped(_ sender: AnyObject) {
        HUD.flash(.progress)
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            self.present(vc, animated: true) {
                PFUser.logOutInBackground { _ in
                    HUD.hide(animated: true)
                }
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
            
            configure(label: cell.titleLabel, content: event.title)
            configure(label: cell.startDateTimeLabel, content: event.startDateTime?.shortDateTimeFormat)
            configure(label: cell.endDateTimeLabel, content: event.endDateTime?.shortDateTimeFormat)
            configure(label: cell.detailLabel, content: event.description)
            
            if let isFavorited = event.isFavorited {
                let image = UIImage(named: (isFavorited ? "favorited" : "not-favorited"))
                cell.favoriteButton.setImage(image, for: .normal)
            } else {
                let image = UIImage(named: "not-favorited")
                cell.favoriteButton.setImage(image, for: .normal)
            }
            cell.favoriteButton.tag = indexPath.row
            cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
            
            return cell
        }
        
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EventDetailViewController", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func favoriteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        events[index].favorite { parseEvent in
            if let parseEvent = parseEvent {
                if let isFavorited = parseEvent.isFavorited {
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EventCell {
                        let image = UIImage(named: (isFavorited ? "favorited" : "not-favorited"))
                        cell.favoriteButton.setImage(image, for: .normal)
                        
                        self.events[index] = parseEvent
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "EventDetailViewController" {
                if let destinationVC = segue.destination as? EventDetailViewController {
                    if let indexPath = sender as? IndexPath {
                        destinationVC.completionHandler = { parseEvent in
                            self.events[indexPath.row] = parseEvent
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                        destinationVC.event = events[indexPath.row]
                    }
                }
            } else if identifier == "NewEventViewController" {
                if let destinationVC = segue.destination as? NewEventViewController {
                    destinationVC.completion = { parseEvent in
                        self.events.append(parseEvent)
                        self.events.sort(by: { (event1, event2) -> Bool in
                            return event1.startDateTime!.timeIntervalSinceNow < event2.startDateTime!.timeIntervalSinceNow
                        })
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func loadEvents() {
        loadGoogleEvents()
        loadParseEvents()
    }
    
    enum ProcessType {
        case loadGoogleEvents, loadParseEvents, associateGoogleEvents
    }
    
    var backgroundProcesses: [ProcessType: Bool] = [
        .loadGoogleEvents: false,
        .loadParseEvents: false,
        .associateGoogleEvents: false
    ] {
        didSet {
            if !backgroundProcesses.values.contains(false) {
                self.events.sort(by: { (event1, event2) -> Bool in
                    return event1.startDateTime!.timeIntervalSinceNow < event2.startDateTime!.timeIntervalSinceNow
                })
                self.tableView.reloadData()
                HUD.hide(animated: true)
            }
        }
    }
    
    private func loadGoogleEvents() {
        var loadedCalendarCount = 0
        let totalCalendarCount = GoogleCalendarClient.calendarIDs.count
        HUD.flash(.label("Loading: \(loadedCalendarCount / totalCalendarCount) %"))
        
        for calendarID in GoogleCalendarClient.calendarIDs {
            GoogleCalendarClient.shared.getPublicEvents(calendarID: calendarID,
                                                        success: { json in
                                                            loadedCalendarCount += 1
                                                            HUD.flash(.label("Loading: \(loadedCalendarCount / totalCalendarCount) %"))
                                                            
                                                            let newEvents: [ParseEvent] = json.map { eventJSON -> GoogleCalendarEvent in
                                                                return GoogleCalendarEvent(json: eventJSON)
                                                                }.filter { event -> Bool in  // Filter out repeat events
                                                                    return event.startDateTime != nil
                                                            }
                                                            
                                                            self.events.append(contentsOf: newEvents)
                                                            
                                                            if loadedCalendarCount == totalCalendarCount {
                                                                self.backgroundProcesses[.loadGoogleEvents] = true
                                                            }},
                                                        failure: { error in
                                                            print(error) }
            )
        }
    }
    
    private func loadParseEvents() {
        let query = PFQuery(className: C.Parse.Event.className)
        query.whereKey(C.Parse.Event.Keys.startDateTime, lessThanOrEqualTo: Calendar.current.date(byAdding: .day, value: 14, to: Date())!)
        query.includeKey(C.Parse.Event.Keys.organizer)
        query.includeKey(C.Parse.Event.Keys.campus)
        query.includeKey(C.Parse.Event.Keys.building)
        query.includeKey(C.Parse.Event.Keys.room)
        
        query.findObjectsInBackground { pfObjects, error in
            if let pfObjects = pfObjects {
                let parseEvents = pfObjects.map { pfObject in
                    return ParseEvent(pfObject: pfObject)
                }
                self.backgroundProcesses[.loadParseEvents] = true
                
                self.associateGoogleEvents(with: parseEvents)
            }
        }
    }
    
    private func associateGoogleEvents(with parseEvents: [ParseEvent]) {
        var nonAssociatedParseEvents: [ParseEvent] = []
        
        for parseEvent in parseEvents {
            if let googleEventID = parseEvent.googleEventID {
                let foundGoogleEvent: ParseEvent? = {
                    for googleEvent in self.events {
                        if googleEvent.googleEventID == googleEventID {
                            return googleEvent
                        }
                    }
                    return nil
                }()
                
                if let foundGoogleEvent = foundGoogleEvent {
                    parseEvent.pfObject = foundGoogleEvent.pfObject
                }
                
            } else {
                nonAssociatedParseEvents.append(parseEvent)
                
            }
        }
        
        self.events.append(contentsOf: nonAssociatedParseEvents)
        
        self.backgroundProcesses[.associateGoogleEvents] = true
    }
}
