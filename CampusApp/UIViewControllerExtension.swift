//
//  UIViewControllerExtension.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/21/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var isModal: Bool {
        if self.presentingViewController != nil ||
            self.navigationController?.presentingViewController?.presentedViewController == self.navigationController ||
            (self.tabBarController?.presentingViewController?.isKind(of: UITabBarController.self) ?? false) {
            return true
        }
        return false
    }
    
    func showViewController(storyboardIdentifier: String, viewControllerIdentifier: String) {
        let storyboard = UIStoryboard(name: storyboardIdentifier, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier)
        present(vc, animated: true, completion: nil)
    }
}
