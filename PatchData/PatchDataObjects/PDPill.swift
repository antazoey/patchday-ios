//
//  PDPill.swift
//  PatchData
//
//  Created by Juliya Smith on 9/2/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PDPill: PDObject, Swallowable, Comparable {
    
    private var moPill: MOPill {
        return mo as! MOPill
    }
    
    public init(pill: MOPill) {
        super.init(mo: pill)
        initialize()
    }
    
    public init(pill: MOPill, name: String) {
        super.init(mo: pill)
        initialize(name: name)
    }

    /// Factory method
    public static func new() -> Swallowable? {
        if let mo = PatchData.insert(.pill) as? MOPill {
            let pill = PDPill(pill: mo)
            pill.initialize()
            return pill
        }
        return nil
    }
    
    public var id: UUID {
        get {
            return moPill.id ?? {
                let newId = UUID()
                moPill.id = newId
                return newId
            }()
        }
        set { moPill.id = newValue }
    }

    public var name: String {
        get { return moPill.name ?? PDSiteStrings.unplaced }
        set { moPill.name = newValue }
    }

    public var time1: Date {
        get {
            if let t1 = moPill.time1 {
                return t1 as Date
            }
            return Date.createDefaultDate()
        }
        set { moPill.time1 = newValue as NSDate? }
    }

    public var time2: Date {
        get {
            if let t2 = moPill.time2 {
                return t2 as Date
            }
            return Date.createDefaultDate()
        } set {
            if time1 >= time2 {
                moPill.time2 = newValue as NSDate?
            } else {
                // swap times if time2 is smaller than time1
                moPill.time1 = moPill.time2
                moPill.time2 = newValue as NSDate
            }
        }
    }

    public var notify: Bool {
        get { return moPill.notify }
        set { moPill.notify = newValue }
    }
    
    public var timesaday: Int {
        get { return Int(moPill.timesaday) }
        set {
            if newValue >= 0 {
                moPill.timesaday = Int16(newValue)
                moPill.time2 = nil
            }
        }
    }

    public var timesTakenToday: Int {
        get { return Int(moPill.timesTakenToday) }
        set {
            if newValue <= moPill.timesTakenToday {
                moPill.timesTakenToday = Int16(newValue)
            }
        }
    }

    public var lastTaken: Date? {
        get { return moPill.lastTaken as Date? }
        set { moPill.lastTaken = newValue as NSDate? }
    }

    public var due: Date {
        if let t1 = moPill.time1 as Time? {
            do {
                let todays = Int(moPill.timesTakenToday)
                let goal = Int(moPill.timesaday)
                var times: [Time] = [t1]
                if let t2 = moPill.time2 {
                    times.append(t2 as Time)
                }
                return try PDPillHelper.nextDueDate(
                    timesTakenToday: todays,
                    timesaday: goal,
                    times: times
                    ) ?? Date()
            } catch PDPillHelper.NextDueDateError.notEnoughTimes {
                return handleNotEnoughTimesError(t1: t1) ?? Date()
            } catch {
                return Date()
            }
        }
        return Date()
    }

    public var isDue: Bool {
        return Date() > due
    }
    
    public var isNew: Bool {
        return moPill.lastTaken == nil
    }
    
    public var isDone: Bool {
        return PDPillHelper.isDone(
            timesTakenToday: timesTakenToday, timesaday: timesaday
        )
    }
    
    public func set(attributes: PillAttributes) {
        if let n = attributes.name {
            name = n
        }
        if let times = attributes.timesaday {
            timesaday = times
        }
        if let t1 = attributes.time1 {
            time1 = t1
        }
        if let t2 = attributes.time2 {
            time2 = t2
        }
        if let n = attributes.notify {
            notify = n
        }
        if let timesTaken = attributes.timesTakenToday {
            timesTakenToday = timesTaken
        }
        if let last = attributes.lastTaken {
            lastTaken = last
        }
        id = UUID()
    }

    public func swallow() {
        if moPill.timesTakenToday < moPill.timesaday {
            moPill.timesTakenToday += 1
            moPill.lastTaken = NSDate()
        }
    }

    public func awaken() {
        if timesTakenToday > 0,
            let lastDate = moPill.lastTaken as Date?,
            !lastDate.isInToday() {
    
            moPill.timesTakenToday = 0
        }
    }

    public func reset() {
        moPill.name = nil
        moPill.timesaday = 1
        moPill.time1 = nil
        moPill.time2 = nil
        moPill.notify = false
        moPill.timesTakenToday = 0
        moPill.lastTaken = nil
    }
    
    // MARK: - Comparable, nil is always at the end of a sort
    
    public static func < (lhs: PDPill, rhs: PDPill) -> Bool {
        let ld = lhs.due
        let rd = rhs.due
        switch (ld, rd) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return ld < rd
        }
    }
    
    public static func > (lhs: PDPill, rhs: PDPill) -> Bool {
        let ld = lhs.due
        let rd = rhs.due
        switch (ld, rd) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return ld > rd
        }
    }
    
    public static func == (lhs: PDPill, rhs: PDPill) -> Bool {
        let ld = lhs.due
        let rd = rhs.due
        switch (ld, rd) {
        case (nil, nil) : return true
        case (nil, _) : return false
        case (_, nil) : return false
        default : return ld == rd
        }
    }
    public static func != (lhs: PDPill, rhs: PDPill) -> Bool {
        let ld = lhs.due
        let rd = rhs.due
        switch (ld, rd) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return true
        default : return ld != rd
        }
    }
    
    private func initialize() {
        self.initialize(name: PDStrings.PlaceholderStrings.newPill)
    }
    
    private func initialize(name: String) {
        moPill.name = name
        moPill.timesaday = 1
        moPill.time1 = NSDate()
        moPill.time2 = NSDate()
        moPill.notify = true
        moPill.timesTakenToday = 0
        moPill.id = UUID()
    }
    
    private func handleNotEnoughTimesError(t1: Time) -> Date? {
        let c = [moPill.time1, moPill.time2].count
        if c < timesaday {
            let goal = Int(timesaday)
            // Set the dates that are missing
            for i in c..<goal {
                switch (i) {
                case 0: self.moPill.time1 = NSDate()
                case 1:
                    self.moPill.time2 = Time(timeInterval: 1000, since: t1 as Date) as NSDate
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
