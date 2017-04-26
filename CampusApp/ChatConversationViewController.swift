//
//  ChatConversationViewController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/22/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import AVKit
import AVFoundation
import JSQMessagesViewController
import Parse
import ParseLiveQuery
import PKHUD
import UIKit
import UserNotifications

class ChatConversationViewController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var conversation: PFObject!
    
    var completion: ((PFObject) -> Void)?
    
    private var users = [User]()
    private var messages = [JSQMessage]()
    
    private var avatars = [String: JSQMessagesAvatarImage]()
    private let blankAvatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profile_blank"), diameter: 30)
    
    private let bubbleFactory = JSQMessagesBubbleImageFactory()
    private var outgoingBubbleImage: JSQMessagesBubbleImage!
    private var incomingBubbleImage: JSQMessagesBubbleImage!
    
    private var subscription: Subscription<Message>!
    
    /* ====================================================================================================
      MARK: - Lifecycle Methods
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_arrow"),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationItem.title = "CONVERSATION"
        
        if let user = PFUser.current() {
            if let otherUser = self.users.filter({ return $0.pfObject.objectId != user.objectId }).first {
                navigationItem.title = otherUser.fullName ?? "CONVERSATION"
            }
            
            self.senderId = user.objectId
            
            if let fullName = user[C.Parse.User.Keys.fullName] as? String, !fullName.isEmpty {
                self.senderDisplayName = fullName
            } else if let username = user.username, !username.isEmpty {
                self.senderDisplayName = username
            }
        }
        
        self.outgoingBubbleImage = self.bubbleFactory?.outgoingMessagesBubbleImage(with: .jsq_messageBubbleBlue())
        self.incomingBubbleImage = self.bubbleFactory?.incomingMessagesBubbleImage(with: .jsq_messageBubbleLightGray())
        
        Message.registerSubclass()
        
        let messageQuery = getMessageQuery()
        subscription = ParseLiveQuery.Client.shared
            .subscribe(messageQuery)
            .handle(Event.created)  { query, pfMessage in
                // Note: DO NOT call add(message:) directly -- Parse Live Query doesn't work well with includeKey yet
                self.loadMessages(query: self.getMessageQuery())
        }
        
        if self.isModal {
            let closeButton: UIButton = {
                let button = UIButton(frame: CGRect(x: 24, y: 24, width: 25, height: 25))
                button.addTarget(self, action: #selector(self.closeButtonTapped), for: .touchUpInside)
                button.adjustsImageWhenHighlighted = false
                button.setImage(UIImage(named: "close_button"), for: .normal)
                button.setTitle("", for: .normal)
                return button
            }()
            self.view.addSubview(closeButton)
        }
        
        HUD.show(.label("Loading messages..."))
        self.loadMessages(query: messageQuery)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        inputToolbar.contentView.textView.becomeFirstResponder()
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Close Button Behavior
     ====================================================================================================== */
    func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
      MARK: - Message-related Methods
     ====================================================================================================== */
    private func getMessageQuery() -> PFQuery<Message> {
        let query: PFQuery<Message> = PFQuery(className: C.Parse.Message.className)
        query.whereKey(C.Parse.Message.Keys.conversation, equalTo: conversation)
        if let lastMessage = messages.last, let lastMessageDate = lastMessage.date {
            query.whereKey(C.Parse.Message.Keys.createdAt, greaterThan: lastMessageDate)
        }
        query.includeKey(C.Parse.Message.Keys.user)
        query.order(byDescending: C.Parse.Message.Keys.createdAt)
        query.limit = 50
        
        return query
    }
    
    private func loadMessages(query: PFQuery<Message>) {
        query.findObjectsInBackground { pfMessages, error in
            if let pfMessages = pfMessages {
                if !pfMessages.isEmpty {
                    self.add(pfMessages: pfMessages.reversed())
                } else {
                    HUD.hide(animated: false)
                }
            } else {
                HUD.hide(animated: false)
                UIWindow.showMessage(title: "Error",
                                     message: error?.localizedDescription ?? "Network error")
            }
        }
    }
    
    private func add(pfMessages: [PFObject]) {
        
        func add(pfMessage: PFObject) {
            if let pfUserObject = pfMessage[C.Parse.Message.Keys.user] as? PFObject {
                let author = User(pfObject: pfUserObject)
                
                if let authorID = author.id, let authorFullName = author.fullName {
                    let jsqMessage: JSQMessage? = {
                        let pictureFile = pfMessage[C.Parse.Message.Keys.picture] as? PFFile
                        let videoFile = pfMessage[C.Parse.Message.Keys.video] as? PFFile
                        
                        if pictureFile == nil && videoFile == nil {
                            if let text = pfMessage[C.Parse.Message.Keys.text] as? String {
                                return JSQMessage(senderId: authorID,
                                                  senderDisplayName: authorFullName,
                                                   date: pfMessage.createdAt,
                                                  text: text)
                            }
                        }
                        
                        if let pictureFile = pictureFile {
                            if let mediaItem = JSQPhotoMediaItem(image: nil) {
                                mediaItem.appliesMediaViewMaskAsOutgoing = (authorID == self.senderId)
                                let pictureDelayedJSQMessage = JSQMessage(senderId: authorID,
                                                                          senderDisplayName: authorFullName,
                                                                          date: pfMessage.createdAt,
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
                                    mediaItem.appliesMediaViewMaskAsOutgoing = (authorID == self.senderId)
                                    return JSQMessage(senderId: authorID,
                                                      senderDisplayName: authorFullName,
                                                      date: pfMessage.createdAt,
                                                      media: mediaItem)
                                }
                            }
                        }
                        
                        return nil
                    }()
                    
                    if let jsqMessage = jsqMessage {
                        self.users.append(author)
                        self.messages.append(jsqMessage)
                    }
                }
            }
        }
    
        for pfMessage in pfMessages {
            add(pfMessage: pfMessage)
        }
    
        if pfMessages.count >= 1 {
            self.scrollToBottom(animated: false)
            self.finishReceivingMessage()
            
            if let lastMessage = pfMessages.last {
                self.conversation[C.Parse.Conversation.Keys.lastMessage] = lastMessage
                self.conversation[C.Parse.Conversation.Keys.lastMessageTimestamp] = lastMessage.createdAt
                self.conversation[C.Parse.Conversation.Keys.lastUser] = lastMessage[C.Parse.Message.Keys.user] as? PFUser
                self.completion?(self.conversation)
            }
            
            HUD.hide(animated: true)
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
                HUD.hide(animated: false)
                UIWindow.showMessage(title: "Error",
                                     message: error?.localizedDescription ?? "Unknown error")
            }
        }
        
        if let video = video,
            let data = FileManager.default.contents(atPath: video.path),
            let file = PFFile(name: "video.mp4", data: data) {
            
            modifiedText += "[Video message]"
            videoFile = file
            file.saveInBackground { succeed, error in
                if let error = error {
                    HUD.hide(animated: false)
                    UIWindow.showMessage(title: "Error",
                                         message: error.localizedDescription)
                }
            }
        }
        
        if let currentUser = PFUser.current() {
            let messageObject = PFObject(className: C.Parse.Message.className)
            messageObject[C.Parse.Message.Keys.conversation] = conversation
            messageObject[C.Parse.Message.Keys.user] = currentUser
            messageObject[C.Parse.Message.Keys.text] = modifiedText
            if let pictureFile = pictureFile {
                messageObject[C.Parse.Message.Keys.picture] = pictureFile
            }
            if let videoFile = videoFile {
                messageObject[C.Parse.Message.Keys.video] = videoFile
            }
            
            messageObject.saveInBackground { succeeded, error in
                if succeeded {
                    self.finishSendingMessage()
                    
                    self.conversation[C.Parse.Conversation.Keys.lastMessage] = messageObject
                    self.conversation[C.Parse.Conversation.Keys.lastMessageTimestamp] = messageObject.createdAt
                    self.conversation[C.Parse.Conversation.Keys.lastUser] = currentUser
                    self.completion?(self.conversation)
                    
                    self.conversation.saveInBackground { succeeded, error in
                        if succeeded {
                            if let currentUser = PFUser.current() {
                                let users = self.conversation[C.Parse.Conversation.Keys.users] as? [PFUser]
                                let otherUsers = users?.filter { user in
                                    return user.objectId != currentUser.objectId
                                }
                                
                                if let otherUser = otherUsers?.first {
                                    PFCloud.callFunction(inBackground: "push",
                                                         withParameters: ["objectId": otherUser.objectId!,
                                                                          "message": modifiedText])
                                }
                            }
                        } else {
                            UIWindow.showMessage(title: "Error",
                                                 message: error?.localizedDescription ?? "Unknown Error")
                        }
                    }
                } else {
                    HUD.hide(animated: false)
                    UIWindow.showMessage(title: "Error",
                                         message: error?.localizedDescription ?? "Failed to send message")
                }
            }
        }
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
        
        let chooseExistingVideoAction = UIAlertAction(title: "Choose existing video", style: .default) { _ in
            _ = Camera.shouldStartPhotoLibrary(target: self, mediaType: .Video, canEdit: true)
        }
        alertVC.addAction(chooseExistingVideoAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertVC.addAction(cancelAction)
        
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
        let pfObject = self.users[indexPath.item].pfObject
        
        if let objectId = pfObject.objectId {
            if self.avatars[objectId] == nil {
                let thumbnailFile = pfObject[C.Parse.User.Keys.avatar] as? PFFile
                thumbnailFile?.getDataInBackground { data, error in
                    if let data = data {
                        self.avatars[objectId] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: data), diameter: 30)
                    } else {
                        self.avatars[objectId] = self.blankAvatarImage
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            } else {
                return self.avatars[objectId]
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
                cell.textView?.textColor = .white
            } else {
                cell.textView?.textColor = .black
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
                if let fileURL = media.fileURL {
                    let playerVC = AVPlayerViewController()
                    
                    let asset = AVURLAsset(url: fileURL)
                    let item = AVPlayerItem(asset: asset)
                    
                    let player = AVPlayer(playerItem: item)
                    playerVC.player = player
                    playerVC.showsPlaybackControls = true
                    
                    self.present(playerVC, animated: true) {
                        player.play()
                    }
                }
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
