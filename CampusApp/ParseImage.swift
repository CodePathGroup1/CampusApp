//
//  Image.swift
//  CampusApp
//
//  Created by Thomas Zhu on 4/9/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse

class ParseImage {
    let pfObject: PFObject
    
    let uploader: PFUser?
    let file: PFFile?
    
    init(pfObject: PFObject) {
        self.pfObject = pfObject
        
        self.uploader = pfObject[C.Parse.Image.Keys.uploader] as? PFUser
        self.file = pfObject[C.Parse.Image.Keys.file] as? PFFile
    }
}
