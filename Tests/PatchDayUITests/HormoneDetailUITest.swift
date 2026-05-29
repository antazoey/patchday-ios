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

    func testSelectSite_viaDialog_updatesSelection() throws {
        app.buttons["hormoneSiteSelectorStack"].tap()
        let select = app.buttons["Select"]
        XCTAssert(select.waitForExistence(timeout: 3))
        select.tap()
        let option = app.buttons["Left Glute"]
        XCTAssert(option.waitForExistence(timeout: 3))
        option.tap()
        XCTAssert(app.staticTexts["Left Glute"].waitForExistence(timeout: 2))
    }

    func testTypeSiteOption_revealsTypedSiteTextField() throws {
        app.buttons["hormoneSiteSelectorStack"].tap()
        let type = app.buttons["Type"]
        XCTAssert(type.waitForExistence(timeout: 3))
        type.tap()
        XCTAssert(app.textFields["selectHormoneSiteTextField"].waitForExistence(timeout: 2))
    }
}
