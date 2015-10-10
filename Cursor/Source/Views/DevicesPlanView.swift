//
//  DevicesPlanView.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class DevicesPlanView: UIView {
    let compassView = CompassView()
    let gridView = DevicesGridView()
    let visibilityIndicatorView = VisibilityIndicatorView()
    
    init() {
        super.init(frame: CGRectZero)
        
        gridView.backgroundColor = .clearColor()
        gridView.gridColor = UIColor(white: 1, alpha: 0.50)
        
        visibilityIndicatorView.backgroundColor = .clearColor()
        
        addSubview(compassView)
        addSubview(gridView)
        addSubview(visibilityIndicatorView)
        
        compassView.setEdgesEqualToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let compassDiameter = compassView.bounds.width
        let gridLength = sqrt(pow(compassDiameter, 2) / 2)
        let gridSize = CGRectMake(0, 0, gridLength, gridLength)
        
        gridView.bounds = gridSize
        visibilityIndicatorView.bounds = gridSize
        gridView.center = compassView.center
        visibilityIndicatorView.center = compassView.center
    }
}
