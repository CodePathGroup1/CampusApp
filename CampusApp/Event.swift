//
//  Event.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/31/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse

class Event {
    let pfObject: PFObject
    
    let googleEventID: String?
    let isFavorited: Bool?
    
    let title: String?
    let startDateTime: Date?
    let endDateTime: Date?
    
    let campusID: String?
    let buildingID: String?
    let roomID: String?
    
    let attendees: PFRelation<PFObject>?
    
    init(pfObject: PFObject) {
        self.pfObject = pfObject
        
        self.googleEventID = pfObject[C.Parse.Event.Keys.googleEventID] as? String
        self.isFavorited = pfObject[C.Parse.Event.Keys.isFavorited] as? Bool
        
        self.title = pfObject[C.Parse.Event.Keys.googleEventID] as? String
        self.startDateTime = pfObject[C.Parse.Event.Keys.startDateTime] as? Date
        self.endDateTime = pfObject[C.Parse.Event.Keys.endDateTime] as? Date
        
        self.campusID = pfObject[C.Parse.Event.Keys.campusID] as? String
        self.buildingID = pfObject[C.Parse.Event.Keys.buildingID] as? String
        self.roomID = pfObject[C.Parse.Event.Keys.roomID] as? String
        
        self.attendees = pfObject[C.Parse.Event.Keys.attendees] as? PFRelation<PFObject>
    }
}
