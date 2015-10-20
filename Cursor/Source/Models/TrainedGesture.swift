//
//  TrainedGesture.swift
//  Cursor
//
//  Created by Simon Støvring on 20/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

class TrainedGesture {
    let name: String
    let gestures: [Gesture]
    
    init(name: String, gestures: [Gesture]) {
        self.name = name
        self.gestures = gestures
    }
}