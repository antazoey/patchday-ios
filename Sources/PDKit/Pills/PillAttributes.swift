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

    public init() {
    }

    public var anyAttributeExists: Bool {
        name != nil ||
        expirationIntervalSetting != nil ||
        times != nil ||
        notify != nil ||
        timesTakenToday != nil ||
        lastTaken != nil ||
        xDays != nil
    }

    public var expirationInterval: PillExpirationInterval {
        let defaultInterval = DefaultPillAttributes.expirationInterval
        let interval = expirationIntervalSetting ?? defaultInterval
        return PillExpirationInterval(interval.rawValue, xDays: xDays)
    }
}