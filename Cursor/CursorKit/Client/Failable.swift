//
//  Failable.swift
//  Tracks
//
//  Created by Simon Støvring on 20/08/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

public enum Failable {
    case Success
    case Failure(ErrorType)
    
    init() {
        self = .Success
    }
    
    init (_ error: ErrorType) {
        self = .Failure(error)
    }
    
    init (_ error: ErrorType?) {
        if let error = error {
            self = .Failure(error)
        } else {
            self = .Success
        }
    }
    
    public var failed: Bool {
        switch self {
        case .Failure(_):
            return true
        default:
            return false
        }
    }
    
    public var error: ErrorType? {
        switch self {
        case .Failure(let error):
            return error
        default:
            return nil
        }
    }
}

public enum FailableOf<T> {
    case Success(T)
    case Failure(ErrorType)
    
    init(_ value: T) {
        self = .Success(value)
    }
    
    init (_ error: ErrorType) {
        self = .Failure(error)
    }
    
    public var failed: Bool {
        switch self {
        case .Failure(_):
            return true
        default:
            return false
        }
    }
    
    public var error: ErrorType? {
        switch self {
        case .Failure(let error):
            return error
        default:
            return nil
        }
    }
    
    public var value: T? {
        switch self {
        case .Success(let value):
            return value
        default:
            return nil
        }
    }
}
