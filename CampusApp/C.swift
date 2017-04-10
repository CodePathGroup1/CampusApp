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
            static let chatUserCell = "ChatUserCell"
        }
        
        struct Segue {
            static let chatConversationViewController = (
                new: "ChatConversationViewController_NEW",
                old: "ChatConversationViewController_OLD"
            )
            static let chatUserSearchViewController = "ChatUserSearchViewController"
        }
    }
    
    struct Parse {
        struct Building {
            static let className = "Building"
            
            struct Keys {
                static let campus = "campus"
                static let name = "name"
            }
        }
        
        struct Campus {
            static let className = "Campus"
            
            struct Keys {
                static let name = "name"
            }
        }
        
        struct Conversation {
            static let className = "Conversation"
            
            struct Keys {
                static let conversationID = "conversation_id"
                static let lastMessage = "last_message"
                static let lastMessageTimestamp = "last_message_timestamp"
                static let lastUser = "last_user"
                static let sendersDescription = "senders_description"
                static let users = "users"
            }
        }
        
        struct Event {
            static let className = "Event"
            
            struct Keys {
                static let googleEventID = "google_event_id"
                static let title = "title"
                static let organizer = "organizer"
                static let organizerName = "organizer_name"
                static let startDateTime = "start_date_time"
                static let endDateTime = "end_date_time"
                static let campus = "campus"
                static let building = "building"
                static let room = "room"
                static let attendees = "attendees"
                static let attendeeCount = "attendee_count"
                static let description = "description"
                static let eventImages = "event_images"
            }
        }
        
        struct Image {
            static let className = "Image"
            
            struct Keys {
                static let uploader = "uploader"
                static let file = "file"
            }
        }
        
        struct Message {
            static let className = "Message"
            
            struct Keys {
                static let conversation = "conversation"
                static let createdAt = "createdAt"
                static let picture = "picture"
                static let text = "text"
                static let user = "user"
                static let video = "video"
            }
        }
        
        struct Room {
            static let className = "Room"
            
            struct Keys {
                static let building = "building"
                static let name = "name"
            }
        }
        
        struct User {
            static let className = "_User"
            
            struct Keys {
                static let avatar = "avatar"
                static let email = "email"
                static let favoritedPFObjects = "favorited_pf_objects"
                static let rsvpEvents = "rsvp_events"
                static let fullName = "full_name"
                static let username = "username"
            }
        }
    }
}
