//
//  Localize.swift
//  Cursor
//
//  Created by Simon Støvring on 19/09/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

public typealias LazyVarArgClosure = Void -> CVarArgType

public func localize(key: String, tableName: String = "", comment: String = "") -> String {
    return NSLocalizedString(key, tableName: tableName, comment: comment)
}

public func localizeFormatted(key: String, args: [CVarArgType]) -> String {
    if args.count == 0 {
        return NSLocalizedString(key, comment: "")
    }
    
    return withVaList(args) { (pointer: CVaListPointer) -> String in
        return NSString(format: localize(key), arguments: pointer) as String
    }
}
