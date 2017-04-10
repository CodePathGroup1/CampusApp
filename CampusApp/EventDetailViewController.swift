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

class EventDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MKMapViewDelegate {

    @IBOutlet var editButton: UIBarButtonItem!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var rsvpButton: UIButton!
    
    @IBOutlet weak var creatorAvatorPFImageView: PFImageView!
    @IBOutlet weak var creatorNameButton: UIButton!
    @IBOutlet weak var showAttendeesButton: UIButton!
    
    @IBOutlet weak var startingDateTimeLabel: UILabel!
    @IBOutlet weak var endingDateTimeLabel: UILabel!
    
    @IBOutlet weak var campusTextField: RoundTextField!
    @IBOutlet weak var buildingTextField: RoundTextField!
    @IBOutlet weak var roomTextField: RoundTextField!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var changed = false
    var completionHandler: ((ParseEvent) -> Void)!
    
    var event: ParseEvent!
    
    /* ====================================================================================================
     MARK: - Lifecycle Methods
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if event.organizer?.objectId != PFUser.current()?.objectId {
            navigationItem.rightBarButtonItem = nil
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadEventImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = event.title
        
        let favoriteButtonImage = UIImage(named: (event.isFavorited ? "favorited" : "not-favorited"))
        favoriteButton.setImage(favoriteButtonImage, for: .normal)
        
        let rsvpButtonImage = UIImage(named: (event.isRVSPed ? "remove_rsvp" : "add_rsvp"))
        rsvpButton.setImage(rsvpButtonImage, for: .normal)
        
        if let organizer = event.organizer {
            if organizer.objectId != PFUser.current()?.objectId {
                if let fullName = organizer[C.Parse.User.Keys.fullName] as? String, !fullName.isEmpty {
                    creatorNameButton.setTitle(fullName, for: .normal)
                } else if let organizerPFUser = organizer as? PFUser {
                    creatorNameButton.setTitle(organizerPFUser.username, for: .normal)
                } else {
                    creatorNameButton.setTitle("User \(organizer.objectId ?? "unknown")", for: .normal)
                }
            } else {
                if let creatorName = organizer[C.Parse.User.Keys.fullName] as? String, !creatorName.isEmpty {
                    creatorNameButton.setTitle("\(creatorName) (me)", for: .normal)
                } else if let username = PFUser.current()?.username, !username.isEmpty {
                    creatorNameButton.setTitle("\(username) (me)", for: .normal)
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
        
        if let attendeeCount = event.attendeeCount, attendeeCount >= 1 {
            self.showAttendeesButton.setTitle("\(attendeeCount) attending", for: .normal)
        } else {
            self.showAttendeesButton.setTitle("", for: .normal)
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
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Buttons
     ====================================================================================================== */
    @IBAction func editButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "EditEventViewController_EDIT", sender: nil)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        event.favorite {
            DispatchQueue.main.async {
                let image = UIImage(named: (self.event.isFavorited ? "favorited" : "not-favorited"))
                self.favoriteButton.setImage(image, for: .normal)
                
                self.changed = true
                
                HUD.hide(animated: true)
            }
        }
    }
    
    @IBAction func rsvpButtonTapped(_ sender: AnyObject) {
        event.rvsp {
            DispatchQueue.main.async {
                let image = UIImage(named: (self.event.isRVSPed ? "remove_rsvp" : "add_rsvp"))
                self.rsvpButton.setImage(image, for: .normal)
                
                if let currentUser = PFUser.current() {
                    if self.event.isRVSPed {
                        self.event.attendees = [currentUser] + (self.event.attendees ?? [])
                        
                    } else {
                        if let index = self.event.attendees?
                            .map({ return $0.objectId ?? "" })
                            .index(of: currentUser.objectId ?? "") {
                            
                            self.event.attendees?.remove(at: index)
                        }
                    }
                }
                self.prepareAttendeeCountLabel()
                
                self.changed = true
                
                HUD.hide(animated: true)
            }
        }
    }
    
    @IBAction func eventCreatorTapped(_ sender: AnyObject) {
        if let organizer = event.organizer as? PFUser, organizer.objectId != PFUser.current()?.objectId {
            Conversation.startConversation(otherUsers: [organizer]) { conversation in
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "ChatConversationViewController") as? ChatConversationViewController {
                        vc.conversation = conversation
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        } else if let _ = event.googleEventID {
            HUD.flash(.label("Chatting with user is not supported for events imported from Google Calendars."))
        }
    }
    
    @IBAction func showAttendeesButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "AttendeeListViewController", sender: nil)
    }
    
    @IBAction func addEventImageButtontapped(_ sender: AnyObject) {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take photo", style: .default) { _ in
            _ = Camera.shouldStartCamera(target: self, canEdit: true, frontFacing: true)
        }
        alertVC.addAction(takePhotoAction)
        
        let chooseExistingPhotoAction = UIAlertAction(title: "Choose existing photo", style: .default) { _ in
            _ = Camera.shouldStartPhotoLibrary(target: self, mediaType: .Photo, canEdit: true)
        }
        alertVC.addAction(chooseExistingPhotoAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UICollectionView Delegate Methods
     ====================================================================================================== */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventImageCell", for: indexPath) as? EventImageCell {
            if let eventImages = event.eventImages {
                let eventImage = eventImages[indexPath.item]
                
                cell.eventImageView.file = eventImage.file
                cell.eventImageView.loadInBackground()
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Event", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "EventImageViewController") as? EventImageViewController {
            
            if let cell = collectionView.cellForItem(at: indexPath) as? EventImageCell {
                if let image = cell.eventImageView.image {
                    vc.image = image
                    present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (event.eventImages?.count ?? 0)
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UIImagePickerController Delegate Methods
     ====================================================================================================== */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        HUD.show(.progress)
        
        if let picture = info[UIImagePickerControllerEditedImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.event.add(eventImage: picture) {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        HUD.hide(animated: true)
                    }
                }
            }
        }
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Segue
     ====================================================================================================== */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "EditEventViewController_EDIT" {
                if let destination = segue.destination as? EditEventViewController {
                    destination.mode = .Edit(event)
                    destination.completionHandler = { parseEvent in
                        self.event = parseEvent
                        self.changed = true
                    }
                }
            } else if identifier == "AttendeeListViewController" {
                if let destination = segue.destination as? AttendeeListViewController {
                    destination.event = event
                }
            }
        }
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Private Helper Method
     ====================================================================================================== */
    private func prepareAttendeeCountLabel() {
        DispatchQueue.main.async {
            if let attendees = self.event.attendees, !attendees.isEmpty {
                self.showAttendeesButton.setTitle("\(attendees.count) attending", for: .normal)
            } else {
                self.showAttendeesButton.setTitle("", for: .normal)
            }
        }
    }
    
    private func loadEventImages() {
        if let relation = event.pfObject?.relation(forKey: C.Parse.Event.Keys.eventImages) {
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            spinner.frame = collectionView.frame
            collectionView.addSubview(spinner)
            
            spinner.startAnimating()
            
            let query = relation.query()
            query.findObjectsInBackground { pfObjects, error in
                if let pfObjects = pfObjects, !pfObjects.isEmpty {
                    self.event.eventImages = pfObjects.map { pfObject in
                        return ParseImage(pfObject: pfObject)
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
                DispatchQueue.main.async {
                    spinner.stopAnimating()
                }
            }
        }
    }
    /* ==================================================================================================== */
}
