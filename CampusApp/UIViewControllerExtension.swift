//
//  UIViewControllerExtension.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/21/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import BATabBarController
import UIKit

extension UIViewController {
    
    var isModal: Bool {
        if self.presentingViewController != nil ||
            self.navigationController?.presentingViewController?.presentedViewController == self.navigationController ||
            (self.tabBarController?.presentingViewController?.isKind(of: BATabBarController.self) ?? false) {
            return true
        }
        return false
    }
    
//    func showMessage(title: String?, message: String?) {
//        DispatchQueue.main.async {
//            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            ac.addAction(okAction)
//            
//            self.present(ac, animated: true, completion: nil)
//        }
//    }
}
