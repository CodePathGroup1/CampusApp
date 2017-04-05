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
    
    let sendersDescription: String?
    let lastMessage: String?
    let lastMessageTimestamp: Date?
    
    init(pfObject: PFObject) {
        self.pfObject = pfObject
        
        sendersDescription = pfObject[C.Parse.Conversation.Keys.sendersDescription] as? String
        lastMessage = pfObject[C.Parse.Conversation.Keys.lastMessage] as? String
        lastMessageTimestamp = pfObject[C.Parse.Conversation.Keys.lastMessageTimestamp] as? Date
    }
    
    class func startConversation(otherUsers: [PFUser], completion: @escaping (PFObject) -> Void) {
        if let currentUser = PFUser.current() {
            if !otherUsers.isEmpty {
                let users: [PFUser] = (otherUsers + [currentUser])
                    .reduce([]) { result, user in
                        if let _ = user.objectId {
                            return (result + [user])
                        }
                        return result
                    }.sorted(by: { user1, user2 -> Bool in
                        return user1.objectId! < user2.objectId!
                    })
                
                let query = PFQuery(className: C.Parse.Conversation.className)
                query.whereKey(C.Parse.Conversation.Keys.users, containsAllObjectsIn: users)
                query.findObjectsInBackground { pfObjects, error in
                    if let pfObject = pfObjects?.first {
                        completion(pfObject)
                    } else {
                        let newConversationPFObject = PFObject(className: C.Parse.Conversation.className)
                        newConversationPFObject[C.Parse.Conversation.Keys.users] = users
                        newConversationPFObject.saveInBackground { succeed, error in
                            if succeed {
                                completion(newConversationPFObject)
                            } else {
                                HUD.flash(.label(error?.localizedDescription ?? "Starting conversation failed"))
                            }
                        }
                    }
                }
            }
        }
    }
}
