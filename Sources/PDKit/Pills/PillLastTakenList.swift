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

    /// Extract the last date off the list and get a tuple of that date and the new date string.
    @discardableResult
    public func splitLast() -> (Date?, String?) {
        let last = _dates.popLast()
        let newString = PDDateFormatter.convertDatesToCommaSeparatedString(_dates)
        self._dateString = newString
        return (last, newString)
    }

    /// Append a date to the last takens list and comma-separated date string.
    @discardableResult
    public func combineWith(lastTaken: Date?) -> String? {
        guard dates.count < MaxPillTimesaday else { return nil }
        guard let lastTaken = lastTaken else { return nil }
        let formattedDate = ISO8601DateFormatter().string(from: lastTaken)
        guard let original = _dateString else { return formattedDate }
        let newDateString = "\(original),\(formattedDate)"
        self._dateString = newDateString
        self._dates = DateFactory.createDatesFromCommaSeparatedString(newDateString)
        return newDateString
    }
}
