//
//  Logger.swift
//  Cursor
//
//  Created by Simon Støvring on 09/11/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Foundation

class Logger {
    private var fields: [String] = []
    private var values: [[String]] = []
    private var startDate: NSDate?
    private let dateFormatter = NSDateFormatter()
    private(set) var isLogging = false
    
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
    }
    
    func startLogging(fields: [String]) {
        guard !isLogging else {
            fatalError("Logger is already logging. Logging must be stopped before it is started again.")
        }
        self.fields = fields
        startDate = NSDate()
        isLogging = true
    }
    
    func stopLogging() {
        guard isLogging else {
            fatalError("Logger is not logging. Logging must be started before it can be stopped.")
        }
        saveLog()
        startDate = nil
        fields.removeAll()
        values.removeAll()
        isLogging = false
    }
    
    func log(newValues: [String]) {
        guard isLogging else {
            fatalError("Logger is not started. The logger must be started before new entries can be logged.")
        }
        guard newValues.count == fields.count else {
            fatalError("Exepected \(fields.count) values but got \(newValues.count).")
        }
        values.append(newValues)
    }
    
    private func saveLog() {
        guard let startDate = startDate else { return }
        let header = fields.joinWithSeparator(",")
        let valuesStr = values.map { $0.joinWithSeparator(",") }.joinWithSeparator("\n")
        let content = header + "\n" + valuesStr
        let filePath = filePathForDate(startDate)
        
        do {
            try content.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            fatalError("Could not write content to file \(filePath).")
        }
    }
    
    private func filePathForDate(date: NSDate) -> String {
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first else {
            fatalError("Expected a documents path but did not find one.")
        }
        
        let fileName = dateFormatter.stringFromDate(date) + ".csv"
        return (documentsPath as NSString).stringByAppendingPathComponent(fileName) as String
    }
}