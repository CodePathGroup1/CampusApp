//
//  Camera.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/25/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import MobileCoreServices

final class Camera {
    
    enum MediaType {
        case Photo, Video
    }
    
    class func shouldStartCamera(target: AnyObject, canEdit: Bool, frontFacing: Bool) -> Bool {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return false
        }
        
        let type = kUTTypeImage as String
        let cameraUI = UIImagePickerController()
        
        let available = UIImagePickerController.isSourceTypeAvailable(.camera) &&
            (UIImagePickerController.availableMediaTypes(for: .camera)?.contains(type) ?? false)
        
        if available {
            cameraUI.mediaTypes = [type]
            cameraUI.sourceType = .camera
            
            if frontFacing {
                if UIImagePickerController.isCameraDeviceAvailable(.front) {
                    cameraUI.cameraDevice = .front
                } else if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                    cameraUI.cameraDevice = .rear
                }
            } else {
                if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                    cameraUI.cameraDevice = .rear
                } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
                    cameraUI.cameraDevice = .front
                }
            }
        } else {
            return false
        }
        
        cameraUI.allowsEditing = canEdit
        cameraUI.showsCameraControls = true
        if let target = target as? UINavigationControllerDelegate & UIImagePickerControllerDelegate {
            cameraUI.delegate = target
        }
        
        target.present(cameraUI, animated: true, completion: nil)
        
        return true
    }
    
    class func shouldStartPhotoLibrary(target: AnyObject, mediaType: MediaType, canEdit: Bool) -> Bool {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) &&
            !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            return false
        }
        
        let type: String = {
            switch mediaType {
            case .Photo:
                return kUTTypeImage as String
            case .Video:
                return kUTTypeMovie as String
            }
        }()
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) &&
            (UIImagePickerController.availableMediaTypes(for: .photoLibrary)?.contains(type) ?? false) {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = .photoLibrary
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) &&
            (UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)?.contains(type) ?? false) {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = .savedPhotosAlbum
        } else {
            return false
        }
        
        imagePicker.allowsEditing = canEdit
        if let target = target as? UINavigationControllerDelegate & UIImagePickerControllerDelegate {
            imagePicker.delegate = target
        }
        
        target.present(imagePicker, animated: true, completion: nil)
        
        return true
    }
}
