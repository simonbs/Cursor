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
    var title: String? = nil
    
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
        
        if let title = title {
            let attr = [
                NSFontAttributeName: UIFont.boldSystemFontOfSize(18),
                NSForegroundColorAttributeName: UIColor.blackColor()
            ]
            
            let titleStr = title as NSString
            let size = titleStr.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: [], attributes: attr, context: nil)
            let titleRect = CGRectMake((rect.width - size.width) / 2, (rect.height - size.height) / 2, size.width, size.height)
            titleStr.drawInRect(titleRect, withAttributes: attr)
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(30, 30)
    }
}