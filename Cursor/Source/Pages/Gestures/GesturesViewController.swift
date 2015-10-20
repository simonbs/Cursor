//
//  GesturesViewController.swift
//  Cursor
//
//  Created by Simon Støvring on 20/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class GesturesViewController: UITableViewController, UIAlertViewDelegate {
    let data = GesturesTableViewData()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = localize("GESTURES")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addGesture")
        data.attachToTableView(tableView)
        data.deleteAction = { [weak self] in self?.deleteGesture($0) }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didAddGesture:", name: GestureTrainingViewController.DidSaveGestureNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        refresh()
    }
    
    func refresh() {
        refreshControl?.beginRefreshing()
        let gestureDatabase = GestureDB.sharedInstance()
        NSOperationQueue().addOperationWithBlock {
            gestureDatabase.readGesturesFromDatabase()
            let gestures = gestureDatabase.gestureDict
            let mappedGestures = gestures!.flatMap { TrainedGesture(name: $0 as! String, gestures: $1 as! [Gesture]) }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.data.gestures = mappedGestures
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func addGesture() {
        let alertView = UIAlertView(
            title: localize("ADD_GESTURE"),
            message: localize("ENTER_GESTURE_NAME"),
            delegate: self,
            cancelButtonTitle: localize("CANCEL"),
            otherButtonTitles: localize("CONTINUE"))
        alertView.alertViewStyle = .PlainTextInput
        alertView.textFieldAtIndex(0)?.autocapitalizationType = .Words
        alertView.show()
    }
    
    func deleteGesture(indexPath: NSIndexPath) {
        let gestureDatabase = GestureDB.sharedInstance()
        data.gestures[safe: indexPath.row]?.name => gestureDatabase.deleteGesturesWithNames
        data.deleteCell(indexPath.row)
    }
    
    func presentGestureTraining(gestureName: String) {
        let gestureTrainingController = GestureTrainingViewController(gestureName: gestureName)
        navigationController?.pushViewController(gestureTrainingController, animated: true)
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            alertView.textFieldAtIndex(0)?.text => presentGestureTraining
        }
    }
    
    func didAddGesture(notification: NSNotification) {
        refresh()
    }
}