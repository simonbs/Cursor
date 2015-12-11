//
//  Resources.swift
//  Tracks
//
//  Created by Simon Støvring on 20/08/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

/// A resource that instances of Client can send requests to.
internal protocol Resource {
    /// The path the resource belongs to.
    var resource: String { get }
}

/// Available resources on the server.
internal enum Cursor {
    case Devices // Get a list of all devices
    case UpdateDevice // Update a single device
}

// Make sure all resources conform to the Resource protocol.
extension Cursor: Resource {
    var resource: String {
        switch self {
        case .Devices: return "devices"
        case .UpdateDevice: return ""
        }
    }
}
