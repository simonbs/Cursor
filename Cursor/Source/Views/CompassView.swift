//
//  CompassView.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class CompassView: UIView {
    private let compassRoseView = CompassRoseView()
    
    init() {
        super.init(frame: CGRectZero)
        
        compassRoseView.backgroundColor = .whiteColor()
        compassRoseView.compassColor = UIColor(white: 0.20, alpha: 1)
        addSubview(compassRoseView)
        compassRoseView.setEdgesEqualToSuperview()
        
        translatesAutoresizingMaskIntoConstraints = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pointToDegrees(degrees: Double) {
        compassRoseView.transform = CGAffineTransformMakeRotation(CGFloat(-degrees.toRadians()))
        compassRoseView.rotateCardinalDirections(degrees)
    }
}