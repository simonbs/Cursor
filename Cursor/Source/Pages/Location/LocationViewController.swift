//
//  LocationViewController.swift
//  Cursor
//
//  Created by Simon Støvring on 10/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class LocationViewController: UIViewController, ESTIndoorLocationManagerDelegate, GestureRecorderDelegate {
    let indoorManager = ESTIndoorLocationManager()
    let location: ESTLocation
    let recognizer = ThreeDollarGestureRecognizer(resampleAmount: 50);
    var gestureRecorder: GestureRecorder?
    private let motionRecognizer = MotionRecognizer()
    private var controllableDevices: [ControllableDevice] = []
    private var currentPosition: ESTOrientedPoint?
    private let visibilityAngle: Double = 30
    private var availableDevices: [ControllableDevice] = [] {
        didSet { contentView.displayAvailableDevices(availableDevices) }
    }
    
    var contentView: LocationView {
        return view as! LocationView
    }
    
    init(location: ESTLocation) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
        title = location.name
        indoorManager.delegate = self
        indoorManager.startIndoorLocation(location)
        self.gestureRecorder = GestureRecorder(nameForGesture: "RecordedGesture", andDelegate: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        indoorManager.stopIndoorLocation()
    }
    
    override func loadView() {
        view = LocationView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.turnOnButton.addTarget(self, action: "turnOn", forControlEvents: .TouchUpInside)
        contentView.turnOffButton.addTarget(self, action: "turnOff", forControlEvents: .TouchUpInside)
        
        contentView.indoorLocationView.rotateOnPositionUpdate = true
        contentView.indoorLocationView.drawLocation(location)
        reloadControllableDevices()
        
        motionRecognizer.didDetectShake = { [weak self] in self?.turnOn() }
        motionRecognizer.didDetectDoubleShake = { [weak self] in self?.turnOff() }
        motionRecognizer.beginRecognizingGestures()
        becomeFirstResponder()

        gestureRecorder?.startRecording()
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        gestureRecorder?.stopRecording()
        recognizer.recognizeGesture(gestureRecorder?.gesture, fromGestures: GestureDB.sharedInstance().gestureDict as [NSObject: AnyObject])
        gestureRecorder?.startRecording()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.indoorLocationView.drawLocation(location)
        redrawControllableDevices()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func turnOn() {
        sendAction("turnOn")
    }
    
    func turnOff() {
        sendAction("turnOff")
    }
    
    private func sendAction(action: Action) {
        availableDevices.forEach { [weak self] device in
            self?.client?.updateDevice(device.id, action: action) { [weak self] result in
                self?.reloadControllableDevices()
            }
        }
    }
    
    func indoorLocationManager(manager: ESTIndoorLocationManager!, didUpdatePosition position: ESTOrientedPoint!, withAccuracy positionAccuracy: ESTPositionAccuracy, inLocation location: ESTLocation!) {
        currentPosition = position
        contentView.indoorLocationView.updatePosition(position)
        availableDevices = controllableDevicesInLineOfSight()
    }

    func recorderForcedStop(sender: AnyObject!) {

    }
    
    private func reloadControllableDevices() {
        client?.devices { [weak self] result in
            self?.removeControllableDevices()
            self?.controllableDevices = result.value ?? []
            self?.drawControllableDevices()
        }
    }
    
    private func redrawControllableDevices() {
        removeControllableDevices()
        drawControllableDevices()
    }
    
    private func removeControllableDevices() {
        controllableDevices.forEach {
            self.contentView.indoorLocationView.removeObjectWithIdentifier(String($0.id))
        }
    }
    
    private func drawControllableDevices() {
        controllableDevices.forEach {
            let point = ESTOrientedPoint(x: Double($0.coordinate.x), y: Double($0.coordinate.y), orientation: 0)
            let objectView = DeviceObjectView()
            objectView.frame = CGRectMake(0, 0, 30, 30)
            objectView.fillColor = $0.state.color
            self.contentView.indoorLocationView.drawObjectInBackground(objectView,
                withPosition: point,
                identifier: String($0.id))
        }
    }

    private func controllableDevicesInLineOfSight() -> [ControllableDevice] {
        guard let currentPosition = currentPosition else { return [] }
        return controllableDevices.filter { d in
            let radians = atan2(Double(d.coordinate.x) - currentPosition.x, Double(d.coordinate.y) - currentPosition.y)
            let degrees = radians.toDegrees()
            let normalizedDegrees = degrees < 0 ? degrees + 360 : degrees
            
            var minDegrees = currentPosition.orientation - Double(self.visibilityAngle / 2)
            var maxDegrees = currentPosition.orientation + Double(self.visibilityAngle / 2)
        
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
}