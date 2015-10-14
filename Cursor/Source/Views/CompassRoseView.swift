//
//  CompassBackgroundView.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class CompassRoseView: UIView {
    var compassColor: UIColor = .lightGrayColor()
    private let northLabel = UILabel()
    private let eastLabel = UILabel()
    private let southLabel = UILabel()
    private let westLabel = UILabel()

    init() {
        super.init(frame: CGRectZero)
        
        northLabel.textColor = .redColor()
        eastLabel.textColor = .blackColor()
        southLabel.textColor = .blackColor()
        westLabel.textColor = .blackColor()
        
        northLabel.font = .boldSystemFontOfSize(17)
        eastLabel.font = .boldSystemFontOfSize(17)
        southLabel.font = .boldSystemFontOfSize(17)
        westLabel.font = .boldSystemFontOfSize(17)
        
        northLabel.text = localize("NORTH_SHORT")
        eastLabel.text = localize("EAST_SHORT")
        southLabel.text = localize("SOUTH_SHORT")
        westLabel.text = localize("WEST_SHORT")
        
        addSubview(northLabel)
        addSubview(eastLabel)
        addSubview(southLabel)
        addSubview(westLabel)
        
        northLabel.setTopToSuperview(constant: cursorLayoutMargins.top)
        northLabel.setCenterHorizontallyInSuperview()
        eastLabel.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        eastLabel.setCenterVerticallyInSuperview()
        southLabel.setBottomToSuperview(constant: -cursorLayoutMargins.bottom)
        southLabel.setCenterHorizontallyInSuperview()
        westLabel.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        westLabel.setCenterVerticallyInSuperview()
        
        translatesAutoresizingMaskIntoConstraints = true
    }
      
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        
        CGContextSetFillColorWithColor(context, backgroundColor?.CGColor)
        CGContextFillRect(context, rect)
        
        CGContextSetFillColorWithColor(context, compassColor.CGColor)
        CGContextFillEllipseInRect(context, rect)
    }
    
    func rotateCardinalDirections(degrees: Double) {
        let transform = CGAffineTransformMakeRotation(CGFloat(degrees.toRadians()))
        northLabel.transform = transform
        eastLabel.transform = transform
        southLabel.transform = transform
        westLabel.transform = transform
    }
}