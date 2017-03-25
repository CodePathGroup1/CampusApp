//
//  Conversation.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Foundation
import Parse
import PKHUD

class Conversation {
    
    let pfObject: PFObject
    
    let lastUser: PFUser?
    let sendersDescription: String?
    let lastMessage: String?
    let lastMessageTimestamp: Date?
    
    init(pfObject: PFObject) {
        self.pfObject = pfObject
        
        lastUser = pfObject[C.Parse.Conversation.Keys.lastUser] as? PFUser
        sendersDescription = pfObject[C.Parse.Conversation.Keys.sendersDescription] as? String
        lastMessage = pfObject[C.Parse.Conversation.Keys.lastMessage] as? String
        lastMessageTimestamp = pfObject[C.Parse.Conversation.Keys.lastMessageTimestamp] as? Date
    }
    
    class func startConversation(otherUsers: [User], completion: @escaping (String) -> Void) {
        if let currentUser = PFUser.current(), let currentUserID = currentUser.objectId {
            let conversationID: String = {
                var otherUserID = otherUsers
                    .filter { $0.id != nil }
                    .map { $0.id! }
                otherUserID.append(currentUserID)
                
                return otherUserID.sorted().joined(separator: "|")
            }()
            
            if !conversationID.isEmpty {
                let query = PFQuery(className: C.Parse.Conversation.className)
                query.whereKey(C.Parse.Conversation.Keys.userID, equalTo: currentUserID)
                query.whereKey(C.Parse.Conversation.Keys.conversationID, equalTo: conversationID)
                query.findObjectsInBackground { pfObject, error in
                    if let pfObject = pfObject {
                        if pfObject.isEmpty {
                            let conversation = PFObject(className: C.Parse.Conversation.className)
                            conversation[C.Parse.Conversation.Keys.conversationID] = conversationID
                            conversation[C.Parse.Conversation.Keys.userID] = currentUserID
                            conversation.saveInBackground { succeed, error in
                                if succeed {
                                    completion(conversationID)
                                } else {
                                    HUD.flash(.label(error?.localizedDescription ?? "Starting conversation failed"))
                                }
                            }
                        } else {
                            completion(conversationID)
                        }
                    } else {
                        HUD.flash(.label(error?.localizedDescription ?? "Starting conversation failed"))
                    }
                }
            }
        }
    }
}
