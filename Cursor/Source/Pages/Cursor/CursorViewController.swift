//
//  CursorViewController.swift
//  Cursor
//
//  Created by Simon Støvring on 01/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import UIKit
import CoreLocation

class CursorViewController: UIViewController, CLLocationManagerDelegate {
    private let gridSize = GridSize(columns: 11, rows: 11)
    private let userLocation = Coordinate(x: 5.5, y: 5.5)
    private let visibilityAngle: Float = 30
    private let locationManager = CLLocationManager()
    private var currentDegrees: Double? {
        didSet {
            currentDegrees => contentView.displayDegrees
        }
    }
    private var controllableDevices: [ControllableDevice] = [] {
        didSet {
            contentView.devicesPlanView.gridView.deviceCoordinates = controllableDevices.map { $0.coordinate }
        }
    }
    private var availableDevices: [ControllableDevice] = [] {
        didSet { contentView.displayAvailableDevices(availableDevices) }
    }
    
    private let movingAverageSampleCount: Int = 10
    private var readingHistory: [Double] = []
    
    private let motionRecognizer = MotionRecognizer()
    
    var contentView: CursorView {
        return view as! CursorView
    }
    
    override func loadView() {
        view = CursorView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = localize("CURSOR_TITLE")
        
        contentView.devicesPlanView.visibilityIndicatorView.angle = visibilityAngle
        contentView.devicesPlanView.gridView.gridSize = gridSize
        contentView.hideGroundPlan()
        
        contentView.turnOnButton.addTarget(self, action: "turnOn", forControlEvents: .TouchUpInside)
        contentView.turnOffButton.addTarget(self, action: "turnOff", forControlEvents: .TouchUpInside)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 1
        locationManager.startUpdatingHeading()
        
        reloadControllableDevices()
        
        motionRecognizer.didDetectShake = { [weak self] in self?.didDetectShake() }
        motionRecognizer.didDetectDoubleShake = { [weak self] in self?.didDetectDoubleShake() }
        motionRecognizer.beginRecognizingGestures()
        becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    deinit {
        locationManager.stopUpdatingHeading()
    }
    
    private func didDetectShake() {
        sendAction("turnOn")
    }
    
    private func didDetectDoubleShake() {
        sendAction("turnOff")
    }
    
    private func sendAction(action: Action) {
        availableDevices.forEach { device in
            client?.updateDevice(device.id, action: action)
        }
    }
    
    private func reloadControllableDevices() {
        client?.devices { [weak self] result in
            guard let controllableDevices = result.value where !result.failed else {
                print(result.error)
                return
            }
            
            self?.controllableDevices = controllableDevices
        }
    }
    
    private func controllableDevicesInLineOfSight() -> [ControllableDevice] {
        guard let currentDegrees = currentDegrees else { return [] }
        return controllableDevices.filter { d in
            let radians = Double(atan2(self.userLocation.y - d.coordinate.y, self.userLocation.x - d.coordinate.x))
            let degrees = radians.toDegrees() - 90 // Thinks west is north, adjust for that
            let normalizedDegrees = degrees < 0 ? degrees + 360 : degrees

            var minDegrees = currentDegrees - Double(self.visibilityAngle / 2)
            var maxDegrees = currentDegrees + Double(self.visibilityAngle / 2)

            minDegrees += minDegrees < 0 ? 360 : 0
            maxDegrees += maxDegrees < 0 ? 360 : 0
            
            minDegrees -= minDegrees > 360 ? 360 : 0
            maxDegrees -= maxDegrees > 360 ? 360 : 0

            if minDegrees < maxDegrees {
                return normalizedDegrees >= minDegrees && normalizedDegrees <= maxDegrees
            } else {
                return normalizedDegrees >= minDegrees || normalizedDegrees <= maxDegrees
            }
        }
    }
    
    private func appendHeading(heading: CLHeading) {
        readingHistory.insert(heading.magneticHeading, atIndex: 0)
        readingHistory = readingHistory.take(movingAverageSampleCount)
        currentDegrees = readingHistory.reduce(0, combine: +) / Double(readingHistory.count)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy > 0 {
            appendHeading(newHeading)
        }
        
        contentView.showGroundPlan(animated: true)
        availableDevices = controllableDevicesInLineOfSight()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager failed: \(error)")
    }
    
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        return true
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        motionRecognizer.motionBegan(motion, withEvent: event)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        motionRecognizer.motionEnded(motion, withEvent: event)
    }
    
    override func motionCancelled(motion: UIEventSubtype, withEvent event: UIEvent?) {
        motionRecognizer.motionCancelled(motion, withEvent: event)
    }
}

