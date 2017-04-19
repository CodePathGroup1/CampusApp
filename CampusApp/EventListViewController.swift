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

class EventListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var events: [ParseEvent] = []
    
    
    /* ====================================================================================================
     MARK: - Lifecycle Methods
     ====================================================================================================== */
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
        
        self.loadEvents()
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Button Handlers
     ====================================================================================================== */
    @IBAction func addEventButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "EditEventViewController_NEW", sender: nil)
    }
    
    func favoriteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        events[index].favorite { parseEvent in
            if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EventCell {
                DispatchQueue.main.async {
//                    let image = UIImage(named: (self.events[index].isFavorited ? "favorited" : "not-favorited"))
//                    cell.favoriteButton.setImage(image, for: .normal)
                    cell.favoriteButton.isSelected = (self.events[index].isFavorited)

                    HUD.hide(animated: true)
                }
            }
        }
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - TableView Delegate Methods
     ====================================================================================================== */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let event = events[indexPath.row]
        return (event.organizer?.objectId == PFUser.current()?.objectId && event.googleEventID == nil)
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
            
            cell.favoriteButton.isSelected = event.isFavorited
            cell.favoriteButton.tag = indexPath.row
            cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let event = events[indexPath.row]
            event.pfObject?.deleteInBackground { succeed, error in
                self.events.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.tableView.reloadData()     // Reload target-action for all favorite buttons
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EventDetailViewController", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Segue
     ====================================================================================================== */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "EventDetailViewController" {
                if let destinationVC = segue.destination as? EventDetailViewController {
                    if let indexPath = sender as? IndexPath {
                        destinationVC.completionHandler = { parseEvent in
                            self.events[indexPath.row] = parseEvent
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                            }
                        }
                        destinationVC.event = events[indexPath.row]
                    }
                }
            } else if identifier == "EditEventViewController_NEW" {
                if let destinationVC = segue.destination as? EditEventViewController {
                    destinationVC.mode = .New
                    destinationVC.completionHandler = { parseEvent in
                        self.events.append(parseEvent)
                        self.events.sort(by: { (event1, event2) -> Bool in
                            return event1.startDateTime!.timeIntervalSinceNow < event2.startDateTime!.timeIntervalSinceNow
                        })
                        
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
     MARK: - Load Events
     ====================================================================================================== */
    // Starter Method
    private func loadEvents() {
        HUD.show(.progress)
        loadGoogleEvents()
    }
    
    // Step 1: Load Google Events from Google Calendar API
    private func loadGoogleEvents() {
        var loadedCalendarCount = 0
        let totalCalendarCount = GoogleCalendarClient.calendarIDs.count
        
        for calendarID in GoogleCalendarClient.calendarIDs {
            GoogleCalendarClient.shared.getPublicEvents(calendarID: calendarID,
                                                        success: { json in
                                                            loadedCalendarCount += 1
                                                            
                                                            HUD.show(.label("Loading events..."))
                                                            
                                                            let newEvents: [ParseEvent] = json.map { eventJSON -> GoogleCalendarEvent in
                                                                return GoogleCalendarEvent(json: eventJSON)
                                                                }.filter { event -> Bool in  // Filter out repeat events
                                                                    return event.startDateTime != nil
                                                            }
                                                            
                                                            self.events.append(contentsOf: newEvents)
                                                            
                                                            if loadedCalendarCount == totalCalendarCount {
                                                                // Go to Step 2
                                                                self.loadParseEvents()
                                                            }},
                                                        failure: { error in
                                                            print(error) }
            )
        }
    }
    
    // Step 2: Load Events from Parse
    private func loadParseEvents() {
        let query = PFQuery(className: C.Parse.Event.className)
        query.whereKey(C.Parse.Event.Keys.startDateTime, lessThanOrEqualTo: Calendar.current.date(byAdding: .month, value: 1, to: Date())!)
        query.includeKeys([C.Parse.Event.Keys.organizer,
                           C.Parse.Event.Keys.attendees, 
                           C.Parse.Event.Keys.campus,
                           C.Parse.Event.Keys.building,
                           C.Parse.Event.Keys.room])
        
        query.findObjectsInBackground { pfObjects, error in
            if let pfObjects = pfObjects {
                let parseEvents = pfObjects.map { pfObject in
                    return ParseEvent(pfObject: pfObject)
                }
                
                // Go to Step 3
                self.associateGoogleEvents(with: parseEvents)
            }
            
            // Go to Step 3
            self.associateGoogleEvents(with: [])
        }
    }
    
    // Step 3: Link Google Events to corresponding Parse Event Objects (if any)
    private func associateGoogleEvents(with parseEvents: [ParseEvent]) {
        
        for parseEvent in parseEvents {
            if let googleEventID = parseEvent.googleEventID {
                let index = self.events.index { event -> Bool in
                    return (event.googleEventID == googleEventID)
                }
                
                if let index = index {
                    self.events[index] = parseEvent
                }
            } else {
                self.events.append(parseEvent)
            }
        }
        
        // Go to Step 4
        self.loadFavoriteStatus()
    }
    
    // Step 4: Query current user's favorited events and update ParseEvent objects
    private func loadFavoriteStatus() {
        if let currentUser = PFUser.current() {
            let relation = currentUser.relation(forKey: C.Parse.User.Keys.favoritedPFObjects)
            let query = relation.query()
            query.findObjectsInBackground { pfObjects, error in
                if let pfObjects = pfObjects {
                    let favoritedParseEventIDs: [String] = pfObjects.reduce([]) { result, pfObject in
                        if let objectId = pfObject.objectId {
                            return result + [objectId]
                        }
                        return result
                    }
                    
                    let favoritedParseEvents = self.events.filter { event in
                        if let objectId = event.pfObject?.objectId {
                            return favoritedParseEventIDs.contains(objectId)
                        }
                        return false
                    }
                    
                    for favoritedParseEvent in favoritedParseEvents {
                        favoritedParseEvent.isFavorited = true
                    }
                    
                    // Go to Step 5
                    self.loadRSVPStatus()
                } else {
                    HUD.hide(animated: false)
                    UIWindow.showMessage(title: "Error",
                                         message: error?.localizedDescription ?? "Getting favorite status failed")
                }
            }
        }
    }
    
    // Step 5: Query current user's RSVPed events and update ParseEvent objects
    private func loadRSVPStatus() {
        if let currentUser = PFUser.current() {
            let relation = currentUser.relation(forKey: C.Parse.User.Keys.rsvpEvents)
            let query = relation.query()
            query.findObjectsInBackground { pfObjects, error in
                if let pfObjects = pfObjects {
                    let rsvpedParseEventIDs: [String] = pfObjects.reduce([]) { result, pfObject in
                        if let objectId = pfObject.objectId {
                            return result + [objectId]
                        }
                        return result
                    }
                    
                    let rsvpedParseEvents = self.events.filter { event in
                        if let objectId = event.pfObject?.objectId {
                            return rsvpedParseEventIDs.contains(objectId)
                        }
                        return false
                    }
                    
                    for rsvpedParseEvent in rsvpedParseEvents {
                        rsvpedParseEvent.isRVSPed = true
                    }
                    
                    // Go to FINAL step
                    self.reloadEvents()
                } else {
                    HUD.hide(animated: false)
                    UIWindow.showMessage(title: "Error",
                                         message: error?.localizedDescription ?? "Getting favorite status failed")
                }
            }
        }
    }
    
    // FINAL Step: Reload Table View
    private func reloadEvents() {
        self.events.sort(by: { (event1, event2) -> Bool in
            return event1.startDateTime!.timeIntervalSinceNow < event2.startDateTime!.timeIntervalSinceNow
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        
            HUD.hide(animated: true)
        }
    }
    /* ==================================================================================================== */
}
