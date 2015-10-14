//
//  Coordinate.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

public struct Coordinate {
    public let x: Float
    public let y: Float
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    init?(json: JSON) {
        guard json.array?.count == 2 else { return nil }
        guard let x = json.array?.first?.float else { return nil }
        guard let y = json.array?.last?.float else { return nil }
        self.x = x
        self.y = y
    }
}