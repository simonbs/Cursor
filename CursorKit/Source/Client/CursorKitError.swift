//
//  Error.swift
//  Cursor
//
//  Created by Simon Støvring on 20/08/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

public let CursorKitErrorDomain = "dk.simonbs.CursorKit"

enum ErrorCode: Int {
    case UnknownError = 1000
    case NoJSONReceived = 1001
    case UnableToParseResponse = 1002
    case ModelNotAvailable = 1003
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