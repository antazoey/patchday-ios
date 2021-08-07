//
//  HormoneValueTypeTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/13/20.

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class TestHormoneSelectionState: PDTestCase {
    func testHasSelections_whenDateIsDefault_returnsFalse() {
        var selections = HormoneSelectionState()
        selections.date = DateFactory.createDefaultDate()
        XCTAssertFalse(selections.hasSelections)
    }

    func testHasSelections_whenDateSelected_returnsTrue() {
        var selections = HormoneSelectionState()
        selections.date = Date()
        XCTAssert(selections.hasSelections)
    }

    func testHasSelections_whenSiteSelectedButHasOrderOfNegativeOne_returnsFalse() {
        var selections = HormoneSelectionState()
        let site = MockSite()
        site.order = -1
        selections.site = site
        XCTAssertFalse(selections.hasSelections)
    }

    func testHasSelections_whenSiteSelectedWithValidOrder_returnsTrue() {
        var selections = HormoneSelectionState()
        let site = MockSite()
        site.order = 0
        selections.site = site
        XCTAssert(selections.hasSelections)
    }

    func testHasSelections_whenSiteNameSelected_returnsTrue() {
        var selections = HormoneSelectionState()
        selections.siteName = "Test"
        XCTAssert(selections.hasSelections)
    }
}
