//
//  Event.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/21/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Foundation

class GoogleCalendarEvent {
    
    // Events Response: https://developers.google.com/google-apps/calendar/v3/reference/events
    
    let id: String?
    let summary: String?
    let organizerDisplayName: String?
    var startDateTime: Date?
    var endDateTime: Date?
    let location: String?
    let description: String?
    let htmlLink: String?
    
    // "fields": "items(id,summary,organizer(displayName),start,end,location,description,htmlLink)",
    init(json: [String: AnyObject]) {
        
        id = json["id"] as? String
        summary = json["summary"] as? String
        organizerDisplayName = json["organizer"]?["displayName"] as? String
        
        if let startTimeString = json["start"]?["dateTime"] as? String,
            let startTime = startTimeString.timeFromStandardFormat {
            startDateTime = startTime
        } else if let startDateString = json["start"]?["date"] as? String,
            let startDate = startDateString.dateFromStandardFormat {
            startDateTime = startDate
        } else {
            startDateTime = nil
        }
        
        if let endTimeString = json["end"]?["dateTime"] as? String,
            let endTime = endTimeString.timeFromStandardFormat {
            endDateTime = endTime
        } else if let endDateString = json["end"]?["date"] as? String,
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
                        self.startDateTime!.addTimeInterval(60 * 60 * 24)
                        self.endDateTime!.addTimeInterval(60 * 60 * 24)
                    } while self.startDateTime! < Date()
                } else if let _ = firstRecurrence.range(of: "=WEEKLY") {
                    repeat {
                        self.startDateTime!.addTimeInterval(60 * 60 * 24 * 7)
                        self.endDateTime!.addTimeInterval(60 * 60 * 24 * 7)
                    } while self.startDateTime! < Date()
                } else if let _ = firstRecurrence.range(of: "=MONTHLY") {
                    repeat {
                        self.startDateTime = Calendar.current.date(byAdding: .month, value: 1, to: self.startDateTime!)
                        self.endDateTime = Calendar.current.date(byAdding: .month, value: 1, to: self.endDateTime!)
                    } while self.startDateTime! < Date()
                } else if let _ = firstRecurrence.range(of: "=YEARLY") {
                    repeat {
                        self.startDateTime = Calendar.current.date(byAdding: .year, value: 1, to: self.startDateTime!)
                        self.endDateTime = Calendar.current.date(byAdding: .year, value: 1, to: self.endDateTime!)
                    } while self.startDateTime! < Date()
                } else {
                    self.startDateTime = nil
                    self.endDateTime = nil
                }
            }
        }
        
        location = json["location"] as? String
        description = json["description"] as? String
        htmlLink = json["htmlLink"] as? String
    }
}
