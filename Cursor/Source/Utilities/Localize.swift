//
//  Localize.swift
//  Cursor
//
//  Created by Simon Støvring on 19/09/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

/**
 Retrieve a localized string.
 
 - Parameter key: Key associated with the localized string.
 - Parameter tableName: Table to retrieve the string from. Default is Localizable.strings.
 - Parameter comment: Optionally provide a comment for the string. Especially useful for auto generated string files.
 
 - Returns: The localized string if it exists, otherwise the key.
*/
public func localize(key: String, tableName: String = "", comment: String = "") -> String {
    return NSLocalizedString(key, tableName: tableName, comment: comment)
}

/**
 Retrieve a localized string.
 The string is expected to be a format and is formatted using the supplied arguments.
 
 - Parameter key: Key associated with the localized string.
 - Parameter tableName: Table to retrieve the string from. Default is Localizable.strings.
 - Parameter comment: Optionally provide a comment for the string. Especially useful for auto generated string files.
 - Parameter args: Array of arguments to supply to the format.
 
 - Returns: The localized string if it exists, otherwise the key.
 */
public func localizeFormatted(key: String, tableName: String = "", comment: String = "", args: [CVarArgType]) -> String {
    if args.count == 0 {
        return NSLocalizedString(key, tableName: tableName, comment: comment)
    }
    
    return withVaList(args) { (pointer: CVaListPointer) -> String in
        return NSString(format: localize(key, tableName: tableName, comment: comment), arguments: pointer) as String
    }
}
