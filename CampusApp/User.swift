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
    
    let avatar: PFFile?
    let fullName: String?
    let id: String?
    
    init(pbObject: PFObject) {
        self.pfObject = pbObject
        
        avatar = pbObject[C.Parse.User.Keys.avatar] as? PFFile
        fullName = pbObject[C.Parse.User.Keys.fullName] as? String
        id = pfObject[C.Parse.User.Keys.id] as? String
    }
}
