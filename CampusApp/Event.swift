//
//  Event.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/31/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse

class ParseEvent {
    let pfObject: PFObject?
    
    let googleEventID: String?
    let isFavorited: Bool?
    
    let title: String?
    let organizerName: String?
    let startDateTime: Date?
    let endDateTime: Date?
    
    let campusID: String?
    let buildingID: String?
    let roomID: String?
    
    let attendees: PFRelation<PFObject>?
    
    let description: String?
    
    init(pfObject: PFObject?,
         googleEventID: String?,
         isFavorited: Bool?,
         title: String?,
         organizerName: String?,
         startDateTime: Date?,
         endDateTime: Date?,
         campusID: String?,
         buildingID: String?,
         roomID: String?,
         attendees: PFRelation<PFObject>?,
         description: String?) {
        self.pfObject = pfObject
        
        self.googleEventID = googleEventID
        self.isFavorited = isFavorited
        
        self.title = title
        self.organizerName = organizerName
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        
        self.campusID = campusID
        self.buildingID = buildingID
        self.roomID = roomID
        
        self.attendees = attendees
        
        self.description = description
    }
    
    init(pfObject: PFObject) {
        self.pfObject = pfObject
        
        self.googleEventID = pfObject[C.Parse.Event.Keys.googleEventID] as? String
        self.isFavorited = pfObject[C.Parse.Event.Keys.isFavorited] as? Bool
        
        self.title = pfObject[C.Parse.Event.Keys.googleEventID] as? String
        self.organizerName = pfObject[C.Parse.Event.Keys.organizerName] as? String
        self.startDateTime = pfObject[C.Parse.Event.Keys.startDateTime] as? Date
        self.endDateTime = pfObject[C.Parse.Event.Keys.endDateTime] as? Date
        
        self.campusID = pfObject[C.Parse.Event.Keys.campusID] as? String
        self.buildingID = pfObject[C.Parse.Event.Keys.buildingID] as? String
        self.roomID = pfObject[C.Parse.Event.Keys.roomID] as? String
        
        self.attendees = pfObject[C.Parse.Event.Keys.attendees] as? PFRelation<PFObject>
        
        self.description = pfObject[C.Parse.Event.Keys.description] as? String
    }
}
