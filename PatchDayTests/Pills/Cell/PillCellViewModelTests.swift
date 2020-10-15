//
//  PillCellViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 10/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class PillCellViewModelTests: XCTestCase {

    func testLastTakenText_whenPillHasLastTaken_returnsFormattedLastTakenText() {
        let pill = MockPill()
        let lastTaken = Date()
        pill.lastTaken = Date()
        let viewModel = PillCellViewModel(pill: pill)
        let expected = PDDateFormatter.formatDate(lastTaken)
        let actual = viewModel.lastTakenText
        XCTAssertEqual(expected, actual)
    }

    func testLastTakenText_whenPillDoesNotHaveLastTaken_returnsNotYetTakenString() {
        let pill = MockPill()
        pill.lastTaken = nil
        let viewModel = PillCellViewModel(pill: pill)
        let expected = PillStrings.NotYetTaken
        let actual = viewModel.lastTakenText
        XCTAssertEqual(expected, actual)
    }

    func testDueDateText_whenPillHasLastTaken_returnsFormattedLastTakenText() {
        let pill = MockPill()
        let due = Date()
        pill.due = Date()
        let viewModel = PillCellViewModel(pill: pill)
        let expected = PDDateFormatter.formatDate(due)
        let actual = viewModel.dueDateText
        XCTAssertEqual(expected, actual)
    }

    func testDueDateText_whenPillDoesNotHaveLastTaken_returnsNotYetTakenString() {
        let pill = MockPill()
        pill.due = nil
        let viewModel = PillCellViewModel(pill: pill)
        let expected = "Take pill to start schedule."
        let actual = viewModel.dueDateText
        XCTAssertEqual(expected, actual)
    }
}
