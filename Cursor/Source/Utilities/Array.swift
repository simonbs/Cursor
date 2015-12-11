//
//  Array.swift
//  DRTV
//
//  Created by Simon Støvring on 18/09/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

extension Array {
    /**
     Safely retrieves an element from the array.
     By default subscript will throw an error if the index does not exist.
     Using [safe:] subscript, nil is returned if the index does not exist.
     
     - Parameter index: Index to retrieve element from. Zero based.
     
     - Returns: The element, if it exists. Nil otherwise.
     */
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}