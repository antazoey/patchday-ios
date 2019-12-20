//
//  Pill.swift
//  PatchData
//
//  Created by Juliya Smith on 9/2/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class Pill: PDObject, Swallowable, Comparable {
    
    private var moPill: MOPill { mo as! MOPill }

    private var times: [Time] {
        var _times: [Time] = []
        if let t1 = moPill.time1 {
            _times.append(t1 as Time)
        }
        if let t2 = moPill.time2 {
            _times.append(t2 as Time)
        }
        return _times
    }
    
    public init(pill: MOPill) {
        super.init(mo: pill)
        initialize()
    }
    
    public init(pill: MOPill, name: String) {
        super.init(mo: pill)
        initialize(name: name)
    }

    public var id: UUID {
        get {
            moPill.id ?? {
                let newId = UUID()
                moPill.id = newId
                return newId
            }()
        }
        set { moPill.id = newValue }
    }

    public var name: String {
        get { moPill.name ?? SiteStrings.unplaced }
        set { moPill.name = newValue }
    }

    public var time1: Date {
        get { moPill.time1 as Date? ?? Date.createDefaultDate() }
        set { moPill.time1 = newValue as NSDate? }
    }

    public var time2: Date {
        get {
            if let t2 = moPill.time2 {
                return t2 as Date
            }
            return Date.createDefaultDate()
        } set {
            if let time1 = moPill.time1 as Date? {
                let newStoredDate = newValue as NSDate
                if newValue < time1 {
                    moPill.time2 = time1 as NSDate
                    moPill.time1 = newStoredDate
                } else {
                    moPill.time2 = newStoredDate
                }
            }
        }
    }

    public var notify: Bool {
        get { moPill.notify }
        set { moPill.notify = newValue }
    }
    
    public var timesaday: Int {
        get { Int(moPill.timesaday) }
        set {
            if newValue >= 0 {
                moPill.timesaday = Int16(newValue)
                moPill.time2 = nil
            }
        }
    }

    public var timesTakenToday: Int {
        get { Int(moPill.timesTakenToday) }
        set {
            if newValue <= moPill.timesTakenToday {
                moPill.timesTakenToday = Int16(newValue)
            }
        }
    }

    public var lastTaken: Date? {
        get { moPill.lastTaken as Date? }
        set { moPill.lastTaken = newValue as NSDate? }
    }

    public var due: Date {
        do {
            return try PillHelper.nextDueDate(pillDueDateFinderParams) ?? Date()
        } catch PillHelper.NextDueDateError.notEnoughTimes {
            return handleNotEnoughTimesError()
        } catch {
            return Date()
        }
    }

    public var isDue: Bool { Date() > due }
    
    public var isNew: Bool { moPill.lastTaken == nil }
    
    public var isDone: Bool {
        PillHelper.isDone(timesTakenToday: timesTakenToday, timesaday: timesaday)
    }
    
    public func set(attributes: PillAttributes) {
        name = attributes.name ?? name
        timesaday = attributes.timesaday ?? timesaday
        time1 = attributes.time1 ?? time1
        time2 = attributes.time2 ?? time2
        notify = attributes.notify ?? notify
        timesTakenToday = attributes.timesTakenToday ?? timesTakenToday
        lastTaken = attributes.lastTaken ?? lastTaken
    }

    public func swallow() {
        if timesTakenToday < timesaday {
            timesTakenToday += 1
            lastTaken = Date()
        }
    }

    public func awaken() {
        if timesTakenToday > 0,
            let lastDate = lastTaken as Date?,
            !lastDate.isInToday() {
    
            timesTakenToday = 0
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
    
    public func isEqualTo(_ otherPill: Swallowable) -> Bool {
        id == otherPill.id
    }
    
    // MARK: - Comparable, nil is always at the end of a sort
    
    public static func < (lhs: Pill, rhs: Pill) -> Bool {
        lhs.due < rhs.due
    }
    
    public static func > (lhs: Pill, rhs: Pill) -> Bool {
        lhs.due > rhs.due
    }
    
    public static func == (lhs: Pill, rhs: Pill) -> Bool {
        lhs.due == rhs.due
    }
    public static func != (lhs: Pill, rhs: Pill) -> Bool {
        lhs.due != rhs.due
    }

    private var pillDueDateFinderParams: PillDueDateFinderParams {
        PillDueDateFinderParams(timesTakenToday, timesaday, times)
    }

    private func ensureTimeOrdering() {
        if self.time2 < time1 || self.time1 > time2{
            self.time2 = time1
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
    
    private func handleNotEnoughTimesError() -> Date {
        if times.count < timesaday {
            addMissingTimes()
            return due
        }
        return Date()
    }

    private func addMissingTimes() {
        for i in times.count..<timesaday {
            addMissingTime(timeIndex: i)
        }
    }

    private func addMissingTime(timeIndex: Index) {
        if timeIndex == 0 {
            time1 = Date()
        } else if timeIndex == 1 {
            addMissingTimeTwo()
        }
    }

    private func addMissingTimeTwo() {
        if let time1 = moPill.time1 as Date? {
            self.moPill.time2 = Time(timeInterval: 1000, since: time1) as NSDate
        } else {
            self.moPill.time2 = Time() as NSDate
        }
    }
}
