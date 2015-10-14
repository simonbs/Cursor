//
//  LocationView.swift
//  Cursor
//
//  Created by Simon Støvring on 10/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class LocationView: UIView {
    let indoorLocationView = ESTIndoorLocationView()
    
    init() {
        super.init(frame: CGRectZero)
        
        backgroundColor = .whiteColor()
        
        addSubview(indoorLocationView)
        indoorLocationView.setEdgesEqualToSuperview(cursorLayoutMargins)
        
        translatesAutoresizingMaskIntoConstraints = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}