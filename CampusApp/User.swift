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
    
    let avatarPFFile: PFFile?
    let favoritedPFObjects: PFRelation<PFObject>?
    let fullName: String?
    let id: String?
    
    init(pfObject: PFObject) {
        self.pfObject = pfObject
        
        avatarPFFile = pfObject[C.Parse.User.Keys.avatar] as? PFFile
        favoritedPFObjects = pfObject[C.Parse.User.Keys.favoritedPFObjects] as? PFRelation<PFObject>
        fullName = pfObject[C.Parse.User.Keys.fullName] as? String
        id = pfObject.objectId
    }
}
