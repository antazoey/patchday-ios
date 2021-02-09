//
//  PillExpirationInterval.swift
//  PDKit
//
//  Created by Juliya Smith on 2/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class PillExpirationInterval {

    public var _value: PillExpirationIntervalSetting?
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
            // Value not found. Try to migrate an older value.
            self.init(rawValue)
        }
    }

    /// The normal initializer that would exist if we did not have to include migrations.
    /// It will take a `xDays` value and convert it to the days integer values. Call `.xDays` to form the new value for storing.
    public init(_ value: PillExpirationIntervalSetting?, xDays: String?) {
        self._value = value
        guard let days = xDays else { return }
        guard let value = value else { return }
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
        let newOptionForLastXDays = PillExpirationIntervalSetting.LastXDays.rawValue
        var value: PillExpirationIntervalSetting?
        if rawValue == "firstTenDays" {
            self._daysOne = 10
            value = PillExpirationIntervalSetting(rawValue: newOptionForFirstXDays)
        } else if rawValue == "firstTwentyDays" {
            self._daysOne = 20
            value = PillExpirationIntervalSetting(rawValue: newOptionForFirstXDays)
        } else if rawValue == "lastTenDays" {
            self._daysOne = 10
            value = PillExpirationIntervalSetting(rawValue: newOptionForLastXDays)
        } else if rawValue == "lastTwentyDays" {
            self._daysOne = 20
            value = PillExpirationIntervalSetting(rawValue: newOptionForLastXDays)
        }
        self._value = value
    }

    /// The value of the pill expiration interval, such as `.FirstXDays`.
    public var value: PillExpirationIntervalSetting? {
        get { _value }
        set {
            _value = newValue
            guard let val = newValue else {
                _daysOne = nil
                _daysTwo = nil
                return
            }
            if !_xDaysIntervals.contains(val) {
                _daysOne = nil
                _daysTwo = nil
            } else if _singleXDayIntervals.contains(val) {
                // .FirstXDays and .LastXDays
                _daysTwo = nil
            }
        }
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

    /// The supported range for any days value, 1-25.
    public static var daysRange: ClosedRange<Int> {
        1...SupportedPillExpirationIntervalDaysLimit
    }

    /// The intervals that only use `.daysOne` and not `.daysTwo`, namely: `.FirstXDays` and `.LastXDays`.
    public static var singleXDayIntervals: [PillExpirationIntervalSetting] {
        [.FirstXDays, .LastXDays]
    }

    /// All of the expiraiton interval values hat use the secondary `xDays` property.
    public static var xDaysIntervals: [PillExpirationIntervalSetting] {
        singleXDayIntervals + [.XDaysOnXDaysOff]
    }

    /// The integer version of the first days value in `xDays`; only applies to expiration intervals that use X days.
    public var daysOne: Int? {
        get { _daysOne }
        set {
            guard let val = value else { return }
            guard _xDaysIntervals.contains(val) else { return }
            if let days = newValue {
                guard _daysRange ~= days else { return }
                self._daysOne = days
            }
        }
    }

    /// The integer version of the second days value in `xDays`; only applies to `.XDaysOnXDaysOff`.
    public var daysTwo: Int? {
        get { _daysTwo }
        set {
            guard let val = value else { return }
            guard val == .XDaysOnXDaysOff else { return }
            if let newValue = newValue {
                guard _daysRange ~= newValue else { return }
                _daysTwo = newValue
            }
        }
    }

    /// The string value of the first days property; only applies to expiration intervals that use X days.
    public var daysOn: String? {
        guard usesXDays else { return nil }
        guard let days = daysOne else { return nil }
        return String(days)
    }

    /// The string value of the second days property; only applies to `.XDaysOnXDaysOff`.
    public var daysOff: String? {
        guard _value == .XDaysOnXDaysOff else { return nil }
        guard let days = daysTwo else { return nil }
        return String(days)
    }

    /// Returns `true` if `.value` involves the use of optional setting "days", such as "the first X days of the month".
    public var usesXDays: Bool {
        guard let value = self._value else { return false }
        return _xDaysIntervals.contains(value)
    }

    /// The combined days value that gets stored on disc, e.g. "5-12" meaning 5 days on, 12 days off.
    public var xDays: String? {
        guard let daysOn = daysOn else { return nil }
        guard let value = self._value else { return nil }
        if _singleXDayIntervals.contains(value) {
            return daysOn
        } else if value == PillExpirationIntervalSetting.XDaysOnXDaysOff {
            if let daysOff = daysOff {
                return "\(daysOn)-\(daysOff)"
            }
        }
        return daysOn
    }

    // MARK: - Private

    private static func parseDays(
        _ interval: PillExpirationIntervalSetting, _ xDays: String
    ) -> (Int?, Int?) {
        if interval == .XDaysOnXDaysOff {
            return parseMultipleDays(xDays)
        } else if singleXDayIntervals.contains(interval) {
            return (parseIntFromXDaysValue(xDays), nil)
        }
        return (nil, nil)
    }

    private static func parseMultipleDays(_ xDays: String) -> (Int?, Int?) {
        var daysOne: Int?
        var daysTwo: Int?

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
