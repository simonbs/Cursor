//
//  GestureTrainingView.swift
//  Cursor
//
//  Created by Simon Støvring on 20/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class GestureTrainingView: UIView {
    let gestureNameLabel = UILabel()
    let trainButton = UIButton(type: .System)
    let trainCountLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var trainCount = 0 {
        didSet { updateDisplayedTrainCount() }
    }
    
    init() {
        super.init(frame: CGRectZero)
        backgroundColor = .whiteColor()
        
        let containerView = UIView()
        addSubview(containerView)
        
        gestureNameLabel.textAlignment = .Center
        gestureNameLabel.numberOfLines = 0
        gestureNameLabel.font = .boldSystemFontOfSize(17)
        containerView.addSubview(gestureNameLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.textAlignment = .Center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = localize("GESTURE_TRAINING_DESCRIPTION")
        containerView.addSubview(descriptionLabel)
        
        trainButton.setTitle(localize("PRESS_HOLD_TO_TRAIN"), forState: .Normal)
        containerView.addSubview(trainButton)
        
        trainCountLabel.textColor = .darkGrayColor()
        trainCountLabel.textAlignment = .Center
        trainCountLabel.numberOfLines = 0
        trainCountLabel.alpha = 0
        containerView.addSubview(trainCountLabel)
        
        activityIndicator.color = .blackColor()
        addSubview(activityIndicator)
        
        containerView.setLeadingToSuperview()
        containerView.setTrailingToSuperview()
        containerView.setCenterVerticallyInSuperview()

        gestureNameLabel.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        gestureNameLabel.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        gestureNameLabel.setTopToSuperview()
        
        descriptionLabel.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        descriptionLabel.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        containerView.constraint(descriptionLabel, .Top, .Equal, gestureNameLabel, .Bottom, constant: cursorLayoutMargins.top)
        
        trainButton.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        trainButton.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        containerView.constraint(trainButton, .Top, .Equal, descriptionLabel, .Bottom, constant: cursorLayoutMargins.top)
        
        trainCountLabel.setLeadingToSuperview(constant: cursorLayoutMargins.left)
        trainCountLabel.setTrailingToSuperview(constant: -cursorLayoutMargins.right)
        trainCountLabel.setBottomToSuperview()
        containerView.constraint(trainCountLabel, .Top, .Equal, trainButton, .Bottom, constant: cursorLayoutMargins.top)
        
        activityIndicator.setCenterHorizontallyInSuperview()
        constraint(activityIndicator, .Top, .Equal, containerView, .Bottom, constant: cursorLayoutMargins.top)
        
        translatesAutoresizingMaskIntoConstraints = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateDisplayedTrainCount() {
        trainCountLabel.text = localizeFormatted(trainCount == 1 ? "TRAIN_COUNT_SINGULARIS" : "TRAIN_COUNT_PLURALIS", args: [ trainCount ])
        UIView.animate(animations: {
            self.trainCountLabel.alpha = self.trainCount > 0 ? 1 : 0
        })
    }
}