//
//  PillAttributes.swift
//  PDKit
//
//  Created by Juliya Smith on 2/4/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class PillAttributes {
    private let defaultName = PillStrings.NewPill
    public var description: String { "Pill DTO" }

    // Pill Properties
    public var name: String?
    public var expirationIntervalSetting: PillExpirationIntervalSetting?
    public var times: String?
    public var notify: Bool?
    public var timesTakenToday: Int?
    public var lastTaken: Date?
    public var xDays: String?

    public init(
        name: String?,
        expirationIntervalSetting: PillExpirationIntervalSetting?,
        times: String?,
        notify: Bool?,
        timesTakenToday: Int?,
        lastTaken: Date?,
        xDays: String?
    ) {
        self.name = name
        self.expirationIntervalSetting = expirationIntervalSetting
        self.times = times
        self.notify = notify
        self.timesTakenToday = timesTakenToday
        self.lastTaken = lastTaken
        self.xDays = xDays
    }

    public init(_ attributes: PillAttributes) {
        self.name = attributes.name
        self.expirationIntervalSetting = attributes.expirationIntervalSetting
        self.times = attributes.times
        self.notify = attributes.notify
        self.timesTakenToday = attributes.timesTakenToday
        self.lastTaken = attributes.lastTaken
        self.xDays = attributes.xDays
    }

    public init() {
    }

    public func anyAttributeExists(exceptions: PillAttributes? = nil) -> Bool {
        // TODO: Adjust tests
        let exceptions = exceptions != nil ? exceptions! : PillAttributes()
        let nameExists = name != nil && name != exceptions.name
        let intervalExists = expirationIntervalSetting != nil
            && expirationIntervalSetting != exceptions.expirationIntervalSetting
        let timesExists = times != nil && times != exceptions.times
        let notifyExists = notify != nil && notify != exceptions.notify
        let timesTakenTodayExists = timesTakenToday != nil
            && timesTakenToday != exceptions.timesTakenToday
        let lastTakenExists = lastTaken != nil && lastTaken != exceptions.lastTaken
        let xDaysExists = xDays != nil && xDays != exceptions.xDays

        return nameExists
            || intervalExists
            || timesExists
            || timesTakenTodayExists
            || notifyExists
            || timesTakenTodayExists
            || lastTakenExists
            || xDaysExists
    }

    public var expirationInterval: PillExpirationInterval {
        let defaultInterval = DefaultPillAttributes.expirationInterval
        let interval = expirationIntervalSetting ?? defaultInterval
        return PillExpirationInterval(interval.rawValue, xDays: xDays)
    }

    public func reset() {
        name = nil
        expirationIntervalSetting = nil
        times = nil
        notify = nil
        timesTakenToday = nil
        lastTaken = nil
        xDays = nil
    }
}
