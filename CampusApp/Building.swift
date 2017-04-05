//
//  Building.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse

struct Building {
    
    let pfObject: PFObject?
    
    let campus: PFObject?
    let name: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    
    init(pfObject: PFObject) {
        self.pfObject = pfObject
        
        campus = pfObject["campus"] as? PFObject
        name = pfObject["building_name"] as? String
        address = pfObject["building_address"] as? String
        latitude = pfObject["building_latitude"] as? Double
        longitude = pfObject["building_longitude"] as? Double
    }
}
