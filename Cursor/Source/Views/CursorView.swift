//
//  CursorView.swift
//  Cursor
//
//  Created by Simon Støvring on 01/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit
import CursorKit

class CursorView: UIView {
    let stackView = UIStackView()
    let groundPlanView = GroundPlanView()
    let degreesLabel = UILabel()
    let availableDevicesLabel = UILabel()
    let buttonsStackView = UIStackView()
    let turnOnButton = UIButton(type: .System)
    let turnOffButton = UIButton(type: .System)
    
    init() {
        super.init(frame: CGRectZero)
        
        backgroundColor = .blackColor()
        
        let containerView = UIView()
        
        buttonsStackView.axis = .Horizontal
        buttonsStackView.distribution = .FillEqually
        buttonsStackView.hidden = true
        
        stackView.axis = .Vertical
        
        degreesLabel.textColor = .whiteColor()
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
        
        stackView.addArrangedSubview(groundPlanView)
        stackView.addArrangedSubview(degreesLabel)
        
        buttonsStackView.addArrangedSubview(turnOnButton)
        buttonsStackView.addArrangedSubview(turnOffButton)
        
        containerView.addSubview(stackView)
        addSubview(containerView)
        addSubview(availableDevicesLabel)
        addSubview(buttonsStackView)
        
        stackView.setEdgesEqualToSuperview()
        
        constraint(groundPlanView, .Height, .Equal, groundPlanView, .Width)
        
        containerView.setLeadingToSuperview()
        containerView.setTrailingToSuperview()
        containerView.setCenterVerticallyInSuperview()
        
        constraint(availableDevicesLabel, .Bottom, .Equal, buttonsStackView, .Top, constant: -layoutMargins.bottom)
        availableDevicesLabel.setLeadingToSuperview(relation: .GreaterThanOrEqual, constant: layoutMargins.left)
        availableDevicesLabel.setTrailingToSuperview(relation: .LessThanOrEqual, constant: -layoutMargins.right)
        availableDevicesLabel.setCenterHorizontallyInSuperview()
        
        buttonsStackView.setBottomToSuperview()
        buttonsStackView.setLeadingToSuperview()
        buttonsStackView.setTrailingToSuperview()
        
        translatesAutoresizingMaskIntoConstraints = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayAvailableDevices(availableDevices: [ControllableDevice]) {
        availableDevicesLabel.text = availableDevices.map({ $0.name }).joinWithSeparator(", ")
        availableDevicesLabel.hidden = availableDevices.count == 0
        buttonsStackView.hidden = availableDevices.count == 0
    }
    
    func displayDegrees(degrees: Double) {
        groundPlanView.compassView.pointToDegrees(degrees)
        groundPlanView.gridView.transform = CGAffineTransformMakeRotation(CGFloat(-degrees.toRadians()))
        degreesLabel.text = String(format: "%.0f°", arguments: [ degrees ])
    }
    
    func hideGroundPlan(animated animated: Bool = false) {
        UIView.perform(animated, animations: {
            self.groundPlanView.alpha = 0
        })
    }
    
    func showGroundPlan(animated animated: Bool = false) {
        UIView.perform(animated, animations: {
            self.groundPlanView.alpha = 1
        })
    }
}
