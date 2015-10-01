//
//  CursorView.swift
//  Cursor
//
//  Created by Simon Støvring on 01/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

class CursorView: UIView {
    init() {
        super.init(frame: CGRectZero)
        backgroundColor = .whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}