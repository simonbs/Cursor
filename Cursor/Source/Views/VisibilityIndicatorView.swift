//
//  VisibilityIndicatorView.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class VisibilityIndicatorView: UIView {
    var angle: Float = 45 {
        didSet { setNeedsDisplay() }
    }
    var topColor: UIColor = UIColor(white: 1, alpha: 0) {
        didSet { setNeedsDisplay() }
    }
    var bottomColor: UIColor = UIColor(white: 1, alpha: 0.60) {
        didSet { setNeedsDisplay() }
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        
        CGContextSetFillColorWithColor(context, backgroundColor?.CGColor)
        CGContextFillRect(context, rect)
        
        // Calculate widest width of indicator (that is, width at top) given an angle.
        // Illustration available at http://d.4su.re/1dl3I
        let indicatorHeight = rect.height / 2
        let y = indicatorHeight / cos(CGFloat(Double(angle / 2).toRadians()))
        let indicatorWidth = y * sin(CGFloat(Double(angle / 2).toRadians()))
        
        let indicatorRect = CGRectIntegral(CGRectMake((rect.width - indicatorWidth) / 2, 0, indicatorWidth, indicatorHeight))
        
        let directionPath = CGPathCreateMutable()
        CGContextMoveToPoint(context, indicatorRect.minX, indicatorRect.minY)
        CGContextAddLineToPoint(context, indicatorRect.maxX, indicatorRect.minY)
        CGContextAddLineToPoint(context, indicatorRect.midX, indicatorRect.maxY)
        CGPathCloseSubpath(directionPath)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [ topColor.CGColor, bottomColor.CGColor ]
        let gradient = CGGradientCreateWithColors(colorSpace, colors, [ 0, 1 ])
        
        CGContextAddPath(context, directionPath)
        CGContextClip(context)
        CGContextAddEllipseInRect(context, rect)
        CGContextClip(context)
        CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, rect.midY), [])
    }
}