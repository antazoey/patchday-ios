//
//  SettingsUITest.swift
//  PatchDayUITests
//

import XCTest

class SettingsUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        app.buttons["settingsGearButton"].tap()
        XCTAssert(app.navigationBars["Settings"].waitForExistence(timeout: 3))
    }

    func testTitle() throws {
        XCTAssert(app.navigationBars["Settings"].exists)
    }

    func testSetQuantity_updatesPickerValue() throws {
        app.buttons["settingsQuantityButton"].tap()
        let four = app.buttons["4"]
        XCTAssert(four.waitForExistence(timeout: 3))
        four.tap()
        XCTAssert(app.staticTexts["4"].waitForExistence(timeout: 2))
    }

    func testSetDeliveryMethod_updatesPickerValue() throws {
        app.buttons["deliveryMethodButton"].tap()
        let injections = app.buttons["Injections"]
        XCTAssert(injections.waitForExistence(timeout: 3))
        injections.tap()
        // A destructive-change confirmation appears.
        let continueBtn = app.alerts.buttons["Continue"]
        if continueBtn.waitForExistence(timeout: 2) {
            continueBtn.tap()
        }
        // The Hormones tab title now reflects the new delivery method.
        tabs.buttons["Injections"].tap()
        XCTAssert(app.staticTexts["Injections"].waitForExistence(timeout: 2))
    }

    func testNotificationsSlider_exists() throws {
        XCTAssert(app.sliders["notificationsMinutesBeforeSlider"].waitForExistence(timeout: 2))
    }

    func testTutorial_opensAndPagesToDone() throws {
        app.buttons["tutorialButton"].tap()
        XCTAssert(app.navigationBars["Tutorial"].waitForExistence(timeout: 3))
        let next = app.buttons["tutorialNextButton"]
        XCTAssert(next.waitForExistence(timeout: 3))
        // Page through all steps; on the last page the button dismisses.
        for _ in 0..<5 { next.tap() }
        next.tap()
        XCTAssertFalse(app.navigationBars["Tutorial"].waitForExistence(timeout: 2))
    }
}
