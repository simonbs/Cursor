//
//  Operators.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

infix operator => { associativity left precedence 160 }

/**
 The "implies operator". If both sides of the operator are non-nil
 the left side is supplied to the right side as a parameter and the
 result of the right is returned.
 
 - Parameter lhs: Some object of type T?.
 - Parameter rhs: A closure taking an object of paramter T as input and returning an object of type U?.
 
 - Returns: Result of evaluating the right side with the left side as input.
 */
func =><T, U>(lhs: T?, rhs: (T -> U?)?) -> U? {
    if let lhs = lhs {
        if let rhs = rhs {
            return rhs(lhs)
        }
    }
    
    return nil
}

/**
 The "implies operator". If both sides of the operator are non-nil
 the left side is supplied to the right side as a parameter and the
 result of the right is returned.
 
 - Parameter lhs: Some object of type T?.
 - Parameter rhs: A closure taking an object of paramter T as input.
 */
func =><T>(lhs: T?, rhs: (T -> Void)?) {
    if let lhs = lhs {
        if let rhs = rhs {
            rhs(lhs)
        }
    }
}