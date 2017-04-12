//
//  UIWindowExtension.swift
//  CampusApp
//
//  Created by Thomas Zhu on 4/11/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    class func showMessage(title: String?, message: String?) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            ac.addAction(okAction)
            
            if let vc = UIApplication.shared.keyWindow?.rootViewController {
                vc.present(ac, animated: true, completion: nil)
            }
        }
    }
}
