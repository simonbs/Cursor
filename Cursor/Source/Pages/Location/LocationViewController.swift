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
    private var actuators: [Actuator] = []
    private var currentPosition: ESTOrientedPoint?
    private let visibilityAngle: Double = 30
    private var availableDevices: [Actuator] = [] {
        didSet { contentView.displayAvailableDevices(availableDevices) }
    }
    private var devicesPointedAt: [Actuator] = []
    
    private let pointDetector = PointDetector()
    private var isDelayingGestureFromPoint = false
    private var delayGestureFromPointTimer: NSTimer?
    private var pointEndsGestureTimer: NSTimer?
    
    private var pointEndsGesture = false
    
    private let logger = Logger()
    private let loggingDateFormatter = NSDateFormatter()
    
    var contentView: LocationView {
        return view as! LocationView
    }
    
    init(location: ESTLocation) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
        title = location.name
        indoorManager.delegate = self
        indoorManager.startIndoorLocation(location)
        beginPointDetection()
        loggingDateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        indoorManager.stopIndoorLocation()
        pointDetector.endDetecting()
        delayGestureFromPointTimer?.invalidate()
    }
    
    override func loadView() {
        view = LocationView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.indoorLocationView.rotateOnPositionUpdate = true
        contentView.indoorLocationView.drawLocation(location)
        reloadActuators()

        contentView.loggingButton.addTarget(self, action: "loggingButtonPressed:", forControlEvents: .TouchUpInside)
        
        contentView.constraintToLayoutSupport(contentView.gestureNameLabel, .Top, .Equal, topLayoutGuide, .Bottom, constant: contentView.cursorLayoutMargins.top)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.indoorLocationView.drawLocation(location)
        redrawActuators()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    dynamic private func loggingButtonPressed(sender: UIButton) {
        if logger.isLogging {
            logger.stopLogging()
        } else {
            logger.startLogging([
                "Date",
                "X",
                "Y",
                "Beacons"
            ])
        }
        
        contentView.loggingButton.setTitle(logger.isLogging ? "Stop logging" : "Start logging", forState: .Normal)
    }
    
    func startPerformingGesture() {
        contentView.showReadyForGesture()
        gestureRecorder = GestureRecorder(nameForGesture: "RecordedGesture", andDelegate: self)
        gestureRecorder?.startRecording()
    }
    
    func endPerformingGesture() {
        guard let recorder = gestureRecorder where recorder.isRecording else { return }
        contentView.showDefault()
        NSOperationQueue().addOperationWithBlock {
            self.gestureRecorder?.stopRecording()
            let knownGestures = GestureDB.sharedInstance().gestureDict as [NSObject: AnyObject]
            let gesture = self.recognizer.recognizeGesture(self.gestureRecorder?.gesture, fromGestures: knownGestures)
            self.gestureRecorder = nil
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if gesture != nil {
                    self.contentView.gestureNameLabel.text = gesture
                    self.didPerformGesture(gesture)
                } else {
                    self.contentView.gestureNameLabel.text = localize("NO_GESTURE")
                }

                UIView.animate(animations: {
                    self.contentView.gestureNameLabel.alpha = 1
                })
                
                UIView.animate(delay: 3, animations: {
                    self.contentView.gestureNameLabel.alpha = 0
                })
                
                self.beginPointDetection()
            }
        }
    }
    
    private func didPerformGesture(gesture: String) {
        let actions = GestureStore().actionsForGesture(gesture)
        actions.forEach { self.sendAction($0.action, actuatorId: $0.actuatorId) }
    }
    
    private func sendAction(action: Action, actuatorId: Int) {
        client.updateDevice(actuatorId, action: action) { [weak self] result in
            self?.reloadActuators()
        }
    }
    
    func indoorLocationManager(manager: ESTIndoorLocationManager!, didUpdatePosition position: ESTOrientedPoint!, withAccuracy positionAccuracy: ESTPositionAccuracy, inLocation location: ESTLocation!) {
        currentPosition = position
        contentView.indoorLocationView.updatePosition(position)
        availableDevices = actuatorsInLineOfSight()
        if logger.isLogging {
            logger.log([
                loggingDateFormatter.stringFromDate(NSDate()),
                String(position.x),
                String(position.y),
                String(location.beacons.count)
            ])
        }
    }

    func recorderForcedStop(sender: AnyObject!) {
        print("Recording was force stopped")
        pointEndsGesture = false
        gestureRecorder = nil
        contentView.showDefault()
        beginPointDetection()
    }
    
    private func reloadActuators() {
        client.devices { [weak self] result in
            self?.removeActuators()
            self?.actuators = result.value ?? []
            self?.drawActuators()
        }
    }
    
    private func redrawActuators() {
        removeActuators()
        drawActuators()
    }
    
    private func removeActuators() {
        actuators.forEach {
            self.contentView.indoorLocationView.removeObjectWithIdentifier(String($0.id))
        }
    }
    
    private func drawActuators() {
        actuators.forEach {
            let point = ESTOrientedPoint(x: Double($0.coordinate.x), y: Double($0.coordinate.y), orientation: 0)
            let objectView = DeviceObjectView()
            objectView.frame = CGRectMake(0, 0, 30, 30)
            objectView.fillColor = $0.state.color
            self.contentView.indoorLocationView.drawObjectInBackground(objectView,
                withPosition: point,
                identifier: String($0.id))
        }
    }

    private func actuatorsInLineOfSight() -> [Actuator] {
        guard let currentPosition = currentPosition else { return [] }
        return actuators.filter { d in
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

    private func beginPointDetection() {
        print("Did begin point detection")
        pointDetector.beginDetecting { [weak self] in self?.didDetectPoint() }
    }
    
    private func endPointDetection() {
        print("Did end point detection")
        pointDetector.endDetecting()
    }
    
    private func didDetectPoint() {
        guard !isDelayingGestureFromPoint else { return }
        if pointEndsGesture {
            print("Did detect ending point")
            pointEndsGesture = false
            endPointDetection()
            endPerformingGesture()
            return
        }
        
        guard availableDevices.count > 0 else { return }
        
        print("Did detect beginning point")
        
        contentView.showPointDetected()
        devicesPointedAt = availableDevices
        endPointDetection()
        isDelayingGestureFromPoint = true
        delayGestureFromPointTimer = .scheduledTimerWithTimeInterval(1, target: self, selector: "didDelayGestureFromPoint:", userInfo: nil, repeats: false)
    }
    
    dynamic private func didDelayGestureFromPoint(timer: NSTimer) {
        print("Did delay gesture from point")
        isDelayingGestureFromPoint = false
        startPerformingGesture()
        pointEndsGestureTimer = .scheduledTimerWithTimeInterval(1, target: self, selector: "pointEndsGestureTimerTriggered:", userInfo: nil, repeats: false)
    }
    
    dynamic private func pointEndsGestureTimerTriggered(timer: NSTimer) {
        beginPointDetection()
        pointEndsGesture = true
    }
}