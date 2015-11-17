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
    private let data = GesturesTableViewData()
    var didSelectGesture: (TrainedGesture -> Void)?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = localize("GESTURES")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addGesture")
        data.attachToTableView(tableView)
        data.deleteAction = { [weak self] in self?.deleteGesture($0) }
        data.didSelect = { [weak self] in self?.didSelect($0) }
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
    
    dynamic private func refresh() {
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
    
    dynamic private func addGesture() {
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
    
    private func deleteGesture(indexPath: NSIndexPath) {
        let gestureDatabase = GestureDB.sharedInstance()
        data.gestures[safe: indexPath.row]?.name => gestureDatabase.deleteGesturesWithNames
        data.deleteCell(indexPath.row)
    }
    
    private func presentGestureTraining(gestureName: String) {
        let gestureTrainingController = GestureTrainingViewController(gestureName: gestureName)
        navigationController?.pushViewController(gestureTrainingController, animated: true)
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            alertView.textFieldAtIndex(0)?.text => presentGestureTraining
        }
    }
    
    dynamic private func didAddGesture(notification: NSNotification) {
        refresh()
    }
    
    private func didSelect(indexPath: NSIndexPath) {
        data.gestures[safe: indexPath.row] => didSelectGesture
    }
}