//
//  AppDelegate.swift
//  MostarNet
//
//  Created by Jakub Dubrovsky on 06/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
//

import UIKit
import CoreData

import CoreSpotlight
import MobileCoreServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func openBridgeItemDetail(id: Int) {
        if let nvc = self.window?.rootViewController as? UINavigationController {
            //nvc.viewControllers = nvc.viewControllers.first
            nvc.popToRootViewControllerAnimated(false)
            
            if let vc = nvc.topViewController as? HomeViewController {
                let item = BridgeItem.item(id)
                vc.performSegueWithIdentifier("toDetail", sender: item)
            }
            
        }
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        print(userActivity.userInfo)
        if let
            id = userActivity.userInfo?["kCSSearchableItemActivityIdentifier"] as? String,
            y = Int(id)
        {
            self.openBridgeItemDetail(y)
            return true
            
        } else {
            return false
        }
        
        /**
         from web
         if uA.activityType == NSUserActivityTypeBrowsingWeb {
         if let url = uA.webPageURL {
         if let components = NSURLComponents(url: uA.webPageURL,
         resolvingAgainstBaseURL: true) {
         let path = components.path, let query = components.query {
         // Show the found item!
         }
         } }
         return true
         }
         */
        
        /**
         z vyhledavani z spotlight
         NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
         if userActivity.activityType == CSQueryContinuationActionType {
         if let searchQuery = userActivity.userInfo?[CSSearchQueryString] as? String {
         // Invoke your search UI!
         }
         return true
         }
         */
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        print(url)
        print(url.fragment)
        print(url.absoluteURL)
        print(url.lastPathComponent)
        print(url.pathComponents)
        
        print(url.path)
        print(url.relativePath)
        print(url.scheme)
        
        if ((url.pathComponents?.contains("item")) != nil),
            let id = url.lastPathComponent,
            y = Int(id) {
            
            self.openBridgeItemDetail(y)
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        
    }
    
    
}

