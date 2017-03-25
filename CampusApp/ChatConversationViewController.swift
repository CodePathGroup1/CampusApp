//
//  ChatConversationViewController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import AVKit
import JSQMessagesViewController
import Parse
import ParseLiveQuery
import PKHUD
import UIKit

import MediaPlayer

class ChatConversationViewController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var conversationID: String?
    
    private var users = [PFUser]()
    private var messages = [JSQMessage]()
    
    private var avatars = [String: JSQMessagesAvatarImage]()
    private var blankAvatarImage: JSQMessagesAvatarImage!
    
    private let bubbleFactory = JSQMessagesBubbleImageFactory()
    private var outgoingBubbleImage: JSQMessagesBubbleImage!
    private var incomingBubbleImage: JSQMessagesBubbleImage!
    
    private var subscription: Subscription<Message>!
    
    /* ====================================================================================================
      MARK: - Lifecycle Methods
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = PFUser.current() {
            self.senderId = user.objectId
            
            if let fullName = user[C.Parse.User.Keys.fullName] as? String {
                self.senderDisplayName = fullName
            }
        }
        
        self.blankAvatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profile_blank"), diameter: 30)
        
        self.outgoingBubbleImage = self.bubbleFactory?.outgoingMessagesBubbleImage(with: .jsq_messageBubbleBlue())
        self.incomingBubbleImage = self.bubbleFactory?.incomingMessagesBubbleImage(with: .jsq_messageBubbleLightGray())
        
        if let _ = conversationID {
            let messageQuery = getMessageQuery()
            subscription = liveQueryClient
                .subscribe(messageQuery)
                .handle(Event.created) { _, message in
                    self.add(message: message)
                }
            
            self.loadMessages(query: messageQuery)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.collectionViewLayout.springinessEnabled = true
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
      MARK: - Message-related Methods
     ====================================================================================================== */
    private func getMessageQuery() -> PFQuery<Message> {
        let query: PFQuery<Message> = PFQuery(className: C.Parse.Message.className)
        
        query.whereKey(C.Parse.Message.Keys.conversationID, equalTo: conversationID)
        if let lastMessage = messages.last {
            query.whereKey(C.Parse.Message.Keys.createdAt, equalTo: lastMessage.date)
        }
        query.includeKey(C.Parse.Message.Keys.user)
        query.order(byDescending: C.Parse.Message.Keys.createdAt)
        query.limit = 50
        
        return query
    }
    
    private func loadMessages(query: PFQuery<Message>) {
        query.findObjectsInBackground { messages, error in
            if let messages = messages {
                self.automaticallyScrollsToMostRecentMessage = false
                for message in messages {
                    self.add(message: message)
                }
                if messages.count >= 1 {
                    self.finishReceivingMessage()
                    self.scrollToBottom(animated: false)
                }
                self.automaticallyScrollsToMostRecentMessage = true
            } else {
                HUD.flash(.label(error?.localizedDescription ?? "Network error"))
            }
        }
    }
    
    private func add(message: Message) {
        if let user = message[C.Parse.Message.Keys.user] as? PFUser,
            let name = user[C.Parse.User.Keys.fullName] as? String {
            
            let jsqMessage: JSQMessage? = {
                let pictureFile = message[C.Parse.Message.Keys.picture] as? PFFile
                let videoFile = message[C.Parse.Message.Keys.video] as? PFFile
                
                if pictureFile == nil && videoFile == nil {
                    if let text = message[C.Parse.Message.Keys.text] as? String {
                        return JSQMessage(senderId: user.objectId,
                                          senderDisplayName: name,
                                          date: message.createdAt,
                                          text: text)
                    }
                }
                
                if let pictureFile = pictureFile {
                    if let mediaItem = JSQPhotoMediaItem(image: nil) {
                        mediaItem.appliesMediaViewMaskAsOutgoing = (user.objectId == self.senderId)
                        let pictureDelayedJSQMessage = JSQMessage(senderId: user.objectId,
                                                                  senderDisplayName: name,
                                                                  date: message.createdAt,
                                                                  media: mediaItem)
                        
                        pictureFile.getDataInBackground { imageData, error in
                            if let imageData = imageData, let image = UIImage(data: imageData) {
                                mediaItem.image = image
                                self.collectionView.reloadData()
                            }
                        }
                        
                        return pictureDelayedJSQMessage
                    }
                }
                
                if let videoFile = videoFile {
                    if let urlString = videoFile.url, let url = URL(string: urlString) {
                        if let mediaItem = JSQVideoMediaItem(fileURL: url, isReadyToPlay: true) {
                            mediaItem.appliesMediaViewMaskAsOutgoing = (user.objectId == self.senderId)
                            return JSQMessage(senderId: user.objectId,
                                              senderDisplayName: name,
                                              date: message.createdAt,
                                              media: mediaItem)
                        }
                    }
                }
                
                return nil
            }()
            
            if let jsqMessage = jsqMessage {
                users.append(user)
                messages.append(jsqMessage)
            }
        }
    }
    
    private func sendMessage(text: String, video: URL?, picture: UIImage?) {
        var modifiedText = text
        var pictureFile: PFFile?
        var videoFile: PFFile?
        
        if let picture = picture,
            let data = UIImageJPEGRepresentation(picture, 0.6),
            let file = PFFile(name: "picture.jpg", data: data) {
            
            modifiedText += "[Picture message]"
            pictureFile = file
            file.saveInBackground { succeed, error in
                if let error = error {
                    HUD.flash(.label(error.localizedDescription))
                }
            }
        }
        
        if let video = video,
            let data = FileManager.default.contents(atPath: video.path),
            let file = PFFile(name: "video.mp4", data: data) {
            
            modifiedText += "[Video message]"
            videoFile = file
            file.saveInBackground { succeed, error in
                if let error = error {
                    HUD.flash(.label(error.localizedDescription))
                }
            }
        }
        
        let messageObject = PFObject(className: C.Parse.Message.className)
        messageObject[C.Parse.Message.Keys.conversationID] = self.conversationID
        messageObject[C.Parse.Message.Keys.user] = PFUser.current()
        messageObject[C.Parse.Message.Keys.text] = modifiedText
        if let pictureFile = pictureFile {
            messageObject[C.Parse.Message.Keys.picture] = pictureFile
        }
        if let videoFile = videoFile {
            messageObject[C.Parse.Message.Keys.video] = videoFile
        }
        
        messageObject.saveInBackground { succeeded, error in
            if let error = error {
                HUD.flash(.label(error.localizedDescription))
            }
        }
        
        self.finishSendingMessage()
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
      MARK: - JSQMessagesViewController Methods
     ====================================================================================================== */
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        sendMessage(text: text, video: nil, picture: nil)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        view.endEditing(true)
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take photo", style: .default) { _ in
            _ = Camera.shouldStartCamera(target: self, canEdit: true, frontFacing: true)
        }
        alertVC.addAction(takePhotoAction)
        
        let chooseExistingPhotoAction = UIAlertAction(title: "Choose existing photo", style: .default) { _ in
            _ = Camera.shouldStartPhotoLibrary(target: self, mediaType: .Photo, canEdit: true)
        }
        alertVC.addAction(chooseExistingPhotoAction)
        
        let chooseExistingVideo = UIAlertAction(title: "Choose existing video", style: .default) { _ in
            _ = Camera.shouldStartPhotoLibrary(target: self, mediaType: .Video, canEdit: true)
        }
        alertVC.addAction(chooseExistingVideo)
        
        present(alertVC, animated: true, completion: nil)
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - JSQMessages CollectionView Data Source
     ====================================================================================================== */
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return nil
        }
        
        if indexPath.item >= 1 {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let user = users[indexPath.item]
        
        if let userId = user.objectId {
            if let avatar = avatars[userId] {
                return avatar
            } else {
                let avatarFile = user[C.Parse.User.Keys.avatar] as? PFFile
                avatarFile?.getDataInBackground { imageData, error in
                    if let imageData = imageData, let image = UIImage(data: imageData) {
                        self.avatars[userId] = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
                    }
                }
            }
        }
        
        return blankAvatarImage
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        if messages[indexPath.row].senderId == self.senderId {
            return outgoingBubbleImage
        } else {
            return incomingBubbleImage
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
      MARK: - UICollectionView Data Source
     ====================================================================================================== */
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell {
            let message = messages[indexPath.item]
            if message.senderId == senderId {
                cell.textView.textColor = UIColor.white
            } else {
                cell.textView.textColor = UIColor.black
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UICollectionView Flow Layout
     ====================================================================================================== */
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return 0
        }
        
        if indexPath.item >= 1 {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return 0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UICollectionView Tap Listener
     ====================================================================================================== */
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let media = message.media as? JSQVideoMediaItem {
                let playerVC = AVPlayerViewController()
                let player = AVPlayer(url: media.fileURL)
                playerVC.player = player
                player.play()
            }
        }
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UIImagePickerControllerDelegate Method
     ====================================================================================================== */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let picture = info[UIImagePickerControllerEditedImage] as? UIImage
        let video = info[UIImagePickerControllerMediaURL] as? URL
        self.sendMessage(text: "", video: video, picture: picture)
        
        picker.dismiss(animated: true, completion: nil)
    }
    /* ==================================================================================================== */
}
