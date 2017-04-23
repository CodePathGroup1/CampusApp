//
//  Image.swift
//  CampusApp
//
//  Created by Thomas Zhu on 4/9/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse

class ParseEventMedia {
    let pfObject: PFObject
    
    let uploader: PFUser?
    let image: PFFile?
    let video: PFFile?
    
    init(pfObject: PFObject) {
        self.pfObject = pfObject
        
        self.uploader = pfObject[C.Parse.Media.Keys.uploader] as? PFUser
        self.image = pfObject[C.Parse.Media.Keys.image] as? PFFile
        self.video = pfObject[C.Parse.Media.Keys.video] as? PFFile
    }
}
