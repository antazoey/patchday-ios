//
//  PillExpirationIntervalXDays.swift
//  PDKit
//
//  Created by Juliya Smith on 2/9/21.

import Foundation

public class PillExpirationIntervalXDays {

    private var _one: Int?
    private var _two: Int?

    public var position: Int?
    public var isOn: Bool?

    public init(_ xDays: String) {
        let daysList = xDays.split(separator: "-").map { String($0) }
        let daysResult = PillExpirationIntervalXDays.parseMultipleDays(daysList)
        let one = daysResult.0
        let two = daysResult.1
        self._one = one
        self._two = two

        if daysList.count > 3 {
            let posArg = String(daysList[3])
            let position = PillExpirationIntervalXDays.parseIntFromXDaysValue(posArg) ?? 1
            let onOrOff = daysList[2]
            let isOn = onOrOff == "on"
            guard let max = (isOn ? one : two) else { return }
            guard 1...max ~= position else { return }
            self.position = position
            self.isOn = isOn
            return
        }

        // Only apply when `two` is used, suc has `.XDaysOnXDaysOff`.
        self.isOn = nil
        self.position = nil
    }

    public var value: String? {
        guard let dayOne = _one else { return nil }
        var builder = "\(dayOne)"
        if let dayTwo = _two {
            builder += "-\(dayTwo)"
        }
        if let isOn = isOn, let pos = position {
            let prefix = isOn ? "on" : "off"
            builder += "-\(prefix)-\(pos)"
        }
        return builder
    }

    /// The integer version of the first days value in `xDays`; only applies to expiration intervals that use X days.
    public var one: Int? {
        get { _one }
        set {
            if let newValue = newValue {
                guard _daysRange ~= newValue else { return }
                _one = newValue
            } else {
                // setting to nil is allowed
                _one = newValue
            }
        }
    }

    /// The integer version of the second days value in `xDays`; only applies to `.XDaysOnXDaysOff`.
    public var two: Int? {
        get { _two }
        set {
            if let newValue = newValue {
                guard _daysRange ~= newValue else { return }
                _two = newValue
            } else {
                // setting to nil is allowed
                _two = newValue
            }
        }
    }

    /// The string value of the second days property; only applies to `.XDaysOnXDaysOff`.
    public var daysOff: String? {
        guard let days = two else { return nil }
        return String(days)
    }

    /// The string value of the first days property; only applies to expiration intervals that use X days.
    public var daysOn: String? {
        guard let days = one else { return nil }
        return String(days)
    }

    /// The supported range for any days value, 1-25.
    public static var daysRange: ClosedRange<Int> {
        1...SupportedPillExpirationIntervalDaysLimit
    }

    public func startPositioning() {
        isOn = true
        position = 1
    }

    public func incrementDayPosition() {
        guard let one = one else { return }
        guard let two = two else { return }
        guard let isOnValue = isOn else { return }
        guard let pos = position else { return }
        let nextPosition = (pos + 1) % (isOnValue ? one : two)
        position = nextPosition
        isOn = nextPosition < pos ? !isOnValue : isOn
    }

    private var _daysRange: ClosedRange<Int> {
        PillExpirationIntervalXDays.daysRange
    }

    private static func parseMultipleDays(_ daysList: [String]) -> (Int?, Int?) {
        var daysOne: Int?
        var daysTwo: Int?

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
            let daysList = value.split(separator: "-").map { String($0) }
            return parseMultipleDays(daysList).0
        } else if let days = Int(value), daysRange ~= days {
            return days
        }
        return nil
    }
}
