//
//  Conversation.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Parse

class Conversation {
    
    let lastUser: PFUser?
    let sendersDescription: String?
    let lastMessage: String?
    let lastMessageTimestamp: Date?
    
    init(pfObject: PFObject) {
        lastUser = pfObject[C.Parse.Conversation.Keys.lastUser] as? PFUser
        sendersDescription = pfObject[C.Parse.Conversation.Keys.sendersDescription] as? String
        lastMessage = pfObject[C.Parse.Conversation.Keys.lastMessage] as? String
        lastMessageTimestamp = pfObject[C.Parse.Conversation.Keys.lastMessageTimestamp] as? Date
    }
}
