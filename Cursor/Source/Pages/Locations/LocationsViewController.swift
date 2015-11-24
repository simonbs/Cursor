//
//  LocationsViewController.swift
//  Cursor
//
//  Created by Simon Støvring on 10/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class LocationsViewController: UITableViewController {
    private let data = LocationsTableViewData()
    private let indoorManager = ESTIndoorLocationManager()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = localize("LOCATIONS_TITLE")
        tabBarItem.image = UIImage(named: "home")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addLocation")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editLocations")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "fetchLocations", forControlEvents: .ValueChanged)
        
        data.attachToTableView(tableView)
        data.deleteAction = { [weak self] in self?.deleteLocation($0) }
        data.didSelect = { [weak self] in self?.didSelectLocation($0) }
        
        fetchLocations()
        
        client.updateDevice(1, action: "turnOn") { result in
            print(result.error)
        }
    }
    
    dynamic private func presentActions() {
        navigationController?.pushViewController(ActionsViewController(), animated: true)
    }
    
    dynamic private func addLocation() {
//        let locationBuilder = ESTLocationBuilder()
//        locationBuilder.setLocationBoundaryPoints([
//            ESTPoint(x: 0.cmToMeter(), y: 0.cmToMeter()),
//            ESTPoint(x: 537.cmToMeter(), y: 0.cmToMeter()),
//            ESTPoint(x: 537.cmToMeter(), y: 60.cmToMeter()),
//            ESTPoint(x: 690.cmToMeter(), y: 60.cmToMeter()),
//            ESTPoint(x: 690.cmToMeter(), y: 385.cmToMeter()),
//            ESTPoint(x: 0.cmToMeter(), y: 385.cmToMeter()),
//        ])
        
//        let locationBuilder = ESTLocationBuilder()
//        locationBuilder.setLocationBoundaryPoints([
//            ESTPoint(x: 0.cmToMeter(), y: 0.cmToMeter()),
//            ESTPoint(x: 1790.cmToMeter(), y: 0.cmToMeter()),
//            ESTPoint(x: 1790.cmToMeter(), y: 1790.cmToMeter()),
//            ESTPoint(x: 0.cmToMeter(), y: 1790.cmToMeter())
//        ])
        
        // 0.2.11
        let locationBuilder = ESTLocationBuilder()
        locationBuilder.setLocationBoundaryPoints([
            ESTPoint(x: 0.cmToMeter(), y: 0.cmToMeter()),
            ESTPoint(x: 495.cmToMeter(), y: 0.cmToMeter()),
            ESTPoint(x: 495.cmToMeter(), y: 995.cmToMeter()),
            ESTPoint(x: 0.cmToMeter(), y: 995.cmToMeter())
        ])
        
//        let ice3 = "dec18deac0c5"
//        let blueberry3 = "f13173ad3185"
//        let ice2 = "d470d26d33f3"
//        let mint3 = "e6d39dee79c9"
        let beacon1 = "f91c2ce28dea"
        let beacon2 = "e7d5ee85b0f2"
        let beacon3 = "ec5b3f949c47"
        let beacon4 = "ceab2c161e4b"
        
        let beacon5 = "e6d39dee79c9"
        let beacon6 = "f49f29a4ae60"
        let beacon7 = "dec18deac0c5"
        let beacon8 = "d470d26d33f3"
        
        // 0.2.11
        locationBuilder.addBeaconIdentifiedByMac(beacon1, atBoundarySegmentIndex: 0, inDistance: 163.cmToMeter(), fromSide: .RightSide)
        locationBuilder.addBeaconIdentifiedByMac(beacon2, atBoundarySegmentIndex: 1, inDistance: 332.cmToMeter(), fromSide: .RightSide)
        locationBuilder.addBeaconIdentifiedByMac(beacon3, atBoundarySegmentIndex: 2, inDistance: 163.cmToMeter(), fromSide: .RightSide)
        locationBuilder.addBeaconIdentifiedByMac(beacon4, atBoundarySegmentIndex: 3, inDistance: 332.cmToMeter(), fromSide: .RightSide)
        
        locationBuilder.addBeaconIdentifiedByMac(beacon5, atBoundarySegmentIndex: 0, inDistance: 163.cmToMeter(), fromSide: .LeftSide)
        locationBuilder.addBeaconIdentifiedByMac(beacon6, atBoundarySegmentIndex: 1, inDistance: 332.cmToMeter(), fromSide: .LeftSide)
        locationBuilder.addBeaconIdentifiedByMac(beacon7, atBoundarySegmentIndex: 2, inDistance: 163.cmToMeter(), fromSide: .LeftSide)
        locationBuilder.addBeaconIdentifiedByMac(beacon8, atBoundarySegmentIndex: 3, inDistance: 332.cmToMeter(), fromSide: .LeftSide)
        
        locationBuilder.setLocationOrientation(130)
        locationBuilder.setLocationName("0.2.11")
        
        // Gros stue
//        locationBuilder.addBeaconIdentifiedByMac(blueberry3, atBoundarySegmentIndex: 0, inDistance: 422.cmToMeter(), fromSide: .RightSide)
//        locationBuilder.addBeaconIdentifiedByMac(ice3, atBoundarySegmentIndex: 3, inDistance: 222.cmToMeter(), fromSide: .RightSide)
//        locationBuilder.addBeaconIdentifiedByMac(mint3, atBoundarySegmentIndex: 4, inDistance: 335.cmToMeter(), fromSide: .LeftSide)
//        locationBuilder.addBeaconIdentifiedByMac(ice2, atBoundarySegmentIndex: 5, inDistance: 165.cmToMeter(), fromSide: .LeftSide)
//        locationBuilder.setLocationOrientation(130)
//        locationBuilder.setLocationName("Gros Stue")
        
        // Outside
//        locationBuilder.addBeaconIdentifiedByMac(blueberry3, atBoundarySegmentIndex: 0, inDistance: 940.cmToMeter(), fromSide: .RightSide)
//        locationBuilder.addBeaconIdentifiedByMac(mint3, atBoundarySegmentIndex: 1, inDistance: 850.cmToMeter(), fromSide: .RightSide)
//        locationBuilder.addBeaconIdentifiedByMac(ice2, atBoundarySegmentIndex: 2, inDistance: 940.cmToMeter(), fromSide: .RightSide)
//        locationBuilder.addBeaconIdentifiedByMac(ice3, atBoundarySegmentIndex: 3, inDistance: 850.cmToMeter(), fromSide: .RightSide)
//        locationBuilder.setLocationOrientation(219)
//        locationBuilder.setLocationName("Outside")
        
        // Auditorium
//        locationBuilder.addBeaconIdentifiedByMac(blueberry3, atBoundarySegmentIndex: 0, inDistance: 400.cmToMeter(), fromSide: .RightSide)
//        locationBuilder.addBeaconIdentifiedByMac(mint3, atBoundarySegmentIndex: 1, inDistance: 400.cmToMeter(), fromSide: .RightSide)
//        locationBuilder.addBeaconIdentifiedByMac(ice2, atBoundarySegmentIndex: 2, inDistance: 400.cmToMeter(), fromSide: .LeftSide)
//        locationBuilder.addBeaconIdentifiedByMac(ice3, atBoundarySegmentIndex: 3, inDistance: 400.cmToMeter(), fromSide: .LeftSide)
//        locationBuilder.setLocationOrientation(138)
//        locationBuilder.setLocationName("Auditorium")
        
        let location = locationBuilder.build()
        indoorManager.addNewLocation(location, success: { [weak self] newLocation in
            guard let newLocation = newLocation as? ESTLocation else {
                fatalError("Expected an instance of ESTLocation, got an unknown object")
            }
            
            print(newLocation)
            self?.fetchLocations()
        }) { error in
            print("Could not add location to cloud: \(error)")
        }
    }
    
    dynamic private func editLocations() {
        tableView.setEditing(!tableView.editing, animated: true)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: tableView.editing ? .Done : .Edit, target: self, action: "editLocations")
        ]
    }
    
    dynamic private func fetchLocations() {
        refreshControl?.beginRefreshing()
        indoorManager.fetchUserLocationsWithSuccess({ [weak self] locations in
            guard let locations = locations as? [ESTLocation] else {
                fatalError("Expected an array of ESTLocations, got an unknown object")
            }
            
            self?.data.locations = locations
            self?.refreshControl?.endRefreshing()
        }) { [weak self] error in
            self?.refreshControl?.endRefreshing()
            self?.data.locations = []
            print("Could not fetch locations from cloud: \(error)")
        }
    }
    
    private func deleteLocation(indexPath: NSIndexPath) {
        guard let location = data.locations[safe: indexPath.row] else { return }
        indoorManager.removeLocation(location, success: { [weak self] location in
            self?.data.deleteCell(indexPath.row)
        }) { error in
            print("Could not remove location from cloud: \(error)")
        }
    }
    
    private func didSelectLocation(indexPath: NSIndexPath) {
        guard let location = data.locations[safe: indexPath.row] else { return }
        let locationController = LocationViewController(location: location)
        navigationController?.pushViewController(locationController, animated: true)
    }
}
