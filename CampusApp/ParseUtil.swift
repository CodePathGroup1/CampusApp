//
//  ParseClient.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit
import Parse

final class ParseUtil {
    
    private init() {}
    
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        if let image = image {
            func resize(image: UIImage, newScale: CGFloat) -> UIImage? {
                let size = image.size
                let resizeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width * newScale, height: size.height * newScale))
                resizeImageView.contentMode = UIViewContentMode.scaleAspectFill
                resizeImageView.image = image
                
                UIGraphicsBeginImageContext(resizeImageView.frame.size)
                resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return newImage
            }
            
            if let resizedImage = resize(image: image, newScale: 0.5) {
                if let imageData = UIImagePNGRepresentation(resizedImage) {
                    return PFFile(name: "image.png", data: imageData)
                }
            }
        }
        return nil
    }
}
