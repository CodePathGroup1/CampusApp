//
//  Event.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/31/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse
import PKHUD

class ParseEvent {
    var pfObject: PFObject?
    
    var googleEventID: String?
    var isFavorited = false
    var isRVSPed = false
    
    let title: String?
    let organizer: PFObject?
    let organizerName: String?
    let startDateTime: Date?
    let endDateTime: Date?
    
    let campus: PFObject?
    let building: PFObject?
    let room: PFObject?
    
    var attendees: [PFUser]?
    var attendeeCount: Int?
    
    let description: String?
    
    var eventImages: [ParseImage]?
    
    init(pfObject: PFObject?,
         googleEventID: String?,
         title: String?,
         organizer: PFObject?,
         organizerName: String?,
         startDateTime: Date?,
         endDateTime: Date?,
         campus: PFObject?,
         building: PFObject?,
         room: PFObject?,
         attendees: [PFUser]?,
         attendeeCount: Int?,
         description: String?,
         eventImages: [ParseImage]?) {
        self.pfObject = pfObject
        
        self.googleEventID = googleEventID
        
        self.title = title
        self.organizer = organizer
        self.organizerName = organizerName
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        
        self.campus = campus
        self.building = building
        self.room = room
        
        self.attendees = attendees
        self.attendeeCount = attendeeCount
        
        self.description = description
        
        self.eventImages = eventImages
    }
    
    init(pfObject: PFObject) {
        self.pfObject = pfObject
        
        self.googleEventID = pfObject[C.Parse.Event.Keys.googleEventID] as? String
        
        self.title = pfObject[C.Parse.Event.Keys.title] as? String
        self.organizer = pfObject[C.Parse.Event.Keys.organizer] as? PFObject
        self.organizerName = pfObject[C.Parse.Event.Keys.organizerName] as? String
        self.startDateTime = pfObject[C.Parse.Event.Keys.startDateTime] as? Date
        self.endDateTime = pfObject[C.Parse.Event.Keys.endDateTime] as? Date
        
        self.campus = pfObject[C.Parse.Event.Keys.campus] as? PFObject
        self.building = pfObject[C.Parse.Event.Keys.building] as? PFObject
        self.room = pfObject[C.Parse.Event.Keys.room] as? PFObject
        
        self.attendees = pfObject[C.Parse.Event.Keys.attendees] as? [PFUser]
        self.attendeeCount = pfObject[C.Parse.Event.Keys.attendeeCount] as? Int
        
        self.description = pfObject[C.Parse.Event.Keys.description] as? String
        
        self.eventImages = pfObject[C.Parse.Event.Keys.eventImages] as? [ParseImage]
    }
    
    private func getRemoteParseObject() -> PFObject {
        if let pfObject = self.pfObject {
            return pfObject
        }
        
        let eventPFObject = PFObject(className: C.Parse.Event.className)
        
        if let googleEventID = googleEventID {
            eventPFObject[C.Parse.Event.Keys.googleEventID] = googleEventID
        }
        if let title = title {
            eventPFObject[C.Parse.Event.Keys.title] = title
        }
        if let organizer = organizer {
            eventPFObject[C.Parse.Event.Keys.organizer] = organizer
        }
        if let organizerName = organizerName {
            eventPFObject[C.Parse.Event.Keys.organizerName] = organizerName
        }
        if let startDateTime = startDateTime {
            eventPFObject[C.Parse.Event.Keys.startDateTime] = startDateTime
        }
        if let endDateTime = endDateTime {
            eventPFObject[C.Parse.Event.Keys.endDateTime] = endDateTime
        }
        if let description = description {
            eventPFObject[C.Parse.Event.Keys.description] = description
        }
        
        return eventPFObject
    }
    
    func favorite(completion: ((Void) -> Void)?) {
        if let currentUser = PFUser.current() {
            HUD.show(.progress)
            
            self.isFavorited = !self.isFavorited
            
            let eventPFObject = self.getRemoteParseObject()
            
            let saveRelationsBlock = {
                if let pfObject = self.pfObject {
                    let relation = currentUser.relation(forKey: C.Parse.User.Keys.favoritedPFObjects)
                    if self.isFavorited {
                        relation.add(pfObject)
                    } else {
                        relation.remove(pfObject)
                    }
                    
                    currentUser.saveInBackground { succeeded, error in
                        if succeeded {
                            completion?()
                        } else {
                            HUD.hide(animated: false)
                            UIWindow.showMessage(title: "Error",
                                                 message: error?.localizedDescription ?? "Unknown Error")
                        }
                    }
                }
            }
            
            if self.pfObject == nil {
                eventPFObject.saveInBackground { succeeded, error in
                    if succeeded {
                        self.pfObject = eventPFObject
                        saveRelationsBlock()
                    } else {
                        HUD.hide(animated: false)
                        UIWindow.showMessage(title: "Error",
                                             message: error?.localizedDescription ?? "Unknown Error")
                    }
                }
            } else {
                saveRelationsBlock()
            }
    }
    }
    
    func rvsp(completion: ((Void) -> Void)?) {
        if let currentUser = PFUser.current() {
            HUD.show(.progress)
            
            self.isRVSPed = !self.isRVSPed
            
            let eventPFObject = self.getRemoteParseObject()
            
            let saveRelationsBlock = {
                if let pfObject = self.pfObject {
                    let relation = pfObject.relation(forKey: C.Parse.Event.Keys.attendees)
                    if self.isRVSPed {
                        relation.add(currentUser)
                        
                        self.attendeeCount = (self.attendeeCount ?? 0) + 1
                        pfObject[C.Parse.Event.Keys.attendeeCount] = self.attendeeCount
                    } else {
                        relation.remove(currentUser)
                        
                        self.attendeeCount = max(0, (self.attendeeCount ?? 0) - 1)
                        pfObject[C.Parse.Event.Keys.attendeeCount] = self.attendeeCount
                    }
                    
                    pfObject.saveInBackground { succeeded, error in
                        if succeeded {
                            let relation = currentUser.relation(forKey: C.Parse.User.Keys.rsvpEvents)
                            if self.isRVSPed {
                                relation.add(pfObject)
                            } else {
                                relation.remove(pfObject)
                            }
                            
                            currentUser.saveInBackground { succeeded, error in
                                if succeeded {
                                    completion?()
                                } else {
                                    HUD.hide(animated: false)
                                    UIWindow.showMessage(title: "Error",
                                                         message: error?.localizedDescription ?? "Unknown Error")
                                }
                            }
                        } else {
                            HUD.hide(animated: false)
                            UIWindow.showMessage(title: "Error",
                                                 message: error?.localizedDescription ?? "Unknown Error")
                        }
                    }
                }
            }
            
            if self.pfObject == nil {
                eventPFObject.saveInBackground { succeeded, error in
                    if succeeded {
                        self.pfObject = eventPFObject
                        saveRelationsBlock()
                    } else {
                        HUD.hide(animated: false)
                        UIWindow.showMessage(title: "Error",
                                             message: error?.localizedDescription ?? "Unknown Error")
                    }
                }
            } else {
                saveRelationsBlock()
            }
        }
    }
    
    func add(eventImage: UIImage, completion: ((Void) -> Void)?) {
        let eventPFObject = self.getRemoteParseObject()
        
        let saveRelationsBlock = {
            if let data = UIImageJPEGRepresentation(eventImage, 0.6),
                let eventImagePFfile = PFFile(name: "picture.jpg", data: data),
                let currentUser = PFUser.current(),
                let pfObject = self.pfObject {
                
                let imagePFObject = PFObject(className: C.Parse.Image.className)
                imagePFObject[C.Parse.Image.Keys.uploader] = currentUser
                imagePFObject[C.Parse.Image.Keys.file] = eventImagePFfile
                
                imagePFObject.saveInBackground { succeeded, error in
                    if succeeded {
                        let relation = pfObject.relation(forKey: C.Parse.Event.Keys.eventImages)
                        relation.add(imagePFObject)
                        
                        pfObject.saveInBackground { succeeded, error in
                            let eventImage = ParseImage(pfObject: imagePFObject)
                            self.eventImages = (self.eventImages ?? []) + [eventImage]
                            
                            completion?()
                        }
                    } else {
                        HUD.hide(animated: false)
                        UIWindow.showMessage(title: "Error",
                                             message: error?.localizedDescription ?? "Unknown Error")
                    }
                }
            }
        }
        
        if self.pfObject == nil {
            eventPFObject.saveInBackground { succeeded, error in
                if succeeded {
                    self.pfObject = eventPFObject
                    saveRelationsBlock()
                } else {
                    HUD.hide(animated: false)
                    UIWindow.showMessage(title: "Error",
                                         message: error?.localizedDescription ?? "Unknown Error")
                }
            }
        } else {
            saveRelationsBlock()
        }
    }
}
