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
//    let turnOnButton = UIButton(type: .System)
//    let turnOffButton = UIButton(type: .System)
    let gestureButton = UIButton(type: .System)
    
    init() {
        super.init(frame: CGRectZero)
        
        backgroundColor = .whiteColor()
        
        availableDevicesLabel.numberOfLines = 0
        availableDevicesLabel.textAlignment = .Center
        availableDevicesLabel.hidden = true
        
//        turnOnButton.titleLabel?.font = .boldSystemFontOfSize(18)
//        turnOffButton.titleLabel?.font = .boldSystemFontOfSize(18)
//        
//        turnOnButton.backgroundColor = .lightGrayColor()
//        turnOffButton.backgroundColor = .lightGrayColor()
//        
//        turnOnButton.tintColor = ControllableDevice.State.On.color
//        turnOffButton.tintColor = ControllableDevice.State.Off.color
//        
//        turnOnButton.setTitle(localize("TURN_ON"), forState: .Normal)
//        turnOffButton.setTitle(localize("TURN_OFF"), forState: .Normal)
//        
//        turnOnButton.hidden = true
//        turnOffButton.hidden = true
        
        gestureButton.setTitle(localize("PRESS_HOLD_TO_GESTURE"), forState: .Normal)
        
        addSubview(indoorLocationView)
        addSubview(availableDevicesLabel)
//        addSubview(turnOnButton)
//        addSubview(turnOffButton)
        addSubview(gestureButton)
        
        indoorLocationView.setEdgesEqualToSuperview(cursorLayoutMargins)
        
        gestureButton.setLeadingToSuperview()
        gestureButton.setTrailingToSuperview()
        gestureButton.setBottomToSuperview()
        gestureButton.setHeightEqual(60)
        
        availableDevicesLabel.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        availableDevicesLabel.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        constraint(availableDevicesLabel, .Bottom, .Equal, gestureButton, .Top, constant: -cursorLayoutMargins.top)
        
//        turnOnButton.setLeadingToSuperview()
//        turnOnButton.setBottomToSuperview()
//        turnOnButton.setHeightEqual(60)
//        constraint(turnOnButton, .Trailing, .Equal, self, .CenterX)
//        
//        turnOffButton.setTrailingToSuperview()
//        turnOffButton.setBottomToSuperview()
//        turnOffButton.setHeightEqual(60)
//        constraint(turnOffButton, .Leading, .Equal, self, .CenterX)
        
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