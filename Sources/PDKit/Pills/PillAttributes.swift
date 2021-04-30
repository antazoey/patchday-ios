//
//  PillAttributes.swift
//  PDKit
//
//  Created by Juliya Smith on 2/2/21.

import Foundation

public class PillAttributes {

    private let defaultName = PillStrings.NewPill
    private var _expirationInterval: PillExpirationInterval
    public var name: String?
    public var times: String?
    public var notify: Bool?
    public var lastTaken: Date?
    public var timesTakenToday: String?

    public init(
        name: String?,
        expirationIntervalSetting: PillExpirationIntervalSetting?,
        xDays: String?,
        times: String?,
        notify: Bool?,
        lastTaken: Date?,
        timesTakenToday: String?
    ) {
        self.name = name
        self._expirationInterval = PillExpirationInterval(
            expirationIntervalSetting, xDays: xDays
        )
        self.times = times
        self.notify = notify
        self.lastTaken = lastTaken
        self.timesTakenToday = timesTakenToday
    }

    public init(_ attributes: PillAttributes) {
        self.name = attributes.name
        self.times = attributes.times
        self.notify = attributes.notify
        self.lastTaken = attributes.lastTaken
        self.timesTakenToday = attributes.timesTakenToday
        let interval = attributes.expirationInterval.value
        let xDaysValue = attributes.expirationInterval.xDaysValue
        self._expirationInterval = PillExpirationInterval(interval, xDays: xDaysValue)
    }

    public init() {
        _expirationInterval = PillExpirationInterval(nil, xDays: nil)
    }

    /// Returns true if these attributes contain any non-nil attributes.
    /// Optionally pass in exceptions and it will also make sure
    /// the attribute is not equal to the property in the exceptions.
    public func anyAttributeExists(exclusions: PillAttributes? = nil) -> Bool {
        let exclusions = exclusions != nil ? exclusions! : PillAttributes()
        let nameExists = name != nil && name != exclusions.name
        let intervalExists = expirationInterval.value != nil
            && expirationInterval.value != exclusions.expirationInterval.value
        let timesExists = times != nil && times != exclusions.times
        let notifyExists = notify != nil && notify != exclusions.notify
        let lastTakenExists = lastTaken != nil && lastTaken != exclusions.lastTaken
        let timesTakenTodayExists = timesTakenToday != nil
            && timesTakenToday != exclusions.timesTakenToday

        return nameExists
            || intervalExists
            || timesExists
            || timesTakenTodayExists
            || notifyExists
            || lastTakenExists
            || timesTakenTodayExists
    }

    /// Update this instance's properties with the given ones. This does not update if the given property is nil.
    public func update(_ attributes: PillAttributes) {
        name = attributes.name ?? name
        times = attributes.times ?? times
        notify = attributes.notify != nil ? attributes.notify : notify
        lastTaken = attributes.lastTaken ?? lastTaken
        timesTakenToday = attributes.timesTakenToday ?? timesTakenToday

        let interval = attributes.expirationInterval.value ?? expirationInterval.value
        let days = attributes.expirationInterval.xDaysValue ?? expirationInterval.xDaysValue
        _expirationInterval = PillExpirationInterval(interval, xDays: days)
    }

    /// The expiration interval object.
    public var expirationInterval: PillExpirationInterval {
        _expirationInterval
    }

    /// Set all properties to nil.
    public func reset() {
        name = nil
        _expirationInterval.value = nil
        times = nil
        notify = nil
        lastTaken = nil
        timesTakenToday = nil
    }
}
