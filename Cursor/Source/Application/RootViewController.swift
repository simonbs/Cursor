//
//  RootViewController.swift
//  Cursor
//
//  Created by Simon Støvring on 18/09/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import UIKit

extension UIViewController {
    var rootViewController: RootViewController? {
        var vc: UIViewController = self
        while !vc.isKindOfClass(RootViewController) {
            if let parent = vc.parentViewController {
                vc = parent
            } else {
                if let presentingParent = vc.presentingViewController {
                    vc = presentingParent
                } else {
                    return nil
                }
            }
        }
        
        return vc as? RootViewController
    }
    
    var client: Client? {
        return rootViewController?.cursorClient
    }
}

class RootViewController: UIViewController {
    let cursorClient = Client()
    
    override var tabBarController: UITabBarController {
        return childViewControllers.first as! UITabBarController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationController = UINavigationController(rootViewController: LocationsViewController())
        navigationController.navigationBar.barStyle = .Black
        navigationController.navigationBar.tintColor = .whiteColor()
        
        addChildViewController(navigationController)
        view.addSubview(navigationController.view)
        navigationController.didMoveToParentViewController(self)
        navigationController.view.setEdgesEqualToSuperview()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

