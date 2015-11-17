//
//  GestureStore.swift
//  Cursor
//
//  Created by Simon Støvring on 17/11/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

class StoredGesture: NSObject, NSCoding {
    let gesture: String
    let actuatorId: Int
    let action: Action
    
    init(gesture: String, actuatorId: Int, action: Action) {
        self.gesture = gesture
        self.actuatorId = actuatorId
        self.action = action
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.gesture = aDecoder.decodeObjectForKey("gesture") as! String
        self.actuatorId = aDecoder.decodeIntegerForKey("actuatorId")
        self.action = aDecoder.decodeObjectForKey("action") as! Action
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(gesture, forKey: "gesture")
        aCoder.encodeInteger(actuatorId, forKey: "actuatorId")
        aCoder.encodeObject(action, forKey: "action")
    }
}

class GestureStore {
    private let store = NSUserDefaults.standardUserDefaults()
    private let gesturesKey = "dk.simonbs.GestureStore.Gestures"
    private var gestures: [StoredGesture] {
        get { return (store.dataForKey(gesturesKey) => NSKeyedUnarchiver.unarchiveObjectWithData as? [StoredGesture]) ?? [] }
        set { store.setObject(NSKeyedArchiver.archivedDataWithRootObject(newValue), forKey: gesturesKey) }
    }
    
    func addAction(action: Action, forActuatorId actuatorId: Int, toGesture gesture: String) {
        removeAction(action, forActuatorId: actuatorId)
        gestures += [ StoredGesture(gesture: gesture, actuatorId: actuatorId, action: action) ]
    }
    
    func removeAction(action: Action, forActuatorId actuatorId: Int) {
        gestures = gestures.filter { !($0.action == action && $0.actuatorId == actuatorId) }
    }
    
    func findGestureForAction(action: Action, actuatorId: Int) -> String? {
        return gestures.filter { $0.action == action && $0.actuatorId == actuatorId }.first?.gesture
    }
    
    func actionsForGesture(gestureName: String) -> [StoredGesture] {
        return gestures.filter { $0.gesture == gestureName }
    }
}