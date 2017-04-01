//
//  NewEventViewController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/31/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import Parse
import PKHUD

class NewEventViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var titleTextField: RoundTextField!
    @IBOutlet weak var startDateTimeTextField: RoundTextField!
    @IBOutlet weak var endDateTimeTextField: RoundTextField!
    @IBOutlet weak var campusTextField: RoundTextField!
    @IBOutlet weak var buildingTextField: RoundTextField!
    @IBOutlet weak var roomTextField: RoundTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    private var startDateTime: Date?
    private var endDateTime: Date?
    private var campus: PFObject? {
        didSet {
            if campus?.objectId != oldValue?.objectId {
                building = nil
                room = nil
            }
            
            if campus == nil {
                campusTextField.text = ""
            }
        }
    }
    private var building: PFObject? {
        didSet {
            if building?.objectId != oldValue?.objectId {
                room = nil
            }
            
            if building == nil {
                buildingTextField.text = ""
            }
        }
    }
    private var room: PFObject? {
        didSet {
            if room == nil {
                roomTextField.text = ""
            }
        }
    }
    
    var completion: ((ParseEvent) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startDateTimeTextField.delegate = self
        startDateTimeTextField.tag = EventDetailPickerViewController.Mode.startDateTime.rawValue
        
        endDateTimeTextField.delegate = self
        endDateTimeTextField.tag = EventDetailPickerViewController.Mode.endDateTime.rawValue
        
        campusTextField.delegate = self
        campusTextField.tag = EventDetailPickerViewController.Mode.campus.rawValue
        
        buildingTextField.delegate = self
        buildingTextField.tag = EventDetailPickerViewController.Mode.building.rawValue
        
        roomTextField.delegate = self
        roomTextField.tag = EventDetailPickerViewController.Mode.room.rawValue
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard
            let title = titleTextField.text, !title.isEmpty,
            let startDateTime = startDateTime,
            let endDateTime = endDateTime
        else {
            HUD.flash(.label("Missing content in required field(s)"))
            return
        }
        
        let eventPFObject = PFObject(className: C.Parse.Event.className)
        
        eventPFObject[C.Parse.Event.Keys.title] = title
        
        if let currentUser = PFUser.current() {
            eventPFObject[C.Parse.Event.Keys.organizer] = currentUser
            
            if let fullName = currentUser[C.Parse.User.Keys.fullName] as? String {
                eventPFObject[C.Parse.Event.Keys.organizerName] = fullName
            }
        }
        
        eventPFObject[C.Parse.Event.Keys.startDateTime] = startDateTime
        eventPFObject[C.Parse.Event.Keys.endDateTime] = endDateTime
        
        if let campus = campus {
            eventPFObject[C.Parse.Event.Keys.campus] = campus
        }
        
        if let building = building {
            eventPFObject[C.Parse.Event.Keys.building] = building
        }
        
        if let room = room {
            eventPFObject[C.Parse.Event.Keys.room] = room
        }
        
        if let eventDescription = descriptionTextView.text, !eventDescription.isEmpty {
            eventPFObject[C.Parse.Event.Keys.description] = eventDescription
        }
        
        eventPFObject.saveInBackground { succeeded, error in
            if succeeded {
                _ = self.navigationController?.popViewController(animated: true)
                
                let parseEvent = ParseEvent(pfObject: eventPFObject)
                self.completion?(parseEvent)
            } else {
                HUD.flash(.label(error?.localizedDescription ?? "Create event failed"))
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        performSegue(withIdentifier: "EventDetailPickerViewController", sender: textField.tag)
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tag = sender as? Int {
            if let vc = segue.destination as? EventDetailPickerViewController {
                typealias Mode = EventDetailPickerViewController.Mode
                
                switch tag {
                case Mode.startDateTime.rawValue:
                    vc.mode = .startDateTime
                    vc.dateClosure = { date in
                        self.startDateTime = date
                        self.startDateTimeTextField.text = date.shortDateTimeFormat
                    }
                case Mode.endDateTime.rawValue:
                    vc.mode = .endDateTime
                    vc.dateClosure = { date in
                        self.endDateTime = date
                        self.endDateTimeTextField.text = date.shortDateTimeFormat
                    }
                case Mode.campus.rawValue:
                    vc.mode = .campus
                    vc.stringClosure = { object, string in
                        self.campus = object
                        self.campusTextField.text = string
                    }
                case Mode.building.rawValue:
                    vc.mode = .building
                    vc.campusID = campus?.objectId
                    vc.stringClosure = { object, string in
                        self.building = object
                        self.buildingTextField.text = string
                    }
                case Mode.room.rawValue:
                    vc.mode = .room
                    vc.buildingID = building?.objectId
                    vc.stringClosure = { object, string in
                        self.room = object
                        self.roomTextField.text = string
                    }
                default:
                    break
                }
            }
        }
    }
}
