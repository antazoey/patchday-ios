//
//  HormonesUITest.swift
//  PatchDayUITests
//

import XCTest

class HormonesUITests: PDUITest {

    func testTitle() throws {
        XCTAssert(app.staticTexts["Patches"].exists)
    }

    func testHormoneCellsExist_forDefaultPatchesQuantity() throws {
        // Default Patches quantity is 3 — cells 0..<3 should render.
        XCTAssert(app.buttons["HormoneCell_0"].waitForExistence(timeout: 3))
        XCTAssert(app.buttons["HormoneCell_1"].exists)
        XCTAssert(app.buttons["HormoneCell_2"].exists)
    }

    func testChangeAllButton_hiddenWhenNotMultipleDue() throws {
        // A fresh schedule has no expired patches, so "Change all" must not show.
        XCTAssert(app.buttons["HormoneCell_0"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["changeAllButton"].exists)
    }

    func testTappingEmptyHormone_showsActionDialog() throws {
        // Empty hormones now open an action sheet (Change / Edit / Remove)
        // instead of jumping straight to detail. Tapping Edit in that
        // dialog still gets you to the detail screen.
        app.buttons["HormoneCell_0"].tap()
        let edit = app.buttons["Edit"]
        XCTAssert(edit.waitForExistence(timeout: 3))
        edit.tap()
        XCTAssert(app.staticTexts["Edit Hormone"].waitForExistence(timeout: 3))
    }
}
