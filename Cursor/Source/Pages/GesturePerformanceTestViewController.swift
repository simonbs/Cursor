//
//  GesturePerformanceTestViewController.swift
//  Cursor
//
//  Created by Kasper Lind Sørensen on 23/11/15.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class GesturePerformanceTestViewController: UIViewController {
    private let gestureRecognizer = ThreeDollarGestureRecognizer(resampleAmount: 50)
    
    var contentView: GesturePerformanceTestView {
        return view as! GesturePerformanceTestView
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = localize("ADD_GESTURE")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "TestGesturePerformance")
    }

    override func loadView() {
        view = GesturePerformanceTestView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.startTestButton.addTarget(self, action: "TestGesturePerformance", forControlEvents: .TouchDown)
        contentView.startTestButton.enabled = true
    }
    
    func TestGesturePerformance(){
        // Setup
        let recognizer = ThreeDollarGestureRecognizer(resampleAmount: 50);
        let knownGestures = GestureDB.sharedInstance().gestureDict as [NSObject: AnyObject]
        let testGesture = knownGestures.values.first![0] as! Gesture
        let start = NSDate(); // Start time
        let iterationCount = 1000
        // Warmup
        for index in 1...10{
            recognizer.recognizeGesture(testGesture, fromGestures: knownGestures)
        }
        
        // Test
        for index in 1...iterationCount{
            recognizer.recognizeGesture(testGesture, fromGestures: knownGestures)
        }
        let end = NSDate();   // End time
        
        let timeInterval: Double = end.timeIntervalSinceDate(start); // <<<<< Difference in seconds (double)
        print("Time to evaluate \(iterationCount) gestures: \(timeInterval) seconds");
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}