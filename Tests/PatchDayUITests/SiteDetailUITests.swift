//
//  SiteDetailUITests.swift
//  PatchDayUITests
//

import XCTest

class SiteDetailUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        tabs.buttons["Sites"].tap()
        XCTAssert(app.buttons["GhostSiteCell"].waitForExistence(timeout: 3))
        app.buttons["GhostSiteCell"].tap()
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

    func testSelectPreset_updatesName() throws {
        app.buttons["siteNamePresetPicker"].tap()
        let option = app.buttons["Right Glute"]
        XCTAssert(option.waitForExistence(timeout: 3))
        option.tap()
        let nameField = app.textFields["siteNameTextField"]
        XCTAssertEqual("Right Glute", nameField.value as? String)
    }
}
