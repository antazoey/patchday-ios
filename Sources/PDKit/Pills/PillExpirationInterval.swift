//
//  PillExpirationInterval.swift
//  PDKit
//
//  Created by Juliya Smith on 2/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

// TODO: TESTS

public class PillExpirationInterval {

    public var value: PillExpirationIntervalSetting
    public var daysOne: Int?
    public var daysTwo: Int?

    public convenience init(_ rawValue: String, xDays: String?) {
        if let value = PillExpirationIntervalSetting(rawValue: rawValue) {
            self.init(value, days: xDays)
        } else {
            self.init(rawValue)
        }
    }

    public init(_ value: PillExpirationIntervalSetting, days: String?) {
        self.value = value
        guard let days = days else { return }

        // Parse days
        if value == .XDaysOnXDaysOff {
            let daysList = days.split(separator: "-")
            if daysList.count > 0 {
                self.daysOne = Int(daysList[0])
            }
            if daysList.count > 1 {
                self.daysTwo = Int(daysList[1])
            }
        } else if value == .FirstXDays || value == .LastXDays {
            self.daysOne = Int(days)
        }
    }

    public init(_ rawValue: String) {
        // Attempt to migrate an older value
        let newOptionForFirstXDays = PillExpirationIntervalSetting.FirstXDays.rawValue
        let newOptionForLastDays = PillExpirationIntervalSetting.LastXDays.rawValue
        var value: PillExpirationIntervalSetting?
        if rawValue == "firstTenDays" {
            self.daysOne = 10
            value = PillExpirationIntervalSetting(rawValue: newOptionForFirstXDays)
        } else if rawValue == "firstTwentyDays" {
            self.daysOne = 20
            value = PillExpirationIntervalSetting(rawValue: newOptionForFirstXDays)
        } else if rawValue == "lastTenDays" {
            self.daysOne = 10
            value = PillExpirationIntervalSetting(rawValue: newOptionForLastDays)
        } else if rawValue == "lastTwentyDays" {
            self.daysOne = 20
            value = PillExpirationIntervalSetting(rawValue: newOptionForLastDays)
        }
        self.value = value ?? DefaultPillAttributes.expirationInterval
    }

    public var usesXDays: Bool {
        xDaysIntervals.contains(self.value)
    }

    public var days: String? {
        guard let daysOne = daysOne else { return nil }
        let singleDaysIntervals = [
            PillExpirationIntervalSetting.FirstXDays,
            PillExpirationIntervalSetting.LastXDays
        ]
        if singleDaysIntervals.contains(value) {
            return String(daysOne)
        } else if value == PillExpirationIntervalSetting.XDaysOnXDaysOff {
            if let daysTwo = daysTwo {
                return "\(daysOne)-\(daysTwo)"
            }
        }
        return String(daysOne)
    }

    public static var options: [PillExpirationIntervalSetting] {
        [
            .EveryDay,
            .EveryOtherDay,
            .FirstXDays,
            .LastXDays,
            .XDaysOnXDaysOff
        ]
    }

    private var xDaysIntervals: [PillExpirationIntervalSetting] {
        [.FirstXDays, .LastXDays, .XDaysOnXDaysOff]
    }
}
