//
//  PDUITest.swift
//  PatchDayUITests
//
//  Base class for SwiftUI UI tests. Launches with --nuke-storage so each
//  test starts from a clean schedule, and dismisses the first-launch
//  disclaimer alert before tests start interacting.
//

import Foundation
import XCTest

class PDUITest: XCTestCase {

    var app: XCUIApplication!
    var tabs: XCUIElementQuery!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments.append("--nuke-storage")
        app.launch()

        // --nuke-storage also clears didShowICloudSetup, so the first-launch
        // SetupSheet appears before anything else. Skip it — that also marks
        // the legal disclaimer as acknowledged for this user, so no separate
        // alert dismiss is needed.
        let skipSetup = app.buttons["setupSheetSkipButton"]
        if skipSetup.waitForExistence(timeout: 5) {
            skipSetup.tap()
        }

        tabs = app.tabBars

        XCTAssert(app.staticTexts["Patches"].waitForExistence(timeout: 5))
    }
}
