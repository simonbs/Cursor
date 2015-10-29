//
//  LocationView.swift
//  Cursor
//
//  Created by Simon Støvring on 10/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class LocationView: UIView {
    let indoorLocationView = ESTIndoorLocationView()
    let availableDevicesLabel = UILabel()
    let gestureNameLabel = UILabel()
    
    init() {
        super.init(frame: CGRectZero)
        
        backgroundColor = .whiteColor()
        
        availableDevicesLabel.numberOfLines = 0
        availableDevicesLabel.textAlignment = .Center
        availableDevicesLabel.hidden = true
        
        gestureNameLabel.textAlignment = .Center
        
        addSubview(indoorLocationView)
        addSubview(availableDevicesLabel)
        addSubview(gestureNameLabel)
        
        indoorLocationView.setEdgesEqualToSuperview(cursorLayoutMargins)
        
        availableDevicesLabel.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        availableDevicesLabel.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        availableDevicesLabel.setBottomToSuperview(constant: -cursorLayoutMargins.bottom)
        
        gestureNameLabel.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        gestureNameLabel.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        
        translatesAutoresizingMaskIntoConstraints = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayAvailableDevices(availableDevices: [ControllableDevice]) {
        availableDevicesLabel.text = availableDevices.map({ $0.name }).joinWithSeparator(", ")
        availableDevicesLabel.hidden = availableDevices.count == 0
    }

    func showReadyForGesture() {
        backgroundColor = UIColor(red: 182/255, green: 255/255, blue: 170/255, alpha: 1)
    }
    
    func showNotReadyForGesture() {
        backgroundColor = .whiteColor()
    }
}