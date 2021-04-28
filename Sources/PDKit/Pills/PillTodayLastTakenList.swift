//
//  PillLastTakenList.swift
//  PDKit
//
//  Created by Juliya Smith on 4/25/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class PillTodayLastTakenList {
    private var _timeString: String?
    private var _times: [Date]

    public var timeString: String {
        _timeString ?? ""
    }

    public var times: [Date] {
        _times
    }

    public init(timeString: String?) {
        self._timeString = timeString
        if let timeString = timeString {
            self._times = DateFactory.createTimesFromCommaSeparatedString(timeString)
        } else {
            self._times = []
        }
    }

    public var count: Int {
        _times.count
    }

    /// Pop the last date off the list.
    @discardableResult
    public func popLast() -> Date? {
        let last = _times.popLast()
        let newString = PDDateFormatter.convertTimesToCommaSeparatedString(_times)
        self._timeString = newString
        return last
    }

    /// Append a date to the list and get the resulting date string.
    @discardableResult
    public func combineWith(lastTaken: Date?) -> String? {
        guard count < MaxPillTimesaday else { return nil }
        guard let lastTaken = lastTaken else { return nil }
        let newTimeString = combineTimes(lastTaken)
        setTimeString(newTimeString)
        return newTimeString
    }

    private func combineTimes(_ newTime: Time) -> String {
        let formattedTime = PDDateFormatter.formatInternalTime(newTime)
        let original = _timeString ?? ""
        var builder = original
        builder += original.isEmpty ? formattedTime :",\(formattedTime)"
        return builder
    }

    private func setTimeString(_ newTimeString: String) {
        self._timeString = newTimeString
        self._times = DateFactory.createTimesFromCommaSeparatedString(newTimeString)
    }
}
