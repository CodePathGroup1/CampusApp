//
//  Conversation.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Foundation

class Conversation {
    
    let id: String
    var otherUserIDs: [String?]?
    var latestMessageTimestamp: Date?
    var messages: [Message]?
    var hasUnreadMessages: Bool
    
    init() {
        self.id = UUID().uuidString
        self.otherUserIDs = nil
        self.latestMessageTimestamp = nil
        self.messages = nil
        self.hasUnreadMessages = false
    }
}
