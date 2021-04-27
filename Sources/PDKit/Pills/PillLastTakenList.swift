//
//  PillLastTakenList.swift
//  PDKit
//
//  Created by Juliya Smith on 4/25/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class PillLastTakenList {
    private var _dateString: String?
    private var _dates: [Date]

    public var dateString: String {
        _dateString ?? ""
    }

    public var dates: [Date] {
        _dates
    }

    public init(dateString: String?) {
        self._dateString = dateString
        if let dateString = dateString {
            self._dates = DateFactory.createDatesFromCommaSeparatedString(dateString)
        } else {
            self._dates = []
        }
    }

    public var count: Int {
        _dates.count
    }

    /// Pop the last date off the list
    @discardableResult
    public func popLast() -> Date? {
        let last = _dates.popLast()
        let newString = PDDateFormatter.convertDatesToCommaSeparatedString(_dates)
        self._dateString = newString
        return last
    }

    /// Append a date to the list and get the resulting date string.
    @discardableResult
    public func combineWith(lastTaken: Date?) -> String? {
        guard dates.count < MaxPillTimesaday else { return nil }
        guard let lastTaken = lastTaken else { return nil }
        let formattedDate = ISO8601DateFormatter().string(from: lastTaken)
        let original = _dateString ?? ""
        var builder = original
        if original.isEmpty {
            builder += formattedDate
        } else {
            builder += ",\(formattedDate)"
        }
        self._dateString = builder
        self._dates = DateFactory.createDatesFromCommaSeparatedString(builder)
        return builder
    }
}
