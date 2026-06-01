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
        // The ghost row now opens an action sheet; "New Location" creates a
        // brand-new site and navigates to its detail screen. confirmationDialog
        // buttons surface twice in the a11y tree, so take the first match.
        let newLocation = app.buttons["newSiteAction"].firstMatch
        XCTAssert(newLocation.waitForExistence(timeout: 3))
        newLocation.tap()
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

    func testTypingKnownSiteName_autoSelectsMatchingImage() throws {
        // Typing a known site name auto-selects its image. Right Glute is the
        // first patch image (index 0); a new site starts on the custom image, so
        // the selection must move to 0.
        let nameField = app.textFields["siteNameTextField"]
        nameField.tap()
        nameField.typeText("Right Glute")
        XCTAssertTrue(app.buttons["siteImageButton_0"].firstMatch.isSelected)
    }
}
