//
//  Utilities.swift
//  Cursor
//
//  Created by Simon Støvring on 19/09/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import SwiftyJSON

infix operator => { associativity left precedence 160 }
func =><T, U>(lhs: T?, rhs: T -> U?) -> U? {
    if let lhs = lhs {
        return rhs(lhs)
    }
    
    return nil
}
