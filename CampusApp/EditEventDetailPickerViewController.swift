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
        case campus(String?)
        case building(String)
        case room(String)
        case invalid
    }
    
    @IBOutlet weak var inputDatePicker: UIDatePicker!
    @IBOutlet weak var inputPickerView: UIPickerView!
    
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
            inputDatePicker.minimumDate = Date()
            inputDatePicker.maximumDate = endDate
            inputPickerView.isHidden = true
        case .endDateTime(let startDate):
            inputDatePicker.minimumDate = (startDate ?? Date())
            inputPickerView.isHidden = true
        case .campus(_):
            className = C.Parse.Campus.className
            inputDatePicker.isHidden = true
        case .building(_):
            className = C.Parse.Building.className
            inputDatePicker.isHidden = true
        case .room(_):
            className = C.Parse.Room.className
            inputDatePicker.isHidden = true
        case .invalid:
            break
        }
        
        if !inputPickerView.isHidden {
            if let className = className {
                let query = PFQuery(className: className)
                
                switch mode {
                case .campus(_):
                    break   // Do nothing, for now
                case .building(let campusID):
                    query.whereKey(C.Parse.Building.Keys.campusID, equalTo: campusID)
                case .room(let buildingID):
                    query.whereKey(C.Parse.Room.Keys.buildingID, equalTo: buildingID)
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
            switch self.mode {
            case .startDateTime(_), .endDateTime(_):
                self.dateClosure(self.inputDatePicker.date)
            default:
                if self.pickerObjects.isEmpty || self.pickerData.isEmpty {
                    self.stringClosure(nil, nil)
                } else {
                    self.stringClosure(self.pickerObjects[self.selectedIndex], self.pickerData[self.selectedIndex])
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
