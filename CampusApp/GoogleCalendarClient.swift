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
    
    func getPublicEvents(calendarID: String, success: @escaping ([String: AnyObject]) -> Void, failure: @escaping (String) -> Void) {
        
        let baseURLString = "https://www.googleapis.com/calendar/v3/calendars/\(calendarID)/events"
        guard let baseURL = URL(string: baseURLString) else {
            failure("Invalid URL")
            return
        }
        
        // API Call: https://developers.google.com/google-apps/calendar/v3/reference/events/list
        // Events Response: https://developers.google.com/google-apps/calendar/v3/reference/events
        let parameters = [
            "key": apiKey,
            "fields": "items(id,summary,organizer(displayName),start,end,location,description,htmlLink)"
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
            
            guard let value = response.result.value as? [String: AnyObject] else {
                failure("Unable to parse events")
                return
            }
            
            success(value)
        }
    }
}
