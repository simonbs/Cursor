//
//  DevicesGrid.swift
//  Cursor
//
//  Created by Simon Støvring on 03/10/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation
import UIKit

struct GridSize {
    let columns: Int
    let rows: Int
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
    }
}

class DevicesGridView: UIView {
    var gridSize = GridSize(columns: 10, rows: 10) {
        didSet { setNeedsDisplay() }
    }
    
    var gridColor: UIColor = UIColor.whiteColor() {
        didSet { setNeedsDisplay() }
    }
        
    var deviceCoordinates: [Coordinate] = [] {
        didSet { setNeedsDisplay() }
    }
    
    var deviceColor: UIColor = .orangeColor()
    
    init() {
        super.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        
        CGContextSetFillColorWithColor(context, backgroundColor?.CGColor)
        CGContextFillRect(context, rect)
        
        context => drawGrid(rect)
        context => drawDevices(rect)
    }
    
    private func drawDevices(rect: CGRect)(context: CGContextRef) {
        CGContextSetFillColorWithColor(context, deviceColor.CGColor)
        let rowHeight = rect.height / CGFloat(gridSize.rows)
        let columnWidth = rect.width / CGFloat(gridSize.columns)
        deviceCoordinates.forEach { coord in
            let tileRect = CGRectMake(columnWidth * CGFloat(coord.x), rowHeight * CGFloat(coord.y), columnWidth, rowHeight)
            CGContextFillEllipseInRect(context, tileRect)
        }
    }
    
    private func drawGrid(rect: CGRect)(context: CGContextRef) {
        CGContextSetFillColorWithColor(context, gridColor.CGColor)
        let gridSeparatorThickness: CGFloat = 1
        for var c = 1; c < gridSize.columns; c++ {
            let columnPos = (rect.width / CGFloat(gridSize.columns)) * CGFloat(c)
            let rect = CGRectMake(columnPos, 0, gridSeparatorThickness, rect.height)
            CGContextFillRect(context, rect)
        }
        
        for var r = 1; r < gridSize.rows; r++ {
            let rowPos = (rect.height / CGFloat(gridSize.rows)) * CGFloat(r)
            let rect = CGRectMake(0, rowPos, rect.width, gridSeparatorThickness)
            CGContextFillRect(context, rect)
        }
    }
}