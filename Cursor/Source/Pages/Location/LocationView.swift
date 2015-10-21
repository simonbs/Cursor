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
    let gestureButton = UIButton(type: .System)
    let gestureNameLabel = UILabel()
    
    init() {
        super.init(frame: CGRectZero)
        
        backgroundColor = .whiteColor()
        
        availableDevicesLabel.numberOfLines = 0
        availableDevicesLabel.textAlignment = .Center
        availableDevicesLabel.hidden = true
        
        gestureButton.setTitle(localize("PRESS_HOLD_TO_GESTURE"), forState: .Normal)
//        gestureButton.hidden = true
        
        addSubview(indoorLocationView)
        addSubview(availableDevicesLabel)
        addSubview(gestureButton)
        addSubview(gestureNameLabel)
        
        indoorLocationView.setEdgesEqualToSuperview(cursorLayoutMargins)
        
        gestureButton.setLeadingToSuperview()
        gestureButton.setTrailingToSuperview()
        gestureButton.setBottomToSuperview()
        gestureButton.setHeightEqual(60)
        
        availableDevicesLabel.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        availableDevicesLabel.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        constraint(availableDevicesLabel, .Bottom, .Equal, gestureButton, .Top, constant: -cursorLayoutMargins.top)
        
        gestureNameLabel.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        gestureNameLabel.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        gestureNameLabel.setTopToSuperview(constant: cursorLayoutMargins.top)
        
        translatesAutoresizingMaskIntoConstraints = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayAvailableDevices(availableDevices: [ControllableDevice]) {
        availableDevicesLabel.text = availableDevices.map({ $0.name }).joinWithSeparator(", ")
        availableDevicesLabel.hidden = availableDevices.count == 0
//        gestureButton.hidden = availableDevices.count == 0
    }
}