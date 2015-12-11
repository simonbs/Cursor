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
    /// layoutMargins are only available on iOS7<, therefore we introduce our own.
    var cursorLayoutMargins: UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    /**
     Perform an animation.
     
     - Parameter duration: Duration of the animation. Defaults to 0.3 seconds.
     - Parameter delay: Delay before performing the animation. Defaults to zero seconds.
     - Parameter options: Options to supply to the animation. Defaults to .BeginFormCurrentState.
     - Parameter animations: Animation block to perform.
     - Parameter completion: Optionally supply a closure to be called upon completion of the animation.
     */
    class func animate(duration: NSTimeInterval = 0.3, delay: NSTimeInterval = 0, options: UIViewAnimationOptions = [ .BeginFromCurrentState ], animations: Void -> Void, completion: (Bool -> Void)? = nil) {
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: animations, completion: completion)
    }
}