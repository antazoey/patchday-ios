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

        // Dismiss the SwiftUI disclaimer alert that always appears on first launch
        // after --nuke-storage. The interruption monitor handles cases where the
        // alert is presented after the app starts.
        addUIInterruptionMonitor(withDescription: "Disclaimer") { alert in
            let dismiss = alert.buttons["Dismiss"]
            if dismiss.exists {
                dismiss.tap()
                return true
            }
            return false
        }

        // Tap the app to trigger the interruption monitor in case the alert is up.
        app.activate()
        let dismiss = app.alerts.buttons["Dismiss"]
        if dismiss.waitForExistence(timeout: 3) {
            dismiss.tap()
        }

        tabs = app.tabBars

        XCTAssert(app.staticTexts["Patches"].waitForExistence(timeout: 5))
    }
}
