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
import PDKit

extension MOPill {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOPill> {
        return NSFetchRequest<MOPill>(entityName: "Pill")
    }

    @NSManaged private var lastTaken: NSDate?
    @NSManaged private var name: String?
    @NSManaged private var notify: Bool
    @NSManaged private var time1: NSDate?
    @NSManaged private var time2: NSDate?
    @NSManaged private var timesaday: Int16
    @NSManaged private var timesTakenToday: Int16
    @NSManaged private var id: UUID?
    
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
        if newTimesaday >= 0 {
            timesaday = newTimesaday
            time2 = nil
        }
    }
    
    public func setTime1(with newTime: NSDate) {
        time1 = newTime
    }
    
    public func setTime2(with newTime: NSDate) {
        if let t1 = time1 as Time? {
            let t2 = newTime as Time
            if t2 >= t1 {
                time2 = newTime
            } else {
                // t1 < t2
                // swap times if time2 is smaller than time1
                time2 = time1
                time1 = newTime
            }
        } else {
            // set both times to new time if time1 is not a time
            time1 = newTime
            time2 = newTime
        }
    }
    
    public func setNotify(with newNotify: Bool) {
        notify = newNotify
    }
    
    public func setId() -> UUID {
        let id = UUID()
        self.id = id
        return id
    }
    
    public func setLastTaken(with last: NSDate) {
        lastTaken = last
    }
    
    public func setTimesTakenToday(with times: Int16) {
        if (times <= timesaday) {
            timesTakenToday = times
        }
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
    
    public func getId() -> UUID? {
        return id
    }
    
    /// Increments timesTakenToday and sets lastTaken to now.
    public func take() {
        if timesTakenToday < timesaday {
            timesTakenToday += 1
            lastTaken = Date() as NSDate
        }
    }
    
    public func due() -> Date? {
        if let t1 = time1 as Time? {
            do {
                let todays = Int(timesTakenToday)
                let goal = Int(timesaday)
                var times = [t1]
                if let t2 = time2 {
                    times.append(t2 as Time)
                }
                let d = try PDPillHelper.nextDueDate(timesTakenToday: todays,
                                                     timesaday: goal,
                                                     times: times)
                return d
            } catch {
                print("Error: Not enough times, timesaday: "
                      + "\(timesaday), times.count: 2")
            }
        }
        return nil
    }
    
    // MARK: - State bools
    
    public func isExpired() -> Bool {
        if lastTaken != nil, let dueDate = due() {
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
            return PDPillHelper.isDone(timesTakenToday: taken,
                                       timesaday: times)
        }
        return false
    }
    
    // MARK: - Maintenance
    
    /// Fixes issue when timesTakenToday is lying (start of next day).
    public func fixTakenToday() {
        if timesTakenToday > 0,
            let lastDate = getLastTaken() as Date?,
            !lastDate.isInToday() {
            timesTakenToday = 0
        }
    }
    
    /// Sets all attributes to either nil or -1.
    public func reset() {
        name = nil
        timesaday = 1
        time1 = nil
        time2 = nil
        notify = false
        timesTakenToday = 0
        lastTaken = nil
    }
}
