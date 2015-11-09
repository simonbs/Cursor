//
//  PointDetector.swift
//  Pointer
//
//  Created by Simon Støvring on 29/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import CoreMotion

class PointDetector {
    private(set) var isDetecting = false
    private let motionManager = CMMotionManager()
    private var isSampling: Bool = false
    private var pointingDuration: NSTimeInterval = 0.5 // Time the user must be pointing in order to trig a pointing gesture
    private var pointingSampleFrequency: Float = 0.5 // Percentage of samples during a sample phase that must be a pointing sample
    private var pointingThreshold: Double = 0.05 // Threshold in radians/second to use when comparing sample data and checking for a pointing gesture
    private var tableThreshold: Double = 0.005 // Threshold in radians/second to use when comparing sample data and checking if the device is on a table
    private var samplingTimer: NSTimer? // Timer used for stopping a sample period
    private var pointingSampleCount = 0 // Amount of samples that are considered a point
    private var totalSampleCount = 0 // Total amount of samples
    private var pointDetectedHandler: (Void -> Void)?
    
    func beginDetecting(handler: (Void -> Void)) {
        guard !isDetecting else { return }
        isDetecting = true
        pointDetectedHandler = handler
        motionManager.deviceMotionUpdateInterval = 0.05
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { [weak self] data, error in
            guard let data = data else { return }
            self?.didUpdateMotionData(data)
        }
    }
    
    func endDetecting() {
        guard isDetecting else { return }
        pointDetectedHandler = nil
        motionManager.stopDeviceMotionUpdates()
        isDetecting = false
    }
    
    private func didUpdateMotionData(data: CMDeviceMotion) {
        let isPointingGesture = isMotionDataAPointingGesture(data)
        if isPointingGesture && !isSampling {
            isSampling = true
            samplingTimer = .scheduledTimerWithTimeInterval(pointingDuration, target: self, selector: "samplingTimerTriggered:", userInfo: nil, repeats: false)
        }
        
        if isPointingGesture && isSampling {
            pointingSampleCount += 1
        }
        
        if isSampling {
            totalSampleCount += 1
        }
    }
    
    // Check whether tor not a data sample is a pointing gesture
    private func isMotionDataAPointingGesture(data: CMDeviceMotion) -> Bool {
        if dataFitsWithinThreshold(data, threshold: tableThreshold) {
            return false
        }
        
        return dataFitsWithinThreshold(data, threshold: pointingThreshold)
    }
    
    private func dataFitsWithinThreshold(data: CMDeviceMotion, threshold: Double) -> Bool {
        return data.rotationRate.x <= threshold && data.rotationRate.x >= -threshold &&
            data.rotationRate.y <= threshold && data.rotationRate.y >= -threshold &&
            data.rotationRate.z <= threshold && data.rotationRate.z >= -threshold
    }
    
    dynamic private func samplingTimerTriggered(timer: NSTimer) {
        let pointingPercentage = Float(pointingSampleCount) / Float(totalSampleCount)
        if pointingPercentage >= pointingSampleFrequency {
            pointDetectedHandler?()
        }
        
        pointingSampleCount = 0
        totalSampleCount = 0
        isSampling = false
    }
}