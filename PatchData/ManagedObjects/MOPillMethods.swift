//
//  MOPillMethods.swift
//  PDKit
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
    public func setID() {
        if id == nil {
            id = UUID()
        }
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
    
    public func getID() -> UUID {
        if id == nil {
            self.setID()
        }
        return id!
    }
    
    /// Increments timesTakenToday and sets lastTaken to now.
    public func take() {
        timesTakenToday += 1
        lastTaken = Date() as NSDate
    }
    
    public func getDueDate() -> Date? {
        if let t1 = time1 as Time?, let t2 = time2 as Time? {
            do {
                let d = try PDPillHelper.nextDueDate(timesTakenToday: Int(timesTakenToday),
                                                     timesaday: Int(timesaday),
                                                     times: [t1, t2])
                return d
            } catch {
                print("Error: Not enough times, timesaday: \(timesaday), times.count: 2")
            }
        }
        return nil
    }
    
    // MARK: - State bools
    
    public func isExpired() -> Bool {
        if lastTaken != nil, let dueDate = getDueDate() {
            return Date() > dueDate
        }
        return false
    }
    
    /// Returns if the Pill was never taken.
    public func isNew() -> Bool {
        return getLastTaken() == nil
    }
    
    /// Returns if the pill has been taken all of its times today.
    public func isDone() -> Bool {
        if let timesaday = getTimesday() {
            let taken = Int(timesTakenToday)
            let times = Int(timesaday)
            return PDPillHelper.isDone(timesTakenToday: taken, timesaday: times)
        }
        return false
    }
    
    // MARK: - Maintenance
    
    /// Fixes issue when timesTakenToday is lying (start of next day).
    public func fixTakenToday() {
        if timesTakenToday > 0, let lastDate = getLastTaken(),
            !PDDateHelper.dateIsInToday(lastDate as Date) {
            timesTakenToday = 0
        }
    }
    
    /// Sets all attributes to either nil or -1.
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
