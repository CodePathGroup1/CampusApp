//
//  Message.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/25/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse

class Message: PFObject, PFSubclassing {
    public static func parseClassName() -> String {
        return "Message"
    }
}
