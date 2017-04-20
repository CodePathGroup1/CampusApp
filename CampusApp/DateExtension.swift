//
//  DateExtension.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/21/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Foundation

extension Date {
    
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
        let shortDateTimeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            
            if Calendar.current.isDate(self, inSameDayAs: Date()) {
                formatter.dateFormat = "hh:mm a"
            } else {
                formatter.dateFormat = "MMM d, hh:mm a"
            }
            return formatter
        }()
        return shortDateTimeFormatter.string(from: self)
    }
}
