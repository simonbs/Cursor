//
//  ActionsTableViewData.swift
//  Cursor
//
//  Created by Simon Støvring on 17/11/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

struct ActuatorActionEntry {
    let actuatorId: Int
    let actuatorName: String
    let action: Action
    
    func findGestureName() -> String? {
        return GestureStore().findGestureForAction(action, actuatorId: actuatorId)
    }
}

class ActionsTableViewData: NSObject, UITableViewDataSource, UITableViewDelegate {
    private let cellIdentifier = "Cell"
    private weak var tableView: UITableView?
    private var privateActuatorActionEntries: [ActuatorActionEntry] = []
    var actuatorActionEntries: [ActuatorActionEntry] {
        get { return privateActuatorActionEntries }
        set {
            privateActuatorActionEntries = newValue
            tableView?.reloadData()
        }
    }
    
    var didSelect: (NSIndexPath -> Void)?
    var didRemoveGesture: (NSIndexPath -> Void)?
    
    func attachToTableView(tableView: UITableView) {
        self.tableView = tableView
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(cellIdentifier) ?? UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actuatorActionEntries.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let entry = actuatorActionEntries[safe: indexPath.item] else { return }
        cell.textLabel?.text = "\(entry.actuatorName) (\(entry.action))"
        cell.detailTextLabel?.text = entry.findGestureName()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let entry = actuatorActionEntries[safe: indexPath.item] else { return false }
        return entry.findGestureName() != nil
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return localize("REMOVE_GESTURE")
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            didRemoveGesture?(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        didSelect?(indexPath)
    }
}