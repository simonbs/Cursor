//
//  Operators.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

infix operator => { associativity left precedence 160 }
func =><T, U>(lhs: T?, rhs: (T -> U?)?) -> U? {
    if let lhs = lhs {
        if let rhs = rhs {
            return rhs(lhs)
        }
    }
    
    return nil
}

func =><T>(lhs: T?, rhs: (T -> Void)?) {
    if let lhs = lhs {
        if let rhs = rhs {
            rhs(lhs)
        }
    }
}