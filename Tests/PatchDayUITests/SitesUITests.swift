//
//  SitesUITests.swift
//  PatchDayUITests
//

import XCTest

class SitesUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        tabs.buttons["Sites"].tap()
        XCTAssert(cellAt(0).waitForExistence(timeout: 3))
    }

    func cellAt(_ index: Int) -> XCUIElement {
        app.buttons["SiteCell_\(index)"]
    }

    func siteCellCount() -> Int {
        var count = 0
        while cellAt(count).exists { count += 1 }
        return count
    }

    func swipeDelete(at index: Int) {
        cellAt(index).swipeLeft()
        let deleteButton = app.buttons["Delete"]
        if deleteButton.waitForExistence(timeout: 2) {
            deleteButton.tap()
        }
        _ = app.wait(for: .unknown, timeout: 1)
    }

    func testTitle_isSites() throws {
        XCTAssert(app.navigationBars["Sites"].exists)
    }

    func testCellCount_whenPatches() throws {
        XCTAssertEqual(4, siteCellCount())
    }

    func testInsertNewSiteButton_navigatesToDetail() throws {
        let before = siteCellCount()
        app.cells["GhostSiteCell"].tap()
        XCTAssert(app.staticTexts["Image:"].waitForExistence(timeout: 3))
        // Going back without saving should leave the count unchanged on the legacy
        // SwiftUI navigation back gesture; instead we expect the new placeholder
        // site was inserted by Add (the SwiftUI Add flow inserts immediately).
        // So count increased by 1 once we return.
        app.buttons["siteSaveButton"].tap()
        XCTAssert(cellAt(0).waitForExistence(timeout: 3))
        XCTAssertEqual(before + 1, siteCellCount())
    }

    func testDeleteCellFromSwipe_deletesCell() throws {
        let before = siteCellCount()
        swipeDelete(at: 1)
        XCTAssertEqual(before - 1, siteCellCount())
    }

    func testReset_afterDelete_restoresDefaultSites() throws {
        swipeDelete(at: 0)
        app.buttons["editSitesButton"].tap()
        XCTAssert(app.buttons["resetSitesButton"].waitForExistence(timeout: 2))
        app.buttons["resetSitesButton"].tap()
        _ = app.wait(for: .unknown, timeout: 1)
        XCTAssertEqual(4, siteCellCount())
    }
}
