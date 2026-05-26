//
//  HormoneDetailUITest.swift
//  PatchDayUITests
//

import XCTest

class HormoneDetailUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Default hormone 0 is empty (no site, default date) — tapping
        // navigates straight to the detail view without a confirmation dialog.
        app.buttons["HormoneCell_0"].tap()
        XCTAssert(app.staticTexts["Edit Hormone"].waitForExistence(timeout: 3))
    }

    func testTitle() throws {
        XCTAssert(app.staticTexts["Edit Hormone"].exists)
    }
}
