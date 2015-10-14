//
//  CursorView.swift
//  Cursor
//
//  Created by Simon Støvring on 01/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class CursorView: UIView {
    let devicesPlanView = DevicesPlanView()
    let degreesLabel = UILabel()
    let availableDevicesLabel = UILabel()
    let turnOnButton = UIButton(type: .System)
    let turnOffButton = UIButton(type: .System)
    
    init() {
        super.init(frame: CGRectZero)
        
        backgroundColor = .whiteColor()
        
        let containerView = UIView()
        
        degreesLabel.textColor = .blackColor()
        degreesLabel.font = .systemFontOfSize(64)
        degreesLabel.textAlignment = .Center
        
        availableDevicesLabel.textColor = .orangeColor()
        availableDevicesLabel.numberOfLines = 0
        availableDevicesLabel.textAlignment = .Center
        availableDevicesLabel.hidden = true
        
        turnOnButton.tintColor = .greenColor()
        turnOffButton.tintColor = .redColor()
        
        turnOnButton.setTitle(localize("TURN_ON"), forState: .Normal)
        turnOffButton.setTitle(localize("TURN_OFF"), forState: .Normal)
        
        containerView.addSubview(devicesPlanView)
        containerView.addSubview(degreesLabel)
        addSubview(containerView)
        addSubview(availableDevicesLabel)
        addSubview(turnOnButton)
        addSubview(turnOffButton)
        
        devicesPlanView.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        devicesPlanView.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        devicesPlanView.setTopToSuperview()
        containerView.constraint(devicesPlanView, .Height, .Equal, devicesPlanView, .Width)
        
        degreesLabel.setLeadingToSuperview()
        degreesLabel.setTrailingToSuperview()
        degreesLabel.setBottomToSuperview()
        containerView.constraint(degreesLabel, .Top, .Equal, devicesPlanView, .Bottom, constant: 10)
        
        containerView.setLeadingToSuperview()
        containerView.setTrailingToSuperview()
        containerView.setCenterVerticallyInSuperview()
        
        turnOnButton.setLeadingToSuperview()
        turnOnButton.setBottomToSuperview()
        constraint(turnOnButton, .Trailing, .Equal, self, .CenterX)
        
        turnOffButton.setTrailingToSuperview()
        turnOffButton.setBottomToSuperview()
        constraint(turnOffButton, .Leading, .Equal, self, .CenterX)
        
        translatesAutoresizingMaskIntoConstraints = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayAvailableDevices(availableDevices: [ControllableDevice]) {
        availableDevicesLabel.text = availableDevices.map({ $0.name }).joinWithSeparator(", ")
        availableDevicesLabel.hidden = availableDevices.count == 0
        turnOnButton.hidden = availableDevices.count == 0
        turnOffButton.hidden = availableDevices.count == 0
    }
    
    func displayDegrees(degrees: Double) {
        devicesPlanView.compassView.pointToDegrees(degrees)
        devicesPlanView.gridView.transform = CGAffineTransformMakeRotation(CGFloat(-degrees.toRadians()))
        degreesLabel.text = String(format: "%.0f°", arguments: [ degrees ])
    }
    
    func hideGroundPlan(animated animated: Bool = false) {
        UIView.perform(animated, animations: {
            self.devicesPlanView.alpha = 0
        })
    }
    
    func showGroundPlan(animated animated: Bool = false) {
        UIView.perform(animated, animations: {
            self.devicesPlanView.alpha = 1
        })
    }
}
