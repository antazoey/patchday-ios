//
//  PillExpirationInterval.swift
//  PDKit
//
//  Created by Juliya Smith on 2/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class PillExpirationInterval {

    private var _value: PillExpirationIntervalSetting?
    private var _xDays: PillExpirationIntervalXDays?
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
        if let xDaysValue = xDays, let val = value, _xDaysIntervals.contains(val) {
            self._xDays = PillExpirationIntervalXDays(xDaysValue)
        }
    }

    public convenience init(_ value: PillExpirationIntervalSetting) {
        self.init(value, xDays: nil)
    }

    /// Migrates older values such as `firstTenDays` ( and similar ones) to use the new model.
    public init(_ rawValue: String) {
        let newOptionForFirstXDays = PillExpirationIntervalSetting.FirstXDays.rawValue
        let newOptionForLastXDays = PillExpirationIntervalSetting.LastXDays.rawValue
        var value: PillExpirationIntervalSetting?
        var xDaysValue: String?
        if rawValue == "firstTenDays" {
            xDaysValue = "10"
            value = PillExpirationIntervalSetting(rawValue: newOptionForFirstXDays)
        } else if rawValue == "firstTwentyDays" {
            xDaysValue = "20"
            value = PillExpirationIntervalSetting(rawValue: newOptionForFirstXDays)
        } else if rawValue == "lastTenDays" {
            xDaysValue = "10"
            value = PillExpirationIntervalSetting(rawValue: newOptionForLastXDays)
        } else if rawValue == "lastTwentyDays" {
            xDaysValue = "20"
            value = PillExpirationIntervalSetting(rawValue: newOptionForLastXDays)
        }
        self._value = value
        if let xDaysValue = xDaysValue {
            self._xDays = PillExpirationIntervalXDays(xDaysValue)
        }
    }

    /// The value of the pill expiration interval, such as `.FirstXDays`.
    public var value: PillExpirationIntervalSetting? {
        get { _value }
        set {
            _value = newValue

            // Correct any xDays values
            guard let val = newValue, _xDaysIntervals.contains(val) else {
                _xDays = nil
                return
            }
            guard let xDays = _xDays else {
                return
            }
            if _singleXDayIntervals.contains(val) {
                xDays.two = nil
            }
        }
    }

    public var xDaysValue: String? {
        guard usesXDays else { return nil }
        return _xDays?.value
    }

    public var daysOne: Int? {
        get { _xDays?.one }
        set {
            if let xDays = _xDays {
                xDays.one = newValue
            } else if let val = newValue {
                _xDays = PillExpirationIntervalXDays("\(val)")
            }
        }
    }

    public var daysOn: String? {
        guard let val = value else { return nil }
        guard _xDaysIntervals.contains(val) else { return nil }
        return _xDays?.daysOn
    }

    public var daysTwo: Int? {
        get {
            guard usesXDays else { return nil }
            return _xDays?.two
        }
        set {
            if let xDays = _xDays {
                xDays.two = newValue
            } else if let val = newValue {
                _xDays = PillExpirationIntervalXDays("\(val)")
            }
        }
    }

    public var daysOff: String? {
        guard usesXDays else { return nil }
        return _xDays?.daysOff
    }

    public var xDaysIsOn: Bool? {
        guard usesXDays else { return nil }
        return _xDays?.isOn
    }

    public var xDaysPosition: Int? {
        guard usesXDays else { return nil }
        return _xDays?.position
    }

    public func startPositioning() {
        guard usesXDays else { return }
        _xDays?.startPositioning()
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

    /// The intervals that only use `.daysOne` and not `.daysTwo`, namely: `.FirstXDays` and `.LastXDays`.
    public static var singleXDayIntervals: [PillExpirationIntervalSetting] {
        [.FirstXDays, .LastXDays]
    }

    /// All of the expiraiton interval values hat use the secondary `xDays` property.
    public static var xDaysIntervals: [PillExpirationIntervalSetting] {
        singleXDayIntervals + [.XDaysOnXDaysOff]
    }

    /// Returns `true` if `.value` involves the use of optional setting "days", such as "the first X days of the month".
    public var usesXDays: Bool {
        guard let value = self._value else { return false }
        return _xDaysIntervals.contains(value)
    }
}
