//
//  MotionRecognizer.swift
//  Cursor
//
//  Created by Simon Støvring on 05/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class MotionRecognizer: NSObject {
    private let doubleShakeGracePeriod: NSTimeInterval = 0.5
    private var isRecognizingGestures = false
    private var cancelDoubleShakeTimer: NSTimer?
    private var motionDidHandleDoubleShake = false
    
    var didDetectShake: (Void -> Void)?
    var didDetectDoubleShake: (Void -> Void)?
    
    
    func beginRecognizingGestures() {
        isRecognizingGestures = true
    }
    
    func endRecognizingGestures() {
        isRecognizingGestures = false
    }
    
    func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        guard isRecognizingGestures else { return }
        if motion == .MotionShake {
            if cancelDoubleShakeTimer != nil {
                motionDidHandleDoubleShake = true
                handleSecondShake()
            }
        }
    }
    
    func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        guard isRecognizingGestures else { return }
        if motion == .MotionShake {
            if cancelDoubleShakeTimer == nil && !motionDidHandleDoubleShake {
                handleFirstShake()
            }
            
            motionDidHandleDoubleShake = false
        }
    }
    
    func motionCancelled(motion: UIEventSubtype, withEvent event: UIEvent?) {
        guard isRecognizingGestures else { return }
        cancelDoubleShakeTimer?.invalidate()
        cancelDoubleShakeTimer = nil
    }
    
    private func handleFirstShake() {
        cancelDoubleShakeTimer = .scheduledTimerWithTimeInterval(doubleShakeGracePeriod, target: self, selector: "cancelDoubleShake:", userInfo: nil, repeats: false)
    }
    
    private func handleSecondShake() {
        cancelDoubleShakeTimer?.invalidate()
        cancelDoubleShakeTimer = nil
        didDetectDoubleShake?()
    }
    
    func cancelDoubleShake(timer: NSTimer) {
        cancelDoubleShakeTimer = nil
        didDetectShake?()
    }
}