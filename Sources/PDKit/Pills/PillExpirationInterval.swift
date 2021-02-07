//
//  PillExpirationInterval.swift
//  PDKit
//
//  Created by Juliya Smith on 2/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class PillExpirationInterval {

    public var value: PillExpirationIntervalSetting
    private var _daysOne: Int?
    private var _daysTwo: Int?
    private let _daysRange =  PillExpirationInterval.daysRange
    private let _xDaysIntervals = PillExpirationInterval.xDaysIntervals
    private let _singleXDayIntervals = PillExpirationInterval.singleXDayIntervals

    /// Either will initialize from a supported value or try to migrate an older value.
    public convenience init(_ rawValue: String, xDays: String?) {
        if let value = PillExpirationIntervalSetting(rawValue: rawValue) {
            self.init(value, xDays: xDays)
        } else {
            // Value not found. Try to migrate an older value...
            self.init(rawValue)
        }
    }

    /// The normal initializer that would exist if we did not have to include migrations.
    /// It will take a given xDays stored value and convert it to the days integer values. Call `.xDays` to form the new value.
    public init(_ value: PillExpirationIntervalSetting, xDays: String?) {
        self.value = value
        guard let days = xDays else { return }
        let daysResult = PillExpirationInterval.parseDays(value, days)
        self._daysOne = daysResult.0
        self._daysTwo = daysResult.1
    }

    public convenience init(_ value: PillExpirationIntervalSetting) {
        self.init(value, xDays: nil)
    }

    /// Migrates older values such as `firstTenDays` ( and similar ones) to use the new model.
    public init(_ rawValue: String) {
        let newOptionForFirstXDays = PillExpirationIntervalSetting.FirstXDays.rawValue
        let newOptionForLastDays = PillExpirationIntervalSetting.LastXDays.rawValue
        var value: PillExpirationIntervalSetting?
        if rawValue == "firstTenDays" {
            self._daysOne = 10
            value = PillExpirationIntervalSetting(rawValue: newOptionForFirstXDays)
        } else if rawValue == "firstTwentyDays" {
            self._daysOne = 20
            value = PillExpirationIntervalSetting(rawValue: newOptionForFirstXDays)
        } else if rawValue == "lastTenDays" {
            self._daysOne = 10
            value = PillExpirationIntervalSetting(rawValue: newOptionForLastDays)
        } else if rawValue == "lastTwentyDays" {
            self._daysOne = 20
            value = PillExpirationIntervalSetting(rawValue: newOptionForLastDays)
        }
        self.value = value ?? DefaultPillAttributes.expirationInterval
    }

    public static var daysRange: ClosedRange<Int> {
        1...SupportedPillExpirationIntervalDaysLimit
    }

    public static var singleXDayIntervals: [PillExpirationIntervalSetting] {
        [.FirstXDays, .LastXDays]
    }

    public static var xDaysIntervals: [PillExpirationIntervalSetting] {
        singleXDayIntervals + [.XDaysOnXDaysOff]
    }

    public var daysOne: Int? {
        get { _daysOne }
        set {
            if let newValue = newValue {
                guard _daysRange ~= newValue else { return }
                self._daysOne = newValue
            }
        }
    }
    public var daysTwo: Int? {
        get { _daysTwo }
        set {
            if let newValue = newValue {
                guard _daysRange ~= newValue else { return }
                self._daysTwo = newValue
            }
        }
    }

    /// The string value of the first days property; only applies to expiration intervals that use X days.
    public var daysOn: String? {
        guard usesXDays else { return nil }
        guard let days = daysOne else { return DefaultPillAttributes.xDaysString }
        return String(days)
    }

    /// The string value of the second days property; only applies to `.XDaysOnXDaysOff`.
    public var daysOff: String? {
        guard value == .XDaysOnXDaysOff else { return nil }
        guard let days = daysTwo else { return  DefaultPillAttributes.xDaysString }
        return String(days)
    }

    /// Returns `true` if `.value` involves the use of optional setting "days", such as "the first X days of the month".
    public var usesXDays: Bool {
        _xDaysIntervals.contains(self.value)
    }

    /// The combined days value that gets stored on disc, e.g. "5-12" meaning 5 days on, 12 days off.
    public var xDays: String? {
        guard let daysOn = daysOn else { return nil }
        if _singleXDayIntervals.contains(value) {
            return daysOn
        } else if value == PillExpirationIntervalSetting.XDaysOnXDaysOff {
            if let daysOff = daysOff {
                return "\(daysOn)-\(daysOff)"
            }
        }
        return daysOn
    }

    /// All of the available PillExpirationIntervalSetting enum values.
    public static var options: [PillExpirationIntervalSetting] {
        [
            .EveryDay,
            .EveryOtherDay,
            .FirstXDays,
            .LastXDays,
            .XDaysOnXDaysOff
        ]
    }

    private static func parseDays(
        _ interval: PillExpirationIntervalSetting, _ xDays: String
    ) -> (Int?, Int?) {
        if interval == .XDaysOnXDaysOff {
            return parseMultipleDays(xDays)
        } else if singleXDayIntervals.contains(interval) {
            let days = parseIntFromXDaysValue(xDays) ?? DefaultPillAttributes.xDaysInt
            return (days, nil)
        }
        return (nil, nil)
    }

    private static func parseMultipleDays(_ xDays: String) -> (Int?, Int?) {
        var daysOne = DefaultPillAttributes.xDaysInt
        var daysTwo = DefaultPillAttributes.xDaysInt

        let daysList = xDays.split(separator: "-")
        if daysList.count > 0, let days = parseIntFromXDaysValue(String(daysList[0])) {
            daysOne = days
        }
        if daysList.count > 1, let days = parseIntFromXDaysValue(String(daysList[1])) {
            daysTwo = days
        }
        return (daysOne, daysTwo)
    }

    private static func parseIntFromXDaysValue(_ value: String) -> Int? {
        if value.contains("-") {
            return parseMultipleDays(value).0
        } else if let days = Int(value), daysRange ~= days {
            return days
        }
        return nil
    }
}
