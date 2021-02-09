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
    private var _expirationInterval: PillExpirationInterval
    public var name: String?
    public var times: String?
    public var notify: Bool?
    public var timesTakenToday: Int?
    public var lastTaken: Date?

    public init(
        name: String?,
        expirationIntervalSetting: PillExpirationIntervalSetting?,
        xDays: String?,
        times: String?,
        notify: Bool?,
        timesTakenToday: Int?,
        lastTaken: Date?
    ) {
        self.name = name
        self._expirationInterval = PillExpirationInterval(
            expirationIntervalSetting, xDays: xDays
        )
        self.times = times
        self.notify = notify
        self.timesTakenToday = timesTakenToday
        self.lastTaken = lastTaken
    }

    public init(_ attributes: PillAttributes) {
        self.name = attributes.name
        self.times = attributes.times
        self.notify = attributes.notify
        self.timesTakenToday = attributes.timesTakenToday
        self.lastTaken = attributes.lastTaken
        let interval = attributes.expirationIntervalSetting
        self._expirationInterval = PillExpirationInterval(interval, xDays: attributes.xDays)
    }

    public init() {
        _expirationInterval = PillExpirationInterval(nil, xDays: nil)
    }

    /// Returns true if these attributes contain any non-nil attributes. Optionally pass in exceptions and it will also make sure
    /// the attribute is not equal to the property in the exceptions.
    public func anyAttributeExists(exclusions: PillAttributes? = nil) -> Bool {
        let exclusions = exclusions != nil ? exclusions! : PillAttributes()
        let nameExists = name != nil && name != exclusions.name
        let intervalExists = expirationIntervalSetting != nil
            && expirationIntervalSetting != exclusions.expirationIntervalSetting
        let timesExists = times != nil && times != exclusions.times
        let notifyExists = notify != nil && notify != exclusions.notify
        let timesTakenTodayExists = timesTakenToday != nil
            && timesTakenToday != exclusions.timesTakenToday
        let lastTakenExists = lastTaken != nil && lastTaken != exclusions.lastTaken
        let xDaysExists = xDays != nil && xDays != exclusions.xDays

        return nameExists
            || intervalExists
            || timesExists
            || timesTakenTodayExists
            || notifyExists
            || timesTakenTodayExists
            || lastTakenExists
            || xDaysExists
    }

    /// Update this instance's properties with the given ones. This does not update if the given property is nil.
    public func update(_ attributes: PillAttributes) {
        name = attributes.name ?? name
        times = attributes.times ?? times
        notify = attributes.notify != nil ? attributes.notify : notify
        timesTakenToday = attributes.timesTakenToday ?? timesTakenToday
        lastTaken = attributes.lastTaken ?? lastTaken

        let interval = attributes.expirationIntervalSetting ?? expirationIntervalSetting
        let days = attributes.xDays ?? xDays
        _expirationInterval = PillExpirationInterval(interval, xDays: days)
    }

    public var expirationIntervalSetting: PillExpirationIntervalSetting? {
       expirationInterval.value
    }

    public var xDays: String? {
        expirationInterval.xDays
    }

    public var expirationInterval: PillExpirationInterval {
        _expirationInterval
    }

    public func reset() {
        name = nil
        _expirationInterval.value = nil
        _expirationInterval.daysOne = nil
        _expirationInterval.daysTwo = nil
        times = nil
        notify = nil
        timesTakenToday = nil
        lastTaken = nil
    }
}
