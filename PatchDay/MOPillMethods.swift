//
//  MOPill+CoreDataProperties.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData

extension MOPill {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOPill> {
        return NSFetchRequest<MOPill>(entityName: "Pill")
    }

    @NSManaged public var lastTaken: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var notify: Bool
    @NSManaged public var time1: NSDate?
    @NSManaged public var time2: NSDate?
    @NSManaged public var timesaday: Int16
    @NSManaged public var timesTakenToday: Int16
    @NSManaged public var id: UUID?
    
    public func initAttributes(name: String) {
        self.name = name
        self.timesaday = 1
        self.time1 = Time() as NSDate
        self.time2 = Time() as NSDate
        self.notify = true
        self.timesTakenToday = 0
        self.id = UUID()
    }
    
    // MARK: - Getters and setters
    
    public func setName(with newName: String) {
        name = newName
    }
    
    public func setTimesaday(with newTimesaday: Int16) {
        timesaday = newTimesaday
    }
    
    public func setTime1(with newTime: NSDate) {
        time1 = newTime
    }
    
    public func setTime2(with newTime: NSDate) {
        time2 = newTime
    }
    
    public func setNotify(with newNotify: Bool) {
        notify = newNotify
    }
    public func setID(with newID: UUID) {
        id = newID
    }
    
    public func setLastTaken(with newTime: NSDate) {
        lastTaken = newTime
    }
    
    public func setTimesTakenToday(with times: Int16) {
        timesTakenToday = times
    }
    
    public func getName() -> String? {
        return name
    }
    
    public func getTimesday() -> Int16? {
        return timesaday
    }
    
    public func getTime1() -> NSDate? {
        return time1
    }
    
    public func getTime2() -> NSDate? {
        return time2
    }
    
    public func getNotify() -> Bool? {
        return notify
    }
    
    public func getLastTaken() -> NSDate? {
        return lastTaken
    }
    
    public func getTimesTakenToday() -> Int16? {
        return timesTakenToday
    }
    
    public func getID() -> UUID? {
        return id
    }
    
    public func take() {
        timesTakenToday += 1
        lastTaken = Date() as NSDate
    }
    
    public func getDueDate() -> Date? {
        return PDPillHelper.nextDueDate(timesTakenToday: Int(timesTakenToday), timesaday: Int(timesaday), times: [time1, time2])
    }
    
    // MARK: - State bools
    
    public func isExpired() -> Bool {
        if let dueDate = getDueDate() {
            return Date() > dueDate
        }
        return false
    }
    
    public func isDone() -> Bool {
        if let timesaday = getTimesday() {
            return PDPillHelper.isDone(timesTakenToday: Int(timesTakenToday), timesaday: Int(timesaday))
        }
        return false
    }
    
    // MARK: - Maintenance
    
    /// Fixes issue when timesTakenToday is lying (start of next day).
    public func fixTakenToday() {
        if timesTakenToday > 0, let lastDate = getLastTaken(), !PDDateHelper.dateIsInToday(lastDate as Date) {
            timesTakenToday = 0
        }
    }
    
    public func reset() {
        name = nil
        timesaday = -1
        time1 = nil
        time2 = nil
        notify = false
        timesTakenToday = -1
        lastTaken = nil
    }

}
