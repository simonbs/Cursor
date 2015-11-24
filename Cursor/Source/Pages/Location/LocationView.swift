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
    
    let loggingButton = UIButton(type: .System)

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
        addSubview(loggingButton)
        
        loggingButton.setTitle("Start logging", forState: .Normal)
        loggingButton.setLeadingToSuperview()
        loggingButton.setTrailingToSuperview()
        loggingButton.setHeightEqual(60)
        loggingButton.setTopToSuperview(constant: 60)
//        constraint(loggingButton, .Bottom, .Equal, availableDevicesLabel, .Top)
        
        indoorLocationView.setEdgesEqualToSuperview(cursorLayoutMargins)
        
        availableDevicesLabel.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        availableDevicesLabel.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        availableDevicesLabel.setBottomToSuperview()
        
        gestureNameLabel.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        gestureNameLabel.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        
        translatesAutoresizingMaskIntoConstraints = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayAvailableDevices(availableDevices: [Actuator]) {
        availableDevicesLabel.text = availableDevices.map({ $0.name }).joinWithSeparator(", ")
        availableDevicesLabel.hidden = availableDevices.count == 0
    }
    
    func showPointDetected() {
        backgroundColor = UIColor(red: 255/255, green: 227/255, blue: 172/255, alpha: 1)
    }
    
    func showReadyForGesture() {
        backgroundColor = UIColor(red: 207/255, green: 247/255, blue: 213/255, alpha: 1)
    }
    
    func showDefault() {
        backgroundColor = .whiteColor()
    }
}