//
//  StringExtension.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/21/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Foundation

extension String {
    /*
    var dateFromISO8601: Date? {
        return Date.iso8601Formatter.date(from: self)
    }
    */
    
    var timeFromStandardFormat: Date? {
        return Date.standardTimeFormatter.date(from: self)
    }
    
    var dateFromStandardFormat: Date? {
        return Date.standardDateFormatter.date(from: self)
    }
}
