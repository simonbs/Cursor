//
//  CursorKit.swift
//  Cursor
//
//  Created by Simon Støvring on 15/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

extension Actuator.State {
    var color: UIColor {
        switch self {
        case .On: return .greenColor()
        case .Off: return .redColor()
        }
    }
}