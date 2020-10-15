//
//  PillCellViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

import UIKit
import PDKit

class PillCellViewModel {

    private let pill: Swallowable

    init(pill: Swallowable) {
        self.pill = pill
    }

    var lastTakenText: String {
        if let lastTaken = self.pill.lastTaken {
            return PDDateFormatter.formatDate(lastTaken)
        } else {
            return PillStrings.NotYetTaken
        }
    }

    var dueDateText: String {
        if let dueDate = pill.due {
            return PDDateFormatter.formatDate(dueDate)
        } else {
            return NSLocalizedString("Take pill to start schedule.", comment: "")
        }
    }
}
