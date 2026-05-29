//
//  PillDetailUITest.swift
//  PatchDayUITests
//

import XCTest

class PillDetailUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Use the Add button — tapping a pill row could land on the inner Take
        // button. Add reliably navigates to the detail screen.
        tabs.buttons["Pills"].tap()
        XCTAssert(app.cells["GhostPillCell"].waitForExistence(timeout: 3))
        app.cells["GhostPillCell"].tap()
        XCTAssert(app.staticTexts["Schedule"].waitForExistence(timeout: 3))
    }

    func testSchedule_appears() throws {
        XCTAssert(app.staticTexts["Schedule"].exists)
    }

    func testSelectName_viaPreset_updatesField() throws {
        app.buttons["pillNamePresetPicker"].tap()
        let prolactin = app.buttons["Prolactin"]
        XCTAssert(prolactin.waitForExistence(timeout: 3))
        prolactin.tap()
        let nameField = app.textFields["pillNameTextField"]
        XCTAssertEqual("Prolactin", nameField.value as? String)
    }

    func testSelectSchedule_everyOtherDay() throws {
        app.buttons["pillScheduleButton"].tap()
        let option = app.buttons["Every Other Day"]
        XCTAssert(option.waitForExistence(timeout: 3))
        option.tap()
        XCTAssert(app.staticTexts["Every Other Day"].waitForExistence(timeout: 2))
    }

    func testSelectSchedule_whenFirstXDays_showsDaysOneStepper() throws {
        app.buttons["pillScheduleButton"].tap()
        let option = app.buttons["First X Days of Month"]
        XCTAssert(option.waitForExistence(timeout: 3))
        option.tap()
        XCTAssert(app.steppers["pillDaysOneScheduleButton"].waitForExistence(timeout: 2))
    }

    func testSelectSchedule_whenXDaysOnXDaysOff_showsBothSteppers() throws {
        app.buttons["pillScheduleButton"].tap()
        let option = app.buttons["X Days On, X Days Off"]
        XCTAssert(option.waitForExistence(timeout: 3))
        option.tap()
        XCTAssert(app.steppers["pillDaysOneScheduleButton"].waitForExistence(timeout: 2))
        XCTAssert(app.steppers["pillDaysTwoScheduleButton"].exists)
    }
}
