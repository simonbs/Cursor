//
//  GestureTrainingViewController.swift
//  Cursor
//
//  Created by Simon Støvring on 20/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class GestureTrainingViewController: UIViewController, GestureRecorderDelegate {
    static let DidSaveGestureNotification = "dk.simonbs.DidSaveGestureNotification"
    private let gestureName: String
    private let gestureRecognizer = ThreeDollarGestureRecognizer(resampleAmount: 50)
    private var gestureRecorder: GestureRecorder?
    private var isTraining: Bool = false
    private var trainingForceStopped = false
    private var trainedGestures: [Gesture] = []
    
    var contentView: GestureTrainingView {
        return view as! GestureTrainingView
    }
    
    init(gestureName: String) {
        self.gestureName = gestureName
        super.init(nibName: nil, bundle: nil)
        title = localize("ADD_GESTURE")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancelTrainingSession()
    }
    
    override func loadView() {
        view = GestureTrainingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.gestureNameLabel.text = gestureName
        contentView.trainButton.addTarget(self, action: "startTrainingSession", forControlEvents: .TouchDown)
        contentView.trainButton.addTarget(self, action: "endTrainingSession", forControlEvents: .TouchUpInside)
        contentView.trainButton.addTarget(self, action: "endTrainingSession", forControlEvents: .TouchUpOutside)
        contentView.trainButton.addTarget(self, action: "cancelTrainingSession", forControlEvents: .TouchCancel)
    }
    
    func cancel() {
        cancelTrainingSession()
        navigationController?.popViewControllerAnimated(true)
    }
    
    func startTrainingSession() {
        guard !isTraining else { return }
        isTraining = true
        gestureRecorder = GestureRecorder(nameForGesture: gestureName, andDelegate: self)
        gestureRecorder?.startRecording()
    }
    
    func endTrainingSession() {
        guard isTraining else { return }
        gestureRecorder?.stopRecording()
        guard let gestureTrace = gestureRecorder?.gesture.gestureTrace where !trainingForceStopped else {
            prepareForNextTrainingSession()
            return
        }
        
        contentView.trainButton.enabled = false

        NSOperationQueue().addOperationWithBlock {
            let normalized = self.gestureRecognizer.prepareMatrixForLibrary(gestureTrace)
            self.gestureRecorder?.gesture.gestureTrace = normalized
            guard let gesture = self.gestureRecorder?.gesture else {
                self.prepareForNextTrainingSession()
                return
            }
            
            self.trainedGestures.append(gesture)
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.contentView.trainCount += 1
                self.prepareForNextTrainingSession()
                if self.contentView.trainCount >= 5 {
                    self.enableSave()
                }
            }
        }
    }
    
    func cancelTrainingSession() {
        guard isTraining else { return }
        gestureRecorder?.stopRecording()
        guard !trainingForceStopped else {
            prepareForNextTrainingSession()
            return
        }
        prepareForNextTrainingSession()
    }
    
    private func prepareForNextTrainingSession() {
        contentView.trainButton.enabled = true
        contentView.activityIndicator.stopAnimating()
        gestureRecorder = nil
        isTraining = false
    }
    
    func enableSave() {
        navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save"), animated: true)
    }
    
    func save() {
        contentView.trainButton.enabled = false
        contentView.activityIndicator.startAnimating()
        
        let gestureDatabase = GestureDB.sharedInstance()
        NSOperationQueue().addOperationWithBlock {
            self.trainedGestures.forEach {
                gestureDatabase.addGesture($0)
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                NSNotificationCenter.defaultCenter().postNotificationName(GestureTrainingViewController.DidSaveGestureNotification, object: nil)
                self.contentView.activityIndicator.stopAnimating()
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func recorderForcedStop(sender: AnyObject!) {
        trainingForceStopped = true
    }
}