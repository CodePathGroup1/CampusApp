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

class EditEventViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var titleTextField: RoundTextField!
    @IBOutlet weak var startDateTimeTextField: RoundTextField!
    @IBOutlet weak var endDateTimeTextField: RoundTextField!
    @IBOutlet weak var campusTextField: RoundTextField!
    @IBOutlet weak var buildingTextField: RoundTextField!
    @IBOutlet weak var roomTextField: RoundTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    enum Mode {
        case New, Edit(ParseEvent)
    }
    
    var mode: Mode!
    private var eventPFObject: PFObject!
    
    enum Tag: Int {
        case startDateTime = 0
        case endDateTime = 1
        case campus = 2
        case building = 3
        case room = 4
    }
    
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
    
    private var isSaving = false
    var completionHandler: ((ParseEvent) -> ())?
    
    
    /* ====================================================================================================
     MARK: - Lifecycle Method
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDateTimeTextField.delegate = self
        startDateTimeTextField.tag = Tag.startDateTime.rawValue
        
        endDateTimeTextField.delegate = self
        endDateTimeTextField.tag = Tag.endDateTime.rawValue
        
        campusTextField.delegate = self
        campusTextField.tag = Tag.campus.rawValue
        
        buildingTextField.delegate = self
        buildingTextField.tag = Tag.building.rawValue
        
        roomTextField.delegate = self
        roomTextField.tag = Tag.room.rawValue
        
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.clipsToBounds = true
        
        switch mode! {
        case .New:
            eventPFObject = PFObject(className: C.Parse.Event.className)
            navigationItem.title = "New Event"
            
        case .Edit(let parseEvent):
            eventPFObject = parseEvent.pfObject
            navigationItem.title = "Edit Event"
            
            titleTextField.text = parseEvent.title
            
            startDateTime = parseEvent.startDateTime
            startDateTimeTextField.text = parseEvent.startDateTime?.shortDateTimeFormat
            
            endDateTime = parseEvent.endDateTime
            endDateTimeTextField.text = parseEvent.endDateTime?.shortDateTimeFormat
            
            campus = parseEvent.campus
            if let campus = campus {
                campusTextField.text = campus[C.Parse.Campus.Keys.name] as? String
            }
            
            building = parseEvent.building
            if let building = building {
                buildingTextField.text = building[C.Parse.Building.Keys.name] as? String
            }
            
            room = parseEvent.room
            if let room = room {
                roomTextField.text = room[C.Parse.Room.Keys.name] as? String
            }
            
            descriptionTextView.text = parseEvent.description
        }
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Buttons
     ====================================================================================================== */
    @IBAction func saveButtonTapped(_ sender: Any) {
        save(eventPFObject: eventPFObject)
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - TextField Delegate Methods
     ====================================================================================================== */
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == Tag.building.rawValue, self.campus == nil {
            HUD.flash(.label("No campus has been specified yet."))
            
        } else if textField.tag == Tag.room.rawValue, self.building == nil {
            HUD.flash(.label("No building has been specified yet."))
            
        } else {
            view.endEditing(true)
            
            let storyboard = UIStoryboard(name: "Event", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "EditEventDetailPickerViewController") as? EditEventDetailPickerViewController {
                vc.modalPresentationStyle = .popover
                vc.popoverPresentationController?.permittedArrowDirections = .up
                vc.popoverPresentationController?.delegate = self
                vc.popoverPresentationController?.sourceView = textField
                vc.popoverPresentationController?.sourceRect = textField.bounds
                
                switch textField.tag {
                case Tag.startDateTime.rawValue:
                    vc.mode = .startDateTime(self.endDateTime)
                    vc.dateClosure = { date in
                        self.startDateTime = date
                        self.startDateTimeTextField.text = date.shortDateTimeFormat
                    }
                    present(vc, animated: true, completion: nil)
                case Tag.endDateTime.rawValue:
                    vc.mode = .endDateTime(self.startDateTime)
                    vc.dateClosure = { date in
                        self.endDateTime = date
                        self.endDateTimeTextField.text = date.shortDateTimeFormat
                    }
                    present(vc, animated: true, completion: nil)
                case Tag.campus.rawValue:
                    vc.mode = .campus(nil)
                    vc.stringClosure = { object, string in
                        self.campus = object
                        self.campusTextField.text = string
                    }
                    present(vc, animated: true, completion: nil)
                case Tag.building.rawValue:
                    if let campus = self.campus {
                        vc.mode = .building(campus)
                        vc.stringClosure = { object, string in
                            self.building = object
                            self.buildingTextField.text = string
                        }
                        present(vc, animated: true, completion: nil)
                    }
                case Tag.room.rawValue:
                    if let building = self.building {
                        vc.mode = .room(building)
                        vc.stringClosure = { object, string in
                            self.room = object
                            self.roomTextField.text = string
                        }
                        present(vc, animated: true, completion: nil)
                    }
                default:
                    break
                }
            }
        }
        
        return false
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UIPopoverPresentationController Delegate Methods
     ====================================================================================================== */
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Private Helper Methods
     ====================================================================================================== */
    private func save(eventPFObject: PFObject) {
        if !isSaving { return }
        
        guard
            let title = titleTextField.text, !title.isEmpty,
            let startDateTime = startDateTime,
            let endDateTime = endDateTime
            else {
                HUD.flash(.label("Missing content in required field(s)"))
                return
        }
        
        self.isSaving = true
        
        eventPFObject[C.Parse.Event.Keys.title] = title
        
        if let currentUser = PFUser.current() {
            eventPFObject[C.Parse.Event.Keys.organizer] = currentUser
            
            if let fullName = currentUser[C.Parse.User.Keys.fullName] as? String {
                eventPFObject[C.Parse.Event.Keys.organizerName] = fullName
            }
            
            switch mode! {
            case .New:
                let relation = eventPFObject.relation(forKey: C.Parse.Event.Keys.attendees)
                relation.add(currentUser)
                
                eventPFObject[C.Parse.Event.Keys.attendeeCount] = 1
            default:
                break
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
                self.isSaving = false
                
                DispatchQueue.main.async {
                    _ = self.navigationController?.popViewController(animated: true)
                }
                
                let parseEvent = ParseEvent(pfObject: eventPFObject)
                self.completionHandler?(parseEvent)
            } else {
                self.isSaving = false
                HUD.flash(.label(error?.localizedDescription ?? "Create event failed"))
            }
        }
    }
    /* ==================================================================================================== */
}
