//
//  Event.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse

enum EventType {
    case Event, Class
}

struct Event {
    
    let id: String?
    
    let startDateTime: Date?
    let endDateTime: Date?
    let name: String?
    let campusID: String?
    let buildingID: String?
    let roomID: String?
    let attendeeIDs: [String?]?
    let type: EventType?
    
    init(pfObject: PFObject) {
        id = pfObject.objectId
        
        startDateTime = pfObject["event_start_date_time"] as? Date
        endDateTime = pfObject["event_end_date_time"] as? Date
        name = pfObject["event_name"] as? String
        campusID = pfObject["campus_id"] as? String
        buildingID = pfObject["building_id"] as? String
        roomID = pfObject["room_id"] as? String
        attendeeIDs = pfObject["event_attendee_ids"] as? [String?]
        type = nil
    }
}
