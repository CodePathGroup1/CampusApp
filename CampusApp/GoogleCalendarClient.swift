//
//  GoogleCalendarClient.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/21/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Alamofire

final class GoogleCalendarClient {
    
    // Singleton
    private init() {}
    static let shared = GoogleCalendarClient()
    
    private let apiKey = "AIzaSyD1gPcuMO_RizGjv3hdfGKpeQtyBgOyM0A"
    
    static let calendarIDs = [
        "mail.ccsf.edu_2o3osj4laq9iapttl8tpc5igbc@group.calendar.google.com",
        "mail.ccsf.edu_djf1t09bs3hs7na51a2ugucecs@group.calendar.google.com",
        "mail.ccsf.edu_6l8efonhf1jsq2vtsp9o38ieh4@group.calendar.google.com",
        "mail.ccsf.edu_45mddeoe0cfrg14kbs5j66crjk@group.calendar.google.com",
        "mail.ccsf.edu_ajl36csfff59hvgoqnpqfhdfa4@group.calendar.google.com",
        "mail.ccsf.edu_ml030nogs912koibedf3c32o5g@group.calendar.google.com",
        "mail.ccsf.edu_8n8s52tpu38jbl5qbue2cu9iu4@group.calendar.google.com",
        "mail.ccsf.edu_cifichd62qr3qscud1mfo7fs58@group.calendar.google.com",
        "mail.ccsf.edu_6fvktpvq3pb7d6qb96sevccf68@group.calendar.google.com",
        "mail.ccsf.edu_j50qlhv9oovhjprdc2ge69jq30@group.calendar.google.com",
        "mail.ccsf.edu_6hjjr8d9hen8kfp098mbr0d38s@group.calendar.google.com"
    ]
    
    func getPublicEvents(calendarID: String, success: @escaping ([[String: AnyObject]]) -> Void, failure: @escaping (String) -> Void) {
        
        let baseURLString = "https://www.googleapis.com/calendar/v3/calendars/\(calendarID)/events"
        guard let baseURL = URL(string: baseURLString) else {
            failure("Invalid URL")
            return
        }
        
        // API Call: https://developers.google.com/google-apps/calendar/v3/reference/events/list
        // Events Response: https://developers.google.com/google-apps/calendar/v3/reference/events
        let parameters: Parameters = [
            "fields": "items(id,summary,organizer(displayName),start,end,location,description,htmlLink)",
            "key": apiKey,
            "maxResults": 10,
            "timeMin": Date().iso8601
        ]
        
        let headers: HTTPHeaders = ["X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier!]
        
        Alamofire.request(baseURL,
                          method: .get,
                          parameters: parameters,
                          headers: headers)
        .validate()
        .responseJSON { (response) -> Void in
            guard response.result.isSuccess else {
                failure("Unable to retrieve events")
                return
            }
            
            guard
                let value = response.result.value as? [String: AnyObject],
                let items = value["items"] as? [[String: AnyObject]] else {
                failure("Unable to parse events")
                return
            }
            
            success(items)
        }
    }
}
