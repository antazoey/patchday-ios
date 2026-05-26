//
//  PillDetailUITest.swift
//  PatchDayUITests
//

import XCTest

class PillDetailUITests: PDUITest {

    func testInsertNewPill_loadsDetailScreen() throws {
        // Reach the detail screen via the Add button rather than tapping a pill
        // row (the Take button inside the row absorbs the tap).
        tabs.buttons["Pills"].tap()
        XCTAssert(app.buttons["pillsAddButton"].waitForExistence(timeout: 3))
        app.buttons["pillsAddButton"].tap()
        // The detail screen shows the schedule section as a static text.
        XCTAssert(app.staticTexts["Schedule"].waitForExistence(timeout: 3))
    }
}
