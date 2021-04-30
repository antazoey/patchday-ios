//
//  PillTimesTakenTodayList.swift
//  PDKit
//
//  Created by Juliya Smith on 4/25/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class PillTimesTakenTodayList {
    private var _timeString: String?
    private var _times: [Time]

    public var asString: String {
        _timeString ?? ""
    }

    public var asList: [Time] {
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

    public subscript(_ index: Index) -> Time {
        _times[index]
    }

    /// Remove the last time from the list and optionally return the new last.
    @discardableResult
    public func undoLast() -> Time? {
        guard count > 0 else { return nil }
        _times.removeLast()
        let newString = PDDateFormatter.convertTimesToCommaSeparatedString(_times)
        self._timeString = newString
        return asList.tryGet(at: count - 1)
    }

    /// Append a date to the list and get the resulting date string.
    @discardableResult
    public func combineWith(_ lastTakenTime: Time?) -> String? {
        guard count < MaxPillTimesaday else { return nil }
        guard let lastTaken = lastTakenTime else { return nil }
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
