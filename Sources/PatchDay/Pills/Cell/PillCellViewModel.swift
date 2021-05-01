//
//  PillCellViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/9/20.

import Foundation

import UIKit
import PDKit

class PillCellViewModel: PillCellViewModelProtocol {

    private let pill: Swallowable

    init(pill: Swallowable) {
        self.pill = pill
    }

    var timesQuotientText: String {
        let quotient = PillTimesQuotient(
            timesTakenToday: pill.timesTakenToday, timesaday: pill.timesaday
        )
        return quotient.toString()
    }

    var lastTakenText: String {
        if let lastTaken = pill.lastTaken, !lastTaken.isDefault() {
            return PDDateFormatter.formatDate(lastTaken)
        } else {
            return PlaceholderStrings.Hyphen
        }
    }

    var dueDateText: String {
        if let dueDate = pill.due {
            return PDDateFormatter.formatDate(dueDate)
        } else {
            return NSLocalizedString("Take to start", comment: "")
        }
    }
}
