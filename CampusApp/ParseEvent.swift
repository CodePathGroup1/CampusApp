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
    var isRSVPed = false
    
    let title: String?
    let organizer: PFObject?
    let organizerName: String?
    var startDateTime: Date?
    var endDateTime: Date?
    
    let campus: PFObject?
    let building: PFObject?
    let room: PFObject?
    
    var attendees: [PFUser]?
    var attendeeCount: Int?
    
    let description: String?
    
    var eventMedias: [ParseEventMedia]?
    
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
         eventMedias: [ParseEventMedia]?) {
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
        
        self.eventMedias = eventMedias
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
        
        self.eventMedias = pfObject[C.Parse.Event.Keys.eventMedias] as? [ParseEventMedia]
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
            
            self.isRSVPed = !self.isRSVPed
            
            let eventPFObject = self.getRemoteParseObject()
            
            let saveRelationsBlock = {
                if let pfObject = self.pfObject {
                    let relation = pfObject.relation(forKey: C.Parse.Event.Keys.attendees)
                    if self.isRSVPed {
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
                            if self.isRSVPed {
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
    
    func add(eventImagePFFile: PFFile?, eventVideoPFFile: PFFile?, completion: ((Void) -> Void)?) {
        let eventPFObject = self.getRemoteParseObject()
        
        let saveRelationsBlock = {
            if let currentUser = PFUser.current(),
                let pfObject = self.pfObject {
                
                guard let _ = (eventImagePFFile ?? eventVideoPFFile) else {
                    HUD.hide(animated: false)
                    UIWindow.showMessage(title: "Error",
                                         message: "Unknown type of media file")
                    return
                }
                
                let mediaPFObject = PFObject(className: C.Parse.Media.className)
                mediaPFObject[C.Parse.Media.Keys.uploader] = currentUser
                if let eventImagePFFile = eventImagePFFile {
                    mediaPFObject[C.Parse.Media.Keys.image] = eventImagePFFile
                } else if let eventVideoPFFile = eventVideoPFFile {
                    mediaPFObject[C.Parse.Media.Keys.video] = eventVideoPFFile
                }
                
                mediaPFObject.saveInBackground { succeeded, error in
                    if succeeded {
                        let relation = pfObject.relation(forKey: C.Parse.Event.Keys.eventMedias)
                        relation.add(mediaPFObject)
                        
                        pfObject.saveInBackground { succeeded, error in
                            let eventMedia = ParseEventMedia(pfObject: mediaPFObject)
                            self.eventMedias = (self.eventMedias ?? []) + [eventMedia]
                            
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
