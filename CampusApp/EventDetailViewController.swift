//
//  DetailEventViewController.swift
//  CampusApp
//
//  Created by bwong on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import MapKit

class EventDetailViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var event: GoogleCalendarEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = event.summary
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
}
