//
//  DeviceObjectView.swift
//  Cursor
//
//  Created by Simon Støvring on 15/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class DeviceObjectView: UIView {
    var fillColor: UIColor = .orangeColor()
    
    init() {
        super.init(frame: CGRectZero)
        backgroundColor = .clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, fillColor.CGColor)
        CGContextFillEllipseInRect(context, rect)
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(30, 30)
    }
}