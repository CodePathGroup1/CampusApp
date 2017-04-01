//
//  Event.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/21/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Foundation
import Parse

class GoogleCalendarEvent: ParseEvent {
    
    // Events Response: https://developers.google.com/google-apps/calendar/v3/reference/events
    
    init(json: [String: AnyObject]) {
        var startDateTime: Date?
        var endDateTime: Date?
        
        if let startTimeString = (json["start"] as? [String: AnyObject])?["dateTime"] as? String,
            let startTime = startTimeString.timeFromStandardFormat {
            startDateTime = startTime
        } else if let startDateString = (json["start"] as? [String: AnyObject])?["date"] as? String,
            let startDate = startDateString.dateFromStandardFormat {
            startDateTime = startDate
        } else {
            startDateTime = nil
        }
        
        if let endTimeString = (json["end"] as? [String: AnyObject])?["dateTime"] as? String,
            let endTime = endTimeString.timeFromStandardFormat {
            endDateTime = endTime
        } else if let endDateString = (json["end"] as? [String: AnyObject])?["date"] as? String,
            let endDate = endDateString.dateFromStandardFormat {
            endDateTime = endDate
        } else {
            endDateTime = nil
        }
        
        if let recurrence = json["recurrence"] as? [AnyObject],
            let firstRecurrence = recurrence.first as? String {
            if startDateTime != nil, endDateTime != nil {
                
                if let _ = firstRecurrence.range(of: "=DAILY") {
                    repeat {
                        startDateTime!.addTimeInterval(60 * 60 * 24)
                        endDateTime!.addTimeInterval(60 * 60 * 24)
                    } while startDateTime! < Date()
                } else if let _ = firstRecurrence.range(of: "=WEEKLY") {
                    repeat {
                        startDateTime!.addTimeInterval(60 * 60 * 24 * 7)
                        endDateTime!.addTimeInterval(60 * 60 * 24 * 7)
                    } while startDateTime! < Date()
                } else if let _ = firstRecurrence.range(of: "=MONTHLY") {
                    repeat {
                        startDateTime = Calendar.current.date(byAdding: .month, value: 1, to: startDateTime!)
                        endDateTime = Calendar.current.date(byAdding: .month, value: 1, to: endDateTime!)
                    } while startDateTime! < Date()
                } else if let _ = firstRecurrence.range(of: "=YEARLY") {
                    repeat {
                        startDateTime = Calendar.current.date(byAdding: .year, value: 1, to: startDateTime!)
                        endDateTime = Calendar.current.date(byAdding: .year, value: 1, to: endDateTime!)
                    } while startDateTime! < Date()
                } else {
                    startDateTime = nil
                    endDateTime = nil
                }
            }
        }
        
        super.init(pfObject: nil,
                   googleEventID: json["id"] as? String,
                   isFavorited: nil,
                   title: json["summary"] as? String,
                   organizerName: (json["organizer"] as? [String: AnyObject])?["displayName"] as? String,
                   startDateTime: startDateTime,
                   endDateTime: endDateTime,
                   campusID: nil,
                   buildingID: nil,
                   roomID: nil,
                   attendees: nil,
                   description: json["description"] as? String)
    }
}
