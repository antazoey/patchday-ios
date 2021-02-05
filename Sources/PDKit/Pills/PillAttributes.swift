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
    public var expirationInterval: PillExpirationIntervalSetting?
    public var times: String?
    public var notify: Bool?
    public var timesTakenToday: Int?
    public var lastTaken: Date?
    public var xDays: String?

    public init(
        name: String?,
        expirationInterval: PillExpirationIntervalSetting?,
        times: String?,
        notify: Bool?,
        timesTakenToday: Int?,
        lastTaken: Date?,
        xDays: String?
    ) {
        self.name = name
        self.expirationInterval = expirationInterval
        self.times = times
        self.notify = notify
        self.timesTakenToday = timesTakenToday
        self.lastTaken = lastTaken
        self.xDays = xDays
    }

    public init() {
    }

    public var anyAttributeExists: Bool {
        name != nil ||
        expirationInterval != nil ||
        times != nil ||
        notify != nil ||
        timesTakenToday != nil ||
        lastTaken != nil ||
        xDays != nil
    }

    public var expirationIntervalObject: PillExpirationInterval {
        let defaultInterval = DefaultPillAttributes.expirationInterval
        let interval = expirationInterval ?? defaultInterval
        return PillExpirationInterval(interval.rawValue, xDays: xDays)
    }

    public func setDaysOne(_ value: Int) {
        // TODO: Test
        guard expirationIntervalObject.usesXDays else { return }
        guard value > 0 && value <= SupportedPillExpirationIntervalDaysLimit else { return }
        if expirationInterval == .FirstXDays || expirationInterval == .LastXDays {
            xDays = String(value)
        } else if expirationInterval == .XDaysOnXDaysOff {
            let daysTwo = expirationIntervalObject.daysTwo ?? DefaultPillAttributes.xDaysInt
            xDays = "\(value)-\(daysTwo)"
        }
    }

    public func setDaysTwo(_ value: Int) {
        // TODO: Test
        guard value > 0 && value <= SupportedPillExpirationIntervalDaysLimit else { return }
        let daysOne = expirationIntervalObject.daysOne ?? DefaultPillAttributes.xDaysInt
        xDays = "\(daysOne)-\(value)"
    }
}
