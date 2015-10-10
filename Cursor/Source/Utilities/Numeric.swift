//
//  Double.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import CoreGraphics

extension Double {
    func toRadians() -> Double {
        return self * M_PI / 180
    }
    
    func toDegrees() -> Double {
        return self * 180 / M_PI
    }
    
    func cmToMeter() -> Double {
        return self / 100
    }
}
