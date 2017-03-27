//
//  User.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse

class User {
    
    let pfObject: PFObject
    
//    let avatarPFFile: PFFile?
    let fullName: String?
    let id: String?
    
    init(pfObject: PFObject) {
        self.pfObject = pfObject
        
//        avatarPFFile = pfObject[C.Parse.User.Keys.avatar] as? PFFile
        fullName = pfObject[C.Parse.User.Keys.fullName] as? String
        id = pfObject.objectId
    }
}
