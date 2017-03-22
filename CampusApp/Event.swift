//
//  Event.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/21/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Foundation

class Event {
    
    // Events Response: https://developers.google.com/google-apps/calendar/v3/reference/events
    
    let id: String?
    let summary: String?
    let organizerDisplayName: String?
    let startDateTime: Date?
    let endDateTime: Date?
    let location: String?
    let description: String?
    let htmlLink: String?
    
    // "fields": "items(id,summary,organizer(displayName),start,end,location,description,htmlLink)",
    init(json: [String: AnyObject]) {
        
        id = json["id"] as? String
        summary = json["summary"] as? String
        organizerDisplayName = json["organizer"]?["displayName"] as? String
        
        if let startDateTimeString = json["start"]?["dateTime"] as? String,
            let formattedStartDateTime = startDateTimeString.dateFromISO8601 {
            startDateTime = formattedStartDateTime
        } else {
            startDateTime = nil
        }
        
        if let endDateTimeString = json["end"]?["dateTime"] as? String,
            let formattedStartDateTime = endDateTimeString.dateFromISO8601 {
            endDateTime = formattedStartDateTime
        } else {
            endDateTime = nil
        }
        
        location = json["location"] as? String
        description = json["description"] as? String
        htmlLink = json["htmlLink"] as? String
    }
}
