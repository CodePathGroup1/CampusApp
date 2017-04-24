//
//  AppDelegate.swift
//  CampusApp
//
//  Created by Aristotle on 2017-02-27.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import BATabBarController
import Parse
import ParseFacebookUtilsV4
import ParseLiveQuery
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().backIndicatorImage = UIImage()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage()

        // Initialize Parse
        Parse.initialize(with:
            ParseClientConfiguration { (configuration: ParseMutableClientConfiguration) -> Void in
                configuration.applicationId = "campus-app"
                configuration.clientKey = "ijS97M6sbiNotEj5IKhf"
                configuration.server = "https://campus-app.herokuapp.com/parse"
                configuration.isLocalDatastoreEnabled = false
            }
        )
        
        //1
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.delegate = self
        
        //2
        userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { accepted, error in
            guard accepted == true else {
                print("User declined remote notifications")
                return
            }
            //3
            application.registerForRemoteNotifications()
        }
        
        if let _ = PFUser.current() {
            window?.rootViewController = MainTabBarController()
        } else {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                window?.rootViewController = vc
            }
        }
        
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        if let currentUser = PFUser.current() {
            installation?["user"] = currentUser
        }
        installation?.saveInBackground()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if (error as NSError).code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if (UIApplication.shared.applicationState == .active) {
            if let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? BATabBarController,
                let viewControllers = tabBarVC.viewControllers {
                
                for viewController in viewControllers {
                    if let navigationController = viewController as? UINavigationController {
                        if let topVC = navigationController.topViewController as? ChatListViewController {
                            topVC.newMessageReceived = true
                        }
                    }
                }
                
            }
        } else {
            PFPush.handle(notification.request.content.userInfo)
            completionHandler(.alert)
        }
    }
}
