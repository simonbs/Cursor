//
//  ClientDevices.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

extension Client {
    public func devices(completion: (FailableOf<[ControllableDevice]> -> Void)) -> Request? {
        return request(.GET, Cursor.Devices,
            mapFunc: ControllableDevice.init,
            completion: completion)
    }
    
    public func updateDevice(id: Int, action: Action, completion: (FailableOf<Void> -> Void)? = nil) -> Request? {
        return request(.POST, Cursor.UpdateDevice,
            params: [ "id": String(id), "action": action ],
            mapFunc: { _ in return },
            completion: completion)
    }
}