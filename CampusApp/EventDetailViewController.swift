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
    @IBOutlet weak var startingDateTimeLabel: UILabel!
    @IBOutlet weak var creatorAvatorPFImageView: PFImageView!
    @IBOutlet weak var creatorNameButton: UIButton!
    @IBOutlet weak var campusTextField: RoundTextField!
    @IBOutlet weak var buildingTextField: RoundTextField!
    @IBOutlet weak var roomTextField: RoundTextField!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var event: ParseEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = event.title
        startingDateTimeLabel.text = event.startDateTime?.shortDateTimeFormat
        
        if let organizer = event.organizer {
            creatorNameButton.setTitle(organizer[C.Parse.User.Keys.fullName] as? String, for: .normal)
        } else if let organizerName = event.organizerName {
            creatorAvatorPFImageView.isHidden = true
            creatorNameButton.setTitle(organizerName, for: .normal)
        }
        
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
        
        configuireUI()
        print(event)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        
        let pfObject = event.getRemoteParseObject()
        
        pfObject.saveInBackground { succeeded, error in
            if succeeded {
                if let isFavorited = self.event.isFavorited {
                    pfObject[C.Parse.Event.Keys.isFavorited] = !isFavorited
                } else {
                    pfObject[C.Parse.Event.Keys.isFavorited] = true
                }
                
                HUD.flash(.progress)
                pfObject.saveInBackground { succeeded, error in
                    if succeeded {
                        self.event = ParseEvent(pfObject: pfObject)
                        HUD.hide(animated: true)
                    } else {
                        HUD.flash(.label(error?.localizedDescription ?? "Unknown error"))
                    }
                }
            } else {
                HUD.flash(.label(error?.localizedDescription ?? "Unknown error"))
            }
        }
    }
    
    @IBAction func eventCreatorTapped(_ sender: AnyObject) {
        // TODO: change this to actual user
        let query = PFQuery(className: C.Parse.User.className)
        query.whereKey(C.Parse.User.Keys.username, notEqualTo: PFUser.current()!.username!)
        query.limit = 1
        query.findObjectsInBackground { pfObject, error in
            if let pfObject = pfObject?.first {
                let otherUsers = [User(pfObject: pfObject)]
                Conversation.startConversation(otherUsers: otherUsers) { conversationID in
                    let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "ChatConversationViewController") as? ChatConversationViewController {
                        vc.conversationID = conversationID
                        self.present(vc, animated: true) {
                            let alertVC = UIAlertController(title: "", message: "The following screen is just a demostration of the live chat feature. A pre-determined user is selected, not the actual event creator. That functionality is coming soon.", preferredStyle: .alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertVC.addAction(okAction)
                            
                            vc.present(alertVC, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                HUD.flash(.label(error?.localizedDescription ?? "ERROR"))
            }
        }
    }
    
    private func configuireUI() {
        
    }
}
