//
//  ActionsViewController.swift
//  Cursor
//
//  Created by Simon Støvring on 17/11/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

class ActionsViewController: UITableViewController {
    private let data = ActionsTableViewData()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = localize("ACTIONS")
        tabBarItem.image = UIImage(named: "wand")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "fetchActions", forControlEvents: .ValueChanged)
        data.attachToTableView(tableView)
        data.didSelect = { [weak self] in self?.didSelect($0) }
        data.didRemoveGesture = { [weak self] in self?.didRemoveGesture($0) }
        fetchActions()
    }
    
    dynamic private func fetchActions() {
        refreshControl?.beginRefreshing()
        data.actuatorActionEntries = [
            ActuatorActionEntry(
                actuatorId: 0,
                actuatorName: "Lamp at Dinner Table",
                action: "turnOn"),
            ActuatorActionEntry(
                actuatorId: 0,
                actuatorName: "Lamp at Dinner Table",
                action: "turnOff"),
            ActuatorActionEntry(
                actuatorId: 1,
                actuatorName: "Lamp at Couches",
                action: "turnOn"),
            ActuatorActionEntry(
                actuatorId: 1,
                actuatorName: "Lamp at Couches",
                action: "turnOff")
        ]
        refreshControl?.endRefreshing()
//        client.devices { [weak self] result in
//            self?.data.actuatorActionEntries = (result.value ?? []).reduce(Array<ActuatorActionEntry>()) { initial, actuator in
//                return initial + actuator.actions.map { ActuatorActionEntry(actuatorId: actuator.id, actuatorName: actuator.name, action: $0) }
//            }
//            
//            self?.refreshControl?.endRefreshing()
//        }
    }
    
    private func didSelect(indexPath: NSIndexPath) {
        guard let entry = data.actuatorActionEntries[safe: indexPath.row] else { return }
        let gesturesController = GesturesViewController()
        gesturesController.didSelectGesture = { [weak self] in self?.didPickGesture($0, entry: entry) }
        navigationController?.pushViewController(gesturesController, animated: true)
    }
    
    private func didPickGesture(gesture: TrainedGesture, entry: ActuatorActionEntry) {
        GestureStore().addAction(entry.action, forActuatorId: entry.actuatorId, toGesture: gesture.name)
        tableView.reloadData()
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func didRemoveGesture(indexPath: NSIndexPath) {
        guard let entry = data.actuatorActionEntries[safe: indexPath.row] else { return }
        GestureStore().removeAction(entry.action, forActuatorId: entry.actuatorId)
        tableView.reloadData()
    }
}