//
//  Resources.swift
//  Tracks
//
//  Created by Simon Støvring on 20/08/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

internal protocol Resource {
    var resource: String { get }
}

internal enum Cursor {
    case Devices
    case UpdateDevice
}

extension Cursor: Resource {
    var resource: String {
        switch self {
        case .Devices: return "devices"
        case .UpdateDevice: return ""
        }
    }
}
