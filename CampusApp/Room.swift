//
//  RoomID.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse

struct Room {
    
    let id: String?
    
    let campusID: String?
    let buildingID: String?
    
    let name: String?
    
    init(pfObject: PFObject) {
        id = pfObject.objectId
        
        campusID = pfObject["campus_id"] as? String
        buildingID = pfObject["building_id"] as? String
        
        name = pfObject["room_name"] as? String
    }
}
