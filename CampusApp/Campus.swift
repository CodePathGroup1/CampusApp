//
//  Campus.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse

struct Campus {
    
    let id: String?
    
    let name: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    
    init(pfObject: PFObject) {
        id = pfObject.objectId
        
        name = pfObject["campus_name"] as? String
        address = pfObject["campus_address"] as? String
        latitude = pfObject["campus_latitude"] as? Double
        longitude = pfObject["campus_longitude"] as? Double
    }
}
