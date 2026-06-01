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

    func testNewLocation_navigatesToDetail() throws {
        let before = siteCellCount()
        app.buttons["GhostSiteCell"].tap()
        // confirmationDialog buttons surface twice in the a11y tree, so match
        // the first by identifier.
        let newLocation = app.buttons["newSiteAction"].firstMatch
        XCTAssert(newLocation.waitForExistence(timeout: 3))
        newLocation.tap()
        XCTAssert(app.staticTexts["Image:"].waitForExistence(timeout: 3))
        // The SwiftUI Add flow inserts the placeholder site immediately, so the
        // count increases by 1 once we save and return.
        app.buttons["siteSaveButton"].tap()
        XCTAssert(cellAt(0).waitForExistence(timeout: 3))
        XCTAssertEqual(before + 1, siteCellCount())
    }

    func testAddExisting_clonesAnExistingLocation_increasingCount() throws {
        let before = siteCellCount()
        app.buttons["GhostSiteCell"].tap()
        app.buttons["addExistingSiteAction"].firstMatch.tap()
        // Pick the first default location (Right Glute for Patches).
        let choice = app.buttons["existingLocation_Right Glute"].firstMatch
        XCTAssert(choice.waitForExistence(timeout: 3))
        choice.tap()
        XCTAssert(cellAt(before).waitForExistence(timeout: 3))
        XCTAssertEqual(before + 1, siteCellCount())
    }

    func testTapSite_duplicateAction_clonesSite() throws {
        let before = siteCellCount()
        cellAt(0).tap()
        let duplicate = app.buttons["duplicateSiteAction"].firstMatch
        XCTAssert(duplicate.waitForExistence(timeout: 3))
        duplicate.tap()
        XCTAssert(cellAt(before).waitForExistence(timeout: 3))
        XCTAssertEqual(before + 1, siteCellCount())
    }

    func testTapSite_editAction_navigatesToDetail() throws {
        cellAt(0).tap()
        let edit = app.buttons["editSiteAction"].firstMatch
        XCTAssert(edit.waitForExistence(timeout: 3))
        edit.tap()
        XCTAssert(app.staticTexts["Image:"].waitForExistence(timeout: 3))
    }

    func testDeleteCellFromSwipe_deletesCell() throws {
        let before = siteCellCount()
        swipeDelete(at: 1)
        XCTAssertEqual(before - 1, siteCellCount())
    }

    func testPresetsDefault_afterDelete_restoresDefaultSites() throws {
        swipeDelete(at: 0)
        app.buttons["editSitesButton"].tap()
        let presets = app.buttons["sitePresetsButton"]
        XCTAssert(presets.waitForExistence(timeout: 2))
        presets.tap()
        let defaultScheme = app.buttons["siteScheme_Default"].firstMatch
        XCTAssert(defaultScheme.waitForExistence(timeout: 3))
        defaultScheme.tap()
        XCTAssert(cellAt(0).waitForExistence(timeout: 3))
        XCTAssertEqual(4, siteCellCount())
    }

    func testPresets_abdomenRotation_appliesSixSlots() throws {
        app.buttons["editSitesButton"].tap()
        app.buttons["sitePresetsButton"].tap()
        let scheme = app.buttons["siteScheme_Abdomen (L×3 → R×3)"].firstMatch
        XCTAssert(scheme.waitForExistence(timeout: 3))
        scheme.tap()
        XCTAssert(cellAt(5).waitForExistence(timeout: 3))
        XCTAssertEqual(6, siteCellCount())
    }

    /// Applies a same-name rotation, leaves edit mode, and confirms the run
    /// collapses to one row that expands to its individual slots.
    private func applyAbdomenRotationThenCollapse() {
        app.buttons["editSitesButton"].tap()
        app.buttons["sitePresetsButton"].tap()
        app.buttons["siteScheme_Abdomen (L×3 → R×3)"].firstMatch.tap()
        app.buttons["editSitesButton"].tap() // "Done" → back to collapsed (non-edit) view
    }

    func testSameNameRun_collapsesAndExpands() throws {
        applyAbdomenRotationThenCollapse()
        let group = app.buttons["siteGroup_0"]
        XCTAssert(group.waitForExistence(timeout: 3))
        // Members are hidden until the group is expanded.
        XCTAssertFalse(app.buttons["SiteCell_1"].exists)
        group.tap()
        XCTAssert(app.buttons["SiteCell_1"].waitForExistence(timeout: 3))
        XCTAssert(app.buttons["SiteCell_2"].exists)
    }

    func testExpandedSlot_swipeDeletesIndividualSlot() throws {
        applyAbdomenRotationThenCollapse()
        app.buttons["siteGroup_0"].tap() // expand Left Abdomen ×3
        XCTAssert(app.buttons["SiteCell_2"].waitForExistence(timeout: 3))
        app.buttons["SiteCell_1"].swipeLeft()
        let del = app.buttons["Delete"].firstMatch
        XCTAssert(del.waitForExistence(timeout: 2))
        del.tap()
        // The run is now ×2, so the third slot drops out of the expanded list.
        XCTAssertFalse(app.buttons["SiteCell_2"].waitForExistence(timeout: 2))
    }
}
