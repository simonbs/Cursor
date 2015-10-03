//
//  Array.swift
//  DRTV
//
//  Created by Simon Støvring on 18/09/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

extension Array {
    func take(count: Int, from: Int = 0) -> [Element] {
        return count <= self.count ? Array(self[from..<count]) : self
    }
    
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}