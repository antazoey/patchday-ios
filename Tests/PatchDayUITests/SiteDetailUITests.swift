//
//  SiteDetailUITests.swift
//  PatchDayUITests
//

import XCTest

class SiteDetailUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        tabs.buttons["Sites"].tap()
        XCTAssert(app.buttons["insertNewSiteButton"].waitForExistence(timeout: 3))
        app.buttons["insertNewSiteButton"].tap()
        XCTAssert(app.staticTexts["Image:"].waitForExistence(timeout: 3))
    }

    func testTitle_isNewSite() throws {
        XCTAssert(app.navigationBars["New Site"].exists)
    }

    func testImagePicker_isPresent() throws {
        XCTAssert(app.buttons["siteImageButton_0"].exists)
        XCTAssert(app.buttons["siteImageButton_1"].exists)
    }

    func testSaveButton_exists() throws {
        XCTAssert(app.buttons["siteSaveButton"].exists)
    }
}
