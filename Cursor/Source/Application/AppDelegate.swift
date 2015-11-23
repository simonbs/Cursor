//
//  AppDelegate.swift
//  Cursor
//
//  Created by Simon Støvring on 01/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import UIKit

private let EstimoteAppID = "cursor-mxo"
private let EstimoteAppToken = "909fbd6c816f629b8057e11c1724817f"

let client = Client()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ESTConfig.setupAppID(EstimoteAppID, andAppToken: EstimoteAppToken)
        GestureDB.sharedInstance()
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            NavigationController(rootViewController: LocationsViewController()),
            NavigationController(rootViewController: ActionsViewController()),
            NavigationController(rootViewController: GesturePerformanceTestViewController())
        ]
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        return true
    }
}

