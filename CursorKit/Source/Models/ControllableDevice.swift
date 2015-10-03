//
//  ControllableDevice.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import SwiftyJSON

public typealias Action = String

public struct ControllableDevice {
    public let id: Int
    public let name: String
    public let coordinate: Coordinate
    private(set) var actions: [Action] = []
    
    init?(json: JSON) {
        guard let id = json["id"].int else { return nil }
        guard let name = json["name"].string else { return nil }
        guard let coordinate = json["coords"] => Coordinate.init else { return nil }
        self.id = id
        self.name = name
        self.coordinate = coordinate
        actions += json["actions"].arrayValue.flatMap { $0.string }
    }
}