//
//  DetailEventViewController.swift
//  CampusApp
//
//  Created by bwong on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import JSQMessagesViewController
import MapKit
import Parse
import ParseUI
import PKHUD
import UIKit

class EventDetailViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var creatorAvatorPFImageView: PFImageView!
    @IBOutlet weak var creatorNameButton: UIButton!
    @IBOutlet weak var startingDateTimeLabel: UILabel!
    @IBOutlet weak var endingDateTimeLabel: UILabel!
    @IBOutlet weak var campusTextField: RoundTextField!
    @IBOutlet weak var buildingTextField: RoundTextField!
    @IBOutlet weak var roomTextField: RoundTextField!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var changed = false
    var completionHandler: ((ParseEvent) -> Void)!
    var event: ParseEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = event.title
        
        if let isFavorited = event.isFavorited {
            let image = UIImage(named: (isFavorited ? "favorited" : "not-favorited"))
            favoriteButton.setImage(image, for: .normal)
        }
        
        if let organizer = event.organizer {
            if organizer.objectId != PFUser.current()?.objectId {
                creatorNameButton.setTitle(organizer[C.Parse.User.Keys.fullName] as? String, for: .normal)
            } else {
                if let creatorName = organizer[C.Parse.User.Keys.fullName] as? String {
                    creatorNameButton.setTitle("\(creatorName) (me)", for: .normal)
                } else {
                    creatorNameButton.setTitle("Me", for: .normal)
                }
                creatorNameButton.isEnabled = false
                creatorNameButton.isUserInteractionEnabled = false
            }
        } else if let organizerName = event.organizerName {
            creatorAvatorPFImageView.isHidden = true
            creatorNameButton.setTitle(organizerName, for: .normal)
        }
        
        startingDateTimeLabel.text = event.startDateTime?.shortDateTimeFormat
        endingDateTimeLabel.text = event.endDateTime?.shortDateTimeFormat
        
        if let campus = event.campus {
            campusTextField.text = campus[C.Parse.Campus.Keys.name] as? String
        }
        
        if let building = event.building {
            buildingTextField.text = building[C.Parse.Building.Keys.name] as? String
        }
        
        if let room = event.room {
            roomTextField.text = room[C.Parse.Room.Keys.name] as? String
        }
        
        descriptionLabel.text = event.description
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.layer.cornerRadius = 8.0
        mapView.clipsToBounds = true
        
        /*
        if let latitude = event.latitude, let longitude = event.longitude {
            let annotation: MKAnnotation = {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                return annotation
            }()
            
            mapView.showAnnotations([annotation], animated: false)
        }
        */
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if changed {
            completionHandler(self.event)
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        event.favorite { parseEvent in
            if let parseEvent = parseEvent {
                if let isFavorited = parseEvent.isFavorited {
                    let image = UIImage(named: (isFavorited ? "favorited" : "not-favorited"))
                    self.favoriteButton.setImage(image, for: .normal)
                }
                
                self.changed = true
                self.event = parseEvent
                HUD.hide(animated: true)
            }
        }
    }
    
    @IBAction func eventCreatorTapped(_ sender: AnyObject) {
        if let organizer = event.organizer, organizer.objectId != PFUser.current()?.objectId {
            let otherUsers = [User(pfObject: organizer)]
            Conversation.startConversation(otherUsers: otherUsers) { conversationID in
                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "ChatConversationViewController") as? ChatConversationViewController {
                    vc.conversationID = conversationID
                    self.present(vc, animated: true, completion: nil)
                }
            }
        } else if let _ = event.googleEventID {
            HUD.flash(.label("Chatting with user is not supported for events imported from Google Calendars."))
        }
    }
}
