//
//  LocationsTableViewData.swift
//  Cursor
//
//  Created by Simon Støvring on 10/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

class LocationsTableViewData: NSObject, UITableViewDataSource, UITableViewDelegate {
    private let cellIdentifier = "LocationCell"
    private weak var tableView: UITableView?
    private var privateLocations: [ESTLocation] = []
    var locations: [ESTLocation] {
        get { return privateLocations }
        set {
            privateLocations = newValue
            tableView?.reloadData()
        }
    }
    
    var deleteAction: (NSIndexPath -> Void)?
    var didSelect: (NSIndexPath -> Void)?
    
    func attachToTableView(tableView: UITableView) {
        self.tableView = tableView
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func deleteCell(index: Int) {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        tableView?.beginUpdates()
        tableView?.deleteRowsAtIndexPaths([ indexPath ], withRowAnimation: .Automatic)
        locations.removeAtIndex(index)
        tableView?.endUpdates()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(cellIdentifier) ?? UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let location = locations[safe: indexPath.item]
        cell.textLabel?.text = location?.name
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return [ UITableViewRowAction(style: .Destructive, title: "Delete", handler: {
            [weak self] _, indexPath in indexPath => self?.deleteAction
        }) ]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        didSelect?(indexPath)
    }
}