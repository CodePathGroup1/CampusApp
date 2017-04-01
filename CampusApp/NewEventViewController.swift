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
    
    private var campusID: String?
    private var buildingID: String?
    private var roomID: String?
    
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
                        self.startDateTimeTextField.text = date.shortDateTimeFormat
                    }
                case Mode.endDateTime.rawValue:
                    vc.mode = .endDateTime
                    vc.dateClosure = { date in
                        self.endDateTimeTextField.text = date.shortDateTimeFormat
                    }
                case Mode.campus.rawValue:
                    vc.mode = .campus
                    vc.stringClosure = { objectID, string in
                        self.campusID = objectID
                        self.campusTextField.text = string
                        
                        self.buildingID = nil
                        self.buildingTextField.text = ""
                        
                        self.roomID = nil
                        self.roomTextField.text = ""
                    }
                case Mode.building.rawValue:
                    vc.mode = .building
                    vc.campusID = campusID
                    vc.stringClosure = { objectID, string in
                        self.buildingID = objectID
                        self.buildingTextField.text = string
                        
                        self.roomID = nil
                        self.roomTextField.text = ""
                    }
                case Mode.room.rawValue:
                    vc.mode = .room
                    vc.buildingID = buildingID
                    vc.stringClosure = { objectID, string in
                        self.roomID = objectID
                        self.roomTextField.text = string
                    }
                default:
                    break
                }
            }
        }
    }
}
