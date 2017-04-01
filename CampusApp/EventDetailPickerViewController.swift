//
//  EventDetailPickerViewController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/31/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse
import PKHUD
import UIKit

class EventDetailPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    enum Mode: Int {
        case startDateTime = 0
        case endDateTime = 1
        case campus = 2
        case building = 3
        case room = 4
    }
    
    @IBOutlet weak var inputDatePicker: UIDatePicker!
    @IBOutlet weak var inputPickerView: UIPickerView!
    
    var mode: Mode!
    
    var campusID: String?
    var buildingID: String?
    
    var dateClosure: ((Date) -> Void)!
    var stringClosure: ((String, String) -> Void)!
    
    private var className: String?
    
    private var pickerObjectIDs: [String] = []
    private var pickerData: [String] = []
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inputPickerView.dataSource = self
        inputPickerView.delegate = self
        
        if mode == .startDateTime {
            inputPickerView.isHidden = true
        } else if mode == .endDateTime {
            inputPickerView.isHidden = true
        } else if mode == .campus {
            className = C.Parse.Campus.className
            inputDatePicker.isHidden = true
        } else if mode == .building {
            className = C.Parse.Building.className
            inputDatePicker.isHidden = true
        } else if mode == .room {
            className = C.Parse.Room.className
            inputDatePicker.isHidden = true
        }
        
        if !inputPickerView.isHidden {
            if let className = className {
                let query = PFQuery(className: className)
                
                if mode == .campus {
                    // Do nothing, for now
                } else if mode == .building, let campusID = campusID {
                    query.whereKey(C.Parse.Building.Keys.campusID, equalTo: campusID)
                } else if mode == .room, let buildingID = buildingID {
                    query.whereKey(C.Parse.Room.Keys.buildingID, equalTo: buildingID)
                }
                
                query.findObjectsInBackground { pfObjects, error in
                    if let pfObjects = pfObjects {
                        self.pickerObjectIDs = pfObjects.reduce([]) { result, pfObject in
                            if let objectId = pfObject.objectId {
                                return result + [objectId]
                            }
                            return result
                        }
                        
                        self.pickerData = pfObjects.reduce([]) { result, pfObject in
                            if self.mode == .campus, let name = pfObject[C.Parse.Campus.Keys.name] as? String {
                                return result + [name]
                            } else if self.mode == .building, let name = pfObject[C.Parse.Building.Keys.name] as? String {
                                return result + [name]
                            } else if self.mode == .room, let name = pfObject[C.Parse.Room.Keys.name] as? String {
                                return result + [name]
                            }
                            return result
                        }
                        
                        self.inputPickerView.reloadAllComponents()
                    } else {
                        HUD.flash(.label(error?.localizedDescription ?? "Unknown error"))
                    }
                }
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        dismiss(animated: true) { 
            if self.mode == .startDateTime || self.mode == .endDateTime {
                self.dateClosure(self.inputDatePicker.date)
            } else {
                self.stringClosure(self.pickerObjectIDs[self.selectedIndex], self.pickerData[self.selectedIndex])
            }
        }
    }
    
    /* ====================================================================================================
     MARK: - PickerView Methods
     ====================================================================================================== */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    /* ==================================================================================================== */
}
