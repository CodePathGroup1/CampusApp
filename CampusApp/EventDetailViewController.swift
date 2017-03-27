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
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var event: GoogleCalendarEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = event.summary
        startingDateTimeLabel.text = event.startDateTime?.shortDateTimeFormat
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
        
        print(event)
    }
    
    
    @IBAction func eventCreatorTapped(_ sender: AnyObject) {
//        // TODO: change this to actual user
//        let query = PFQuery(className: C.Parse.User.className)
//        query.whereKey(C.Parse.User.Keys.username, notEqualTo: PFUser.current()!.username!)
//        query.limit = 1
//        query.findObjectsInBackground { pfObject, error in
//            if let pfObject = pfObject?.first {
//                let otherUsers = [User(pfObject: pfObject)]
//                Conversation.startConversation(otherUsers: otherUsers) { conversationID in
//                    let storyboard = UIStoryboard(name: "Chat", bundle: nil)
//                    if let vc = storyboard.instantiateViewController(withIdentifier: "ChatConversationViewController") as? ChatConversationViewController {
//                        vc.conversationID = conversationID
//                        self.present(vc, animated: true, completion: nil)
//                    }
//                }
//            } else {
//                HUD.flash(.label(error?.localizedDescription ?? "ERROR"))
//            }
//        }
        
        showViewController(storyboardIdentifier: "Chat", viewControllerIdentifier: "ChatNavigationController")
    }
    
    
}
