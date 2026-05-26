//
//  HormoneDetailUITest.swift
//  PatchDayUITests
//

import XCTest

class HormoneDetailUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Default hormone 0 is empty — tapping goes straight to detail.
        app.buttons["HormoneCell_0"].tap()
        XCTAssert(app.staticTexts["Edit Hormone"].waitForExistence(timeout: 3))
    }

    func testTitle() throws {
        XCTAssert(app.staticTexts["Edit Hormone"].exists)
    }

    func testSelectSite_viaPicker_updatesSelection() throws {
        app.buttons["hormoneSiteSelectorStack"].tap()
        let option = app.buttons["Left Glute"]
        XCTAssert(option.waitForExistence(timeout: 3))
        option.tap()
        XCTAssert(app.staticTexts["Left Glute"].waitForExistence(timeout: 2))
    }

    func testTypeSiteButton_revealsTypedSiteTextField() throws {
        app.buttons["typeSiteButton"].tap()
        XCTAssert(app.textFields["selectHormoneSiteTextField"].waitForExistence(timeout: 2))
    }
}
