//
//  ScreenshotTests.swift
//  PatchDayUITests
//
//  Drives the app through a known demo state (via `--demo-state`) and parks on
//  each App Store / TestFlight screen in turn, logging a "SHOT <name>" marker
//  before a short sleep. scripts/generate-screenshots.sh polls those markers
//  and grabs the screen with `xcrun simctl io screenshot`.
//
//  Why park + simctl instead of XCTAttachment extraction: `xcresulttool`
//  attachment extraction broke under current Xcode (empty test graph), so the
//  old "attach screenshots, dig them out of the .xcresult" flow produced zero
//  files. Capturing the live simulator screen is reliable across Xcode updates.
//

import XCTest

final class ScreenshotTests: XCTestCase {

    private var app: XCUIApplication!

    /// Seconds the app parks on each screen — long enough for the orchestrator
    /// to see the marker and take the screenshot.
    private let parkSeconds: TimeInterval = 8

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--nuke-storage", "--demo-state"]
        app.launch()

        // Skip the first-launch SetupSheet so screenshots aren't of it.
        let skip = app.buttons["setupSheetSkipButton"]
        if skip.waitForExistence(timeout: 5) {
            skip.tap()
        }
    }

    func testCaptureMarketingScreens() {
        // 01 — Hormones (default tab on launch).
        XCTAssert(app.buttons["HormoneCell_0"].waitForExistence(timeout: 10))
        park("01-Hormones")

        // 02 — Pills.
        tapTab("Pills")
        XCTAssert(app.buttons["PillCell_0"].waitForExistence(timeout: 8))
        park("02-Pills")

        // 03 — Sites.
        tapTab("Sites")
        XCTAssert(app.buttons["SiteCell_0"].waitForExistence(timeout: 8))
        park("03-Sites")

        // 04 — Settings.
        tapTab("Settings")
        XCTAssert(app.buttons["themePicker"].waitForExistence(timeout: 8))
        park("04-Settings")

        // 05 — Hormone quick-action alert.
        tapHormonesTab()
        let cell = app.buttons["HormoneCell_1"]
        XCTAssert(cell.waitForExistence(timeout: 8))
        cell.tap()
        XCTAssert(app.buttons["Edit"].waitForExistence(timeout: 3))
        park("05-HormoneActions")

        // 06 — Hormone detail.
        app.buttons["Edit"].tap()
        XCTAssert(app.staticTexts["Edit Hormone"].waitForExistence(timeout: 3))
        park("06-HormoneDetail")
    }

    // MARK: - Helpers

    private func park(_ name: String) {
        NSLog("SHOT \(name)")
        Thread.sleep(forTimeInterval: parkSeconds)
    }

    /// The Hormones tab's label tracks the delivery method (Patches / Injections
    /// / Gel); the demo state uses Patches.
    private func tapHormonesTab() {
        for label in ["Patches", "Injections", "Gel"] {
            let button = app.tabBars.buttons[label].firstMatch
            if button.exists {
                button.tap()
                return
            }
        }
    }

    /// iPhone surfaces tab buttons under `app.tabBars`. iPad's floating tab bar
    /// exposes each entry as both an outer button + an inner cell, so a plain
    /// match throws "multiple matching elements." Use the first match in either.
    private func tapTab(_ label: String) {
        let inTabBar = app.tabBars.buttons[label].firstMatch
        if inTabBar.waitForExistence(timeout: 1) {
            inTabBar.tap()
            return
        }
        app.buttons.matching(identifier: label).firstMatch.tap()
    }
}
