//
//  C.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/24/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

struct C {
    struct Identifier {
        struct Cell {
            static let chatCell = "ChatCell"
        }
        
        struct Segue {
            static let chatConversationViewController = "ChatConversationViewController"
        }
    }
    
    struct Parse {
        struct Conversation {
            static let className = "Conversation"
            
            struct Keys {
                static let groupID = "group_id"
                static let lastMessage = "last_message"
                static let lastUser = "last_user"
                static let sendersDescription = "senders_description"
                static let lastMessageTimestamp = "last_message_timestamp"
                static let userID = "user_id"
            }
        }
        
        struct User {
            static let className = "User"
            
            struct Keys {
                static let avatar = "avatar"
            }
        }
    }
}
