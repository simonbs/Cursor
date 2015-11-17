//
//  ClientDevices.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

extension Client {
    public func devices(completion: (FailableOf<[Actuator]> -> Void)) -> Request? {
        return request(.GET, Cursor.Devices,
            rootElementPath: "devices",
            mapFunc: Actuator.init,
            completion: completion)
    }
    
    public func updateDevice(id: Int, action: Action, completion: (Failable -> Void)? = nil) -> Request? {
        return request(.POST, Cursor.UpdateDevice,
            params: [ "id": String(id), "action": action ],
            completion: completion)
    }
}