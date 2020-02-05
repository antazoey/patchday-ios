//
//  Pill.swift
//  PatchData
//
//  Created by Juliya Smith on 9/2/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class Pill: Swallowable {

    private var pillData: PillStruct
    private let log = PDLog<Pill>()

    public init(pillData: PillStruct) {
        self.pillData = pillData
    }
    
    public init(pillData: PillStruct, name: String) {
        self.pillData = pillData
    }

    public var id: UUID {
        get { pillData.id }
        set { pillData.id = newValue }
    }

    public var attributes: PillAttributes {
        PillAttributes(name: name,
            timesaday: timesaday,
            time1: time1,
            time2: time2,
            notify: notify,
            timesTakenToday: timesTakenToday,
            lastTaken: lastTaken
        )
    }

    public var name: String {
        get { pillData.attributes.name ?? SiteStrings.Unplaced }
        set { pillData.attributes.name = newValue }
    }

    public var time1: Date {
        get { pillData.attributes.time1 as Date? ?? Date.createDefaultDate() }
        set { pillData.attributes.time1 = newValue }
    }

    public var time2: Date {
        get {
            guard let t2 = pillData.attributes.time2 else {
                return Date.createDefaultDate()
            }
            return t2 as Date
        } set {
            if let time1 = pillData.attributes.time1 as Date? {
                if newValue < time1 {
                    pillData.attributes.time2 = time1
                    pillData.attributes.time1 = newValue
                } else {
                    pillData.attributes.time2 = newValue
                }
            }
        }
    }

    public var notify: Bool {
        get { pillData.attributes.notify ?? false }
        set { pillData.attributes.notify = newValue }
    }
    
    public var timesaday: Int {
        get { pillData.attributes.timesaday ?? DefaultPillAttributes.timesaday }
        set {
            if newValue >= 0 {
                pillData.attributes.timesaday = newValue
                if newValue < 2 {
                    pillData.attributes.time2 = nil
                }
            }
        }
    }

    public var timesTakenToday: Int {
        pillData.attributes.timesTakenToday ?? 0
    }

    public var lastTaken: Date? {
        get { pillData.attributes.lastTaken }
        set { pillData.attributes.lastTaken = newValue }
    }

    public var due: Date? {
        guard timesTakenToday <= timesaday else { return nil }

        if timesTakenToday == 0 {
            return DateHelper.getDate(at: time1)
        } else if timesTakenToday == 1 {
            return DateHelper.getDate(at: time2)
        } else {
            return DateHelper.getDate(at: time1, daysFromToday: 1)
        }
    }

    public var isDue: Bool {
        if let dueDate = due {
            return Date() > dueDate
        }
        return false
    }
    
    public var isNew: Bool { pillData.attributes.lastTaken == nil }
    
    public var isDone: Bool {
        PillHelper.isDone(timesTakenToday: timesTakenToday, timesaday: timesaday)
    }
    
    public func set(attributes: PillAttributes) {
        name = attributes.name ?? name
        timesaday = attributes.timesaday ?? timesaday
        time1 = attributes.time1 ?? time1
        time2 = attributes.time2 ?? time2
        notify = attributes.notify ?? notify
        lastTaken = attributes.lastTaken ?? lastTaken
    }

    public func swallow() {
        if timesTakenToday < timesaday {
            pillData.attributes.timesTakenToday = (pillData.attributes.timesTakenToday ?? 0) + 1
            lastTaken = Date()
        }
    }

    public func awaken() {
        if timesTakenToday > 0,
            let lastDate = lastTaken as Date?,
            !lastDate.isInToday() {
    
            pillData.attributes.timesTakenToday = 0
        }
    }

    public func reset() {
        pillData.attributes.name = nil
        pillData.attributes.timesaday = DefaultPillAttributes.timesaday
        pillData.attributes.time1 = DefaultPillAttributes.time
        pillData.attributes.time2 = nil
        pillData.attributes.notify = DefaultPillAttributes.notify
        pillData.attributes.timesTakenToday = DefaultPillAttributes.timesTakenToday
        pillData.attributes.lastTaken = nil
    }

    private var pillDueDateFinderParams: PillDueDateFinderParams {
        PillDueDateFinderParams(timesTakenToday, timesaday, times)
    }

    private var times: [Time] {
        var _times: [Time] = []
        if let t1 = pillData.attributes.time1 {
            _times.append(t1 as Time)
        }
        if let t2 = pillData.attributes.time2 {
            _times.append(t2 as Time)
        }
        return _times
    }

    private func ensureTimeOrdering() {
        if self.time2 < time1 || self.time1 > time2{
            self.time2 = time1
        }
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
        if let time1 = pillData.attributes.time1 {
            pillData.attributes.time2 = Time(timeInterval: 1000, since: time1)
        } else {
            pillData.attributes.time2 = Time()
        }
    }
}
