//
//  PDPill.swift
//  PatchData
//
//  Created by Juliya Smith on 9/2/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PDPill: Swallowable, Comparable {
    
    private let pill: MOPill
    
    public init(pill: MOPill, name: String) {
        self.pill = pill
        pill.name = name
        pill.timesaday = 1
        pill.time1 = NSDate()
        pill.time2 = NSDate()
        pill.notify = true
        pill.timesTakenToday = 0
        pill.id = UUID()
    }
    
    public var name: String {
        get { return mo.name ?? PDSiteStrings.unplaced }
        set { mo.name = newValue }
    }
    
    public var id: UUID {
        get { return pill.id ?? { let newId = UUID(); pill.id = newId; return newId }() }
        set { pill.id = newValue }
    }
    
    public var time1: NSDate {
        get { return pill.time1 ?? NSDate() }
        set { pill.time1 = newValue as NSDate? }
    }
    
    public var time2: NSDate {
        get { return pill.time2 ?? NSDate() }
        set {
            if time1.ge(time2) {
                pill.time2 = newValue as NSDate?
            } else {
                // swap times if time2 is smaller than time1
                pill.time1 = pill.time2
                pill.time2 = newValue as NSDate
            }
        }
    }
    
    public var notify: Bool {
        get { return pill.notify }
        set { pill.notify = newValue }
    }
    
    public var timesaday: Int16 {
        get { return pill.timesaday }
        set {
            if newValue >= 0 {
                pill.timesaday = newValue
                pill.time2 = nil
            }
        }
    }
    
    public var timesTakenToday: Int16 {
        get { return pill.timesTakenToday }
        set {
            if newValue <= pill.timesTakenToday {
                pill.timesTakenToday = newValue
            }
        }
    }
    
    public var lastTaken: NSDate? {
        get { return pill.lastTaken }
        set { pill.lastTaken = newValue }
    }
    
    public var due: Date? {
        get {
            if let t1 = pill.time1 as Time? {
                do {
                    let todays = Int(pill.timesTakenToday)
                    let goal = Int(pill.timesaday)
                    var times: [Time] = [t1]
                    if let t2 = pill.time2 {
                        times.append(t2 as Time)
                    }
                    return try PDPillHelper.nextDueDate(timesTakenToday: todays, timesaday: goal, times: times)
                } catch PDPillHelper.NextDueDateError.notEnoughTimes {
                    return handleNotEnoughTimesError(t1: t1)
                } catch {
                    return nil
                }
            }
            return nil
        }
    }
    
    public var isDue: Bool {
        get {
            if let dueDate = due {
                return Date() > dueDate
            }
            return false
        }
    }
    
    public var isNew: Bool {
        get { return pill.lastTaken == nil }
    }
    
    public var isDone: Bool {
        get {
            let taken = Int(pill.timesTakenToday)
            let times = Int(pill.timesaday)
            return PDPillHelper.isDone(timesTakenToday: taken, timesaday: times)
        }
    }
    
    /// Increments timesTakenToday and sets lastTaken to now.
    public func swallow() {
        if pill.timesTakenToday < pill.timesaday {
            pill.timesTakenToday += 1
            pill.lastTaken = NSDate()
        }
    }
    
    /// Fixes issue when timesTakenToday is lying (start of next day).
    public func awaken() {
        if timesTakenToday > 0, let lastDate = pill.lastTaken as Date?, !lastDate.isInToday() {
            pill.timesTakenToday = 0
        }
    }
    
    /// Sets all attributes to default values
    public func reset() {
        pill.name = nil
        pill.timesaday = 1
        pill.time1 = nil
        pill.time2 = nil
        pill.notify = false
        pill.timesTakenToday = 0
        pill.lastTaken = nil
    }
    
    // MARK: - Comparable, nil is always at the end of a sort
    
    public static func < (lhs: PDPill, rhs: PDPill) -> Bool {
        let ld = lhs.due
        let rd = rhs.due
        switch (ld, rd) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return ld! < rd!
        }
    }
    
    public static func > (lhs: PDPill, rhs: PDPill) -> Bool {
        let ld = lhs.due
        let rd = rhs.due
        switch (ld, rd) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return ld! > rd!
        }
    }
    
    public static func == (lhs: PDPill, rhs: PDPill) -> Bool {
        let ld = lhs.due
        let rd = rhs.due
        switch (ld, rd) {
        case (nil, nil) : return true
        case (nil, _) : return false
        case (_, nil) : return false
        default : return ld! == rd!
        }
    }
    public static func != (lhs: PDPill, rhs: PDPill) -> Bool {
        let ld = lhs.due
        let rd = rhs.due
        switch (ld, rd) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return true
        default : return ld! != rd!
        }
    }
    
    private func handleNotEnoughTimesError(t1: Time) -> Date? {
        let c = [pill.time1, pill.time2].filter() { $0 != nil }.count
        if c < timesaday {
            let goal = Int(timesaday)
            // Set the dates that are missing
            for i in c..<goal {
                switch (i) {
                case 0: self.mo.time1 = NSDate()
                case 1:
                    self.mo.time2 = Time(timeInterval: 1000, since: t1 as Date) as NSDate
                default :
                    break
                }
            }
            // Retry due, this time there should be enough times
            return due
        }
        return nil
    }
}
