//
//  dispatch.swift
//  SwiftyCat
//
//  Created by Ulrik Damm on 11/01/15.
//  Copyright (c) 2015 Robocat. All rights reserved.
//

import Foundation

public func dispatch_main(block: Void -> Void) {
	dispatch_async(dispatch_get_main_queue(), block)
}

public func dispatch_background(block: Void -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
}

public func dispatch_after(seconds: Double, queue: dispatch_queue_t? = nil, callback: Void -> Void) {
    let dispatch_to: dispatch_queue_t = queue ?? dispatch_get_main_queue()
	let time = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
	dispatch_after(time, dispatch_to, callback)
}
