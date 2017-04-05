//
//  Message.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/25/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse

class Message: PFObject, PFSubclassing {
    
    let pfObject: PFObject?
    
    let user: PFUser?
    let avatar: PFFile?
    
    let text: String?
    
    override init() {
        self.pfObject = nil
        
        self.user = nil
        self.avatar = nil
        
        self.text = nil
        
        super.init()
    }
    
    init(pfObject: PFObject) {
        self.pfObject = pfObject
        
        self.user = pfObject[C.Parse.Message.Keys.user] as? PFUser
        
        // TODO: Add the avatar key and work on the avatar
        self.avatar = nil // self.user?[C.Parse.User.Keys.avatar] as? PFFile
        
        self.text = pfObject[C.Parse.Message.Keys.text] as? String
        
        super.init()
    }
    
    public static func parseClassName() -> String {
        return "Message"
    }
}
