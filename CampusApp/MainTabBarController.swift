//
//  MainTabBarController.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/21/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    
        let eventListViewController = UIStoryboard(name: "Event", bundle: nil)
            .instantiateViewController(withIdentifier: "EventNavigationController") as? UINavigationController
        let eventListBarItem = UITabBarItem(title: "Events",
                                            image: UIImage(named: "event_tab_bar_icon"),
                                            selectedImage: nil)
        eventListViewController?.tabBarItem = eventListBarItem
        
        let chatListViewController = UIStoryboard(name: "Chat", bundle: nil)
            .instantiateViewController(withIdentifier: "ChatNavigationController") as? UINavigationController
        let chatListBarItem = UITabBarItem(title: "Chat",
                                           image: UIImage(named: "chat_tab_bar_icon"),
                                           selectedImage: nil)
        chatListViewController?.tabBarItem = chatListBarItem
        
        let profileViewController = UIStoryboard(name: "Profile", bundle: nil)
            .instantiateViewController(withIdentifier: "ProfileNavigationController") as? UINavigationController
        let profileBarItem = UITabBarItem(title: "Profile",
                                          image: UIImage(named: "profile_tab_bar_icon"),
                                          selectedImage: nil)
        profileViewController?.tabBarItem = profileBarItem
        
        if let eventListViewController = eventListViewController,
            let chatListViewController = chatListViewController,
            let profileViewController = profileViewController {
            
            self.viewControllers = [
                eventListViewController,
                chatListViewController,
                profileViewController
            ]
        } else {
            fatalError("One or more tab bars failed to load...")
        }
    }
}
