//
//  Error.swift
//  Cursor
//
//  Created by Simon Støvring on 20/08/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

//
// Create errors with a custom error code and description.
// Shortens the notation for creating NSErrors,
// and enforces known error codes.
//

public let CursorKitErrorDomain = "dk.simonbs.CursorKit"

// Error codes available in the kit.
enum ErrorCode: Int {
    case UnknownError = 1000 // The error is not known
    case NoJSONReceived = 1001 // No JSON was received
    case UnableToParseResponse = 1002 // The JSON could not be parsed
    case ModelNotAvailable = 1003 // The requested model is not available
}

extension NSError {
    convenience init(code: ErrorCode, description: String? = nil) {
        var userInfo: [String: String] = [:]
        if let description = description {
            userInfo[NSLocalizedDescriptionKey] = description
        }
        
        self.init(domain: CursorKitErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}