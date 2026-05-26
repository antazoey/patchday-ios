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

    func testTappingEmptyHormone_goesToDetail() throws {
        app.buttons["HormoneCell_0"].tap()
        XCTAssert(app.staticTexts["Edit Hormone"].waitForExistence(timeout: 3))
    }
}
