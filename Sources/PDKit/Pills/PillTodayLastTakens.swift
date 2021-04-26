//
//  PillTodayLastTakens.swift
//  PDKit
//
//  Created by Juliya Smith on 4/25/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class PillTodayLastTakens {
    private let dateString: String?

    public init(dateString: String?) {
        self.dateString = dateString
    }

    public var dates: [Date] {
        guard let lastTakensString = dateString else { return [] }
        return DateFactory.createDatesFromSeparatedString(lastTakensString)
    }

    public func splitLast() -> (Date?, String?) {
        var current = dates
        let last = current.popLast()
        let newString = PDDateFormatter.convertDatesToCommaSeparatedString(current)
        return (last, newString)
    }

    public func combineWith(lastTaken: Date?) -> String? {
        guard dates.count < MaxPillTimesaday else { return nil }
        guard let lastTaken = lastTaken else { return nil }
        let formattedDate = PDDateFormatter.formatDate(lastTaken)
        guard let original = dateString else { return formattedDate }
        return "\(original)_\(formattedDate)"
    }
}
