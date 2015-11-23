//
//  GesturePerformanceTestView.swift
//  Cursor
//
//  Created by Kasper Lind Sørensen on 23/11/15.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class GesturePerformanceTestView: UIView {
    let titleLabel = UILabel()
    let startTestButton = UIButton(type: .System)
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    init() {
        super.init(frame: CGRectZero)
        backgroundColor = .whiteColor()
        
        let containerView = UIView()
        addSubview(containerView)
        
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0
        titleLabel.font = .boldSystemFontOfSize(17)
        containerView.addSubview(titleLabel)
        
        startTestButton.setTitle(localize("PRESS_HOLD_TO_TRAIN"), forState: .Normal)
        containerView.addSubview(startTestButton)

        activityIndicator.color = .blackColor()
        addSubview(activityIndicator)
        
        containerView.setLeadingToSuperview()
        containerView.setTrailingToSuperview()
        containerView.setCenterVerticallyInSuperview()
        
        titleLabel.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        titleLabel.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        titleLabel.setTopToSuperview()
        
        startTestButton.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        startTestButton.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        containerView.constraint(startTestButton, .Top, .Equal, titleLabel, .Bottom, constant: cursorLayoutMargins.top)
        
        
        activityIndicator.setCenterHorizontallyInSuperview()
        constraint(activityIndicator, .Top, .Equal, containerView, .Bottom, constant: cursorLayoutMargins.top)
        
        translatesAutoresizingMaskIntoConstraints = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}