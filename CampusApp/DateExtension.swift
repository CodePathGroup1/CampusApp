//
//  DateExtension.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/21/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Foundation

extension Date {
    /*
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    var iso8601: String {
        return Date.iso8601Formatter.string(from: self)
    }
    */
    
    static let standardTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
    var standardTime: String {
        return Date.standardTimeFormatter.string(from: self)
    }
    
    static let standardDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    var standardDate: String {
        return Date.standardDateFormatter.string(from: self)
    }
    
    var shortDateTimeFormat: String {
        let interval = self.timeIntervalSinceNow
        let shortDateTimeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            if interval < 24 * 60 * 60 {
                formatter.dateFormat = "hh:mm a"
            } else {
                formatter.dateFormat = "MMM d, hh:mm a"
            }
            return formatter
        }()
        return shortDateTimeFormatter.string(from: self)
    }
}
