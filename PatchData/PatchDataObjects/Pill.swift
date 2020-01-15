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
        get { pillData.attributes.name ?? SiteStrings.unplaced }
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
        get { pillData.attributes.timesaday ?? DefaultPillTimesaday }
        set {
            if newValue >= 0 {
                pillData.attributes.timesaday = newValue
                pillData.attributes.time2 = nil
            }
        }
    }

    public var timesTakenToday: Int {
        get { pillData.attributes.timesTakenToday ?? 0 }
        set {
            if let oldTimesTakenToday = pillData.attributes.timesTakenToday, newValue <= oldTimesTakenToday {
                pillData.attributes.timesTakenToday = newValue
            } else {
                pillData.attributes.timesTakenToday = newValue
            }
        }
    }

    public var lastTaken: Date? {
        get { pillData.attributes.lastTaken }
        set { pillData.attributes.lastTaken = newValue }
    }

    public var due: Date {
        do {
            return try PillHelper.nextDueDate(pillDueDateFinderParams) ?? Date()
        } catch PillHelper.NextDueDateError.notEnoughTimes {
            log.warn("Pill \(name) did not have enough times to calculate due date. System will correct.")
            return handleNotEnoughTimesError()
        } catch {
            log.error("Unknown error when calculating due date for pill \(name)")
            return Date()
        }
    }

    public var isDue: Bool { Date() > due }
    
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
        pillData.attributes.name = nil
        pillData.attributes.timesaday = 1
        pillData.attributes.time1 = nil
        pillData.attributes.time2 = nil
        pillData.attributes.notify = false
        pillData.attributes.timesTakenToday = 0
        pillData.attributes.lastTaken = nil
    }
    
    public func isEqualTo(_ otherPill: Swallowable) -> Bool {
        id == otherPill.id
    }

    private var pillDueDateFinderParams: PillDueDateFinderParams {
        PillDueDateFinderParams(timesTakenToday, timesaday, times)
    }

    private func ensureTimeOrdering() {
        if self.time2 < time1 || self.time1 > time2{
            self.time2 = time1
        }
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
        if let time1 = pillData.attributes.time1 {
            pillData.attributes.time2 = Time(timeInterval: 1000, since: time1)
        } else {
            pillData.attributes.time2 = Time()
        }
    }
}
