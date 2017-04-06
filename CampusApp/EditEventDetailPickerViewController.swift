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

class EditEventDetailPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    enum Mode {
        case startDateTime(Date?)
        case endDateTime(Date?)
        case campus(PFObject?)
        case building(PFObject)
        case room(PFObject)
        case invalid
    }
    
    @IBOutlet weak var inputDatePicker: UIDatePicker!
    @IBOutlet weak var inputPickerView: UIPickerView!
    @IBOutlet weak var customNameField: RoundTextField!
    
    var mode: Mode = .invalid
    
    var dateClosure: ((Date) -> Void)!
    var stringClosure: ((PFObject?, String?) -> Void)!
    
    private var className: String?
    
    private var pickerObjects: [PFObject] = []
    private var pickerData: [String] = []
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputPickerView.dataSource = self
        inputPickerView.delegate = self
        
        switch mode {
        case .startDateTime(let endDate):
            navigationItem.title = "Select Start Time"
            inputDatePicker.minimumDate = Date()
            inputDatePicker.maximumDate = endDate
            inputPickerView.isHidden = true
            customNameField.isHidden = true
        case .endDateTime(let startDate):
            navigationItem.title = "Select End Time"
            inputDatePicker.minimumDate = (startDate ?? Date())
            inputPickerView.isHidden = true
            customNameField.isHidden = true
        case .campus(_):
            navigationItem.title = "Select Campus"
            className = C.Parse.Campus.className
            inputDatePicker.isHidden = true
            customNameField.placeholder = "New campus"
        case .building(_):
            navigationItem.title = "Select Building"
            className = C.Parse.Building.className
            inputDatePicker.isHidden = true
            customNameField.placeholder = "New building"
        case .room(_):
            navigationItem.title = "Select Room"
            className = C.Parse.Room.className
            inputDatePicker.isHidden = true
            customNameField.placeholder = "New room"
        case .invalid:
            break
        }
        
        if !inputPickerView.isHidden {
            if let className = className {
                HUD.flash(.label("Loading \(className)..."))
                
                let query = PFQuery(className: className)
                
                switch mode {
                case .campus(_):
                    break   // Do nothing, for now
                case .building(let campus):
                    query.whereKey(C.Parse.Building.Keys.campus, equalTo: campus)
                case .room(let building):
                    query.whereKey(C.Parse.Room.Keys.building, equalTo: building)
                default:
                    break
                }
                
                query.findObjectsInBackground { pfObjects, error in
                    if let pfObjects = pfObjects {
                        self.pickerObjects = pfObjects
                        
                        self.pickerData = pfObjects.reduce([]) { result, pfObject in
                            switch self.mode {
                            case .campus(_):
                                if let name = pfObject[C.Parse.Campus.Keys.name] as? String {
                                    return result + [name]
                                }
                            case .building(_):
                                if let name = pfObject[C.Parse.Building.Keys.name] as? String {
                                    return result + [name]
                                }
                            case .room(_):
                                if let name = pfObject[C.Parse.Room.Keys.name] as? String {
                                    return result + [name]
                                }
                            default:
                                break
                            }
                            return result
                        }
                        
                        DispatchQueue.main.async {
                            self.inputPickerView.reloadAllComponents()
                            
                            HUD.hide(animated: true)
                        }
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
            switch self.mode {
            case .startDateTime(_), .endDateTime(_):
                self.dateClosure(self.inputDatePicker.date)
                
            default:
                if let customName = self.customNameField.text, !customName.isEmpty,
                   let className = self.className, !className.isEmpty {
                    let pfObject = PFObject(className: className)
                    
                    switch self.mode {
                    case .campus(_):
                        pfObject[C.Parse.Campus.Keys.name] = customName
                    case .building(let campus):
                        pfObject[C.Parse.Building.Keys.name] = customName
                        pfObject[C.Parse.Building.Keys.campus] = campus
                    case .room(let building):
                        pfObject[C.Parse.Room.Keys.name] = customName
                        pfObject[C.Parse.Room.Keys.building] = building
                    default:
                        break
                    }
                    
                    pfObject.saveInBackground { succeeded, error in
                        if succeeded {
                            DispatchQueue.main.async {
                                self.stringClosure(pfObject, customName)
                            }
                        } else {
                            HUD.flash(.label(error?.localizedDescription ?? "Saving custom object failed"))
                        }
                    }
                    
                } else if self.pickerObjects.isEmpty || self.pickerData.isEmpty {
                    DispatchQueue.main.async {
                        self.stringClosure(nil, nil)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.stringClosure(self.pickerObjects[self.selectedIndex], self.pickerData[self.selectedIndex])
                    }
                }
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
