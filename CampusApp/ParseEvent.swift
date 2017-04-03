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
    
    let title: String?
    let organizer: PFObject?
    let organizerName: String?
    let startDateTime: Date?
    let endDateTime: Date?
    
    let campus: PFObject?
    let building: PFObject?
    let room: PFObject?
    
    let attendees: PFRelation<PFObject>?
    
    let description: String?
    
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
         attendees: PFRelation<PFObject>?,
         description: String?) {
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
        
        self.description = description
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
        
        self.attendees = pfObject[C.Parse.Event.Keys.attendees] as? PFRelation<PFObject>
        
        self.description = pfObject[C.Parse.Event.Keys.description] as? String
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
        
        self.pfObject = eventPFObject
        return eventPFObject
    }
    
    func favorite(completion: ((Void) -> Void)?) {
        if let currentUser = PFUser.current() {
            let pfObject = self.getRemoteParseObject()
            
            pfObject.saveInBackground { succeeded, error in
                if succeeded {
                    HUD.flash(.progress)
                    pfObject.saveInBackground { succeeded, error in
                        if succeeded {
                            self.isFavorited = !self.isFavorited
                            
                            let relation = currentUser.relation(forKey: C.Parse.User.Keys.favoritedPFObjects)
                            if self.isFavorited {
                                relation.add(pfObject)
                            } else {
                                relation.remove(pfObject)
                            }
                            
                            currentUser.saveInBackground { succeed, error in
                                if succeeded {
                                    completion?()
                                } else {
                                    self.isFavorited = !self.isFavorited
                                    HUD.flash(.label("Failed to save favorited event to user profile"))
                                }
                            }
                        } else {
                            HUD.flash(.label(error?.localizedDescription ?? "Unknown error"))
                        }
                    }
                } else {
                    HUD.flash(.label(error?.localizedDescription ?? "Unknown error"))
                }
            }
        }
    }
}
