//
//  UIView.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    // layoutMargins are only available on iOS7<, therefore we introduce our own.
    var cursorLayoutMargins: UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    class func animate(duration: NSTimeInterval = 0.30, delay: NSTimeInterval = 0, options: UIViewAnimationOptions = [ .BeginFromCurrentState ], animations: Void -> Void, completion: (Bool -> Void)? = nil) {
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: animations, completion: completion)
    }
    
    class func transition(view: UIView, duration: NSTimeInterval = 0.30, options: UIViewAnimationOptions = [ .TransitionCrossDissolve, .BeginFromCurrentState ], animations: Void -> Void, completion: (Bool -> Void)? = nil) {
        UIView.transitionWithView(view, duration: duration, options: options, animations: animations, completion: completion)
    }
    
    func transition(duration: NSTimeInterval = 0.30, options: UIViewAnimationOptions = [ .TransitionCrossDissolve, .BeginFromCurrentState ], animations: Void -> Void, completion: (Bool -> Void)? = nil) {
        UIView.transitionWithView(self, duration: duration, options: options, animations: animations, completion: completion)
    }
    
    class func perform(animated: Bool, duration: NSTimeInterval = 0.30, delay: NSTimeInterval = 0, options: UIViewAnimationOptions = [ .TransitionCrossDissolve, .BeginFromCurrentState ], animations: Void -> Void, completion: (Bool -> Void)? = nil) {
        if animated {
            UIView.animate(duration, delay: delay, options: options, animations: animations, completion: completion)
        } else {
            animations()
            completion?(true)
        }
    }
}