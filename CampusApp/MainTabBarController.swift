//
//  MainTabBarController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/21/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import BATabBarController
import Parse
import UIKit

class MainTabBarController: BATabBarController, BATabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let attributes: [String: Any] = [NSFontAttributeName: UIFont(name: "JosefinSans", size: 10.0)!,
                                         NSForegroundColorAttributeName: UIColor.white]
        
        let eventListViewController = UIStoryboard(name: "Event", bundle: nil)
            .instantiateViewController(withIdentifier: "EventNavigationController") as? UINavigationController
        let eventListBarTitle = NSMutableAttributedString(string: "EVENTS", attributes: attributes)
        let eventListBarItem = BATabBarItem(image: UIImage(named: "event_tab_bar_icon"),
                                            selectedImage: UIImage(named: "event_tab_bar_icon"),
                                            title: eventListBarTitle)
        
        let chatListViewController = UIStoryboard(name: "Chat", bundle: nil)
            .instantiateViewController(withIdentifier: "ChatNavigationController") as? UINavigationController
        let chatListBarTitle = NSMutableAttributedString(string: "CHAT", attributes: attributes)
        let chatListBarItem = BATabBarItem(image: UIImage(named: "chat_tab_bar_icon"),
                                           selectedImage: UIImage(named: "chat_tab_bar_icon"),
                                           title: chatListBarTitle)
        
        let profileViewController = UIStoryboard(name: "Profile", bundle: nil)
            .instantiateViewController(withIdentifier: "ProfileNavigationController") as? UINavigationController
        let profileBarTitle = NSMutableAttributedString(string: "PROFILE", attributes: attributes)
        let profileBarItem = BATabBarItem(image: UIImage(named: "profile_tab_bar_icon"),
                                          selectedImage: UIImage(named: "profile_tab_bar_icon"),
                                          title: profileBarTitle)
        
        if let eventListViewController = eventListViewController,
            let chatListViewController = chatListViewController,
            let profileViewController = profileViewController,
            let eventListBarItem = eventListBarItem,
            let chatListBarItem = chatListBarItem,
            let profileBarItem = profileBarItem {
            
            self.delegate = self
            self.tabBarBackgroundColor = UIColor(red: 67.0/255, green: 80.0/255, blue: 116.0/255, alpha: 1)
            self.tabBarItemStrokeColor = .white
            self.tabBarItemLineWidth = 1.0
            
            self.viewControllers = [
                eventListViewController,
                chatListViewController,
                profileViewController
            ]
            
            self.tabBarItems = [
                eventListBarItem,
                chatListBarItem,
                profileBarItem
            ]
        } else {
            fatalError("One or more tab bars failed to load...")
        }
        
        if let installation = PFInstallation.current(), installation["user"] == nil,
            let currentUser = PFUser.current() {
            
            installation["user"] = currentUser
            installation.saveInBackground()
        }
    }
    
    func tabBarController(_ tabBarController: BATabBarController!, didSelect viewController: UIViewController!) {
        if let navigationController = tabBarController.selectedViewController as? UINavigationController {
            if let chatListVC = navigationController.topViewController as? ChatListViewController {
                chatListVC.loadConversations()
            }
        }
    }
}
