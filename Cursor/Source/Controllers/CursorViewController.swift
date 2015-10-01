//
//  CursorViewController.swift
//  Cursor
//
//  Created by Simon Støvring on 01/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import UIKit

class CursorViewController: UIViewController {
    var contentView: CursorView {
        return view as! CursorView
    }
    
    override func loadView() {
        view = CursorView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localize("CURSOR_TITLE")
    }
}

