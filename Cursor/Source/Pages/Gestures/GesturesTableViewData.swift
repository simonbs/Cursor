//
//  GesturesTableViewData.swift
//  Cursor
//
//  Created by Simon Støvring on 10/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

class GesturesTableViewData: NSObject, UITableViewDataSource, UITableViewDelegate {
    private let cellIdentifier = "GestureCell"
    private weak var tableView: UITableView?
    private var privateGestures: [TrainedGesture] = []
    var gestures: [TrainedGesture] {
        get { return privateGestures }
        set {
            privateGestures = newValue
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
        gestures.removeAtIndex(index)
        tableView?.endUpdates()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(cellIdentifier) ?? UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gestures.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let gesture = gestures[safe: indexPath.item]
        let trainCount = gesture?.gestures.count ?? 0
        cell.textLabel?.text = gesture?.name
        cell.detailTextLabel?.text = localizeFormatted(trainCount == 1 ? "SHORT_TRAIN_COUNT_SINGULARIS" : "SHORT_TRAIN_COUNT_PLURALIS", args: [ trainCount ])
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteAction?(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        didSelect?(indexPath)
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}