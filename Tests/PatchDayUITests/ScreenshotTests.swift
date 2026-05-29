//
//  ScreenshotTests.swift
//  PatchDayUITests
//
//  Drives the app through a known demo state (via `--demo-state`) and
//  captures App Store / TestFlight-ready screenshots. Pair with the
//  scripts/generate-screenshots.sh orchestrator which boots simulators,
//  toggles appearance, and extracts the PNGs from the xcresult bundle.
//

import XCTest

final class ScreenshotTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--nuke-storage", "--demo-state"]
        app.launch()

        // Skip the first-launch SetupSheet so screenshots aren't of it
        // unless we explicitly capture it (see testSetupSheet below).
        let skip = app.buttons["setupSheetSkipButton"]
        if skip.waitForExistence(timeout: 5) {
            skip.tap()
        }
    }

    // MARK: - Capture flow

    func testCaptureMainTabs() {
        // Hormones tab is default. Don't gate on a specific title since
        // iPad layouts vary — wait for the first patch cell instead.
        XCTAssert(app.buttons["HormoneCell_0"].waitForExistence(timeout: 8))
        attachScreenshot(named: "01-Hormones")

        tapTab("Pills")
        XCTAssert(app.buttons["PillCell_0"].waitForExistence(timeout: 5))
        attachScreenshot(named: "02-Pills")

        tapTab("Sites")
        XCTAssert(app.buttons["SiteCell_0"].waitForExistence(timeout: 5))
        attachScreenshot(named: "03-Sites")

        tapTab("Settings")
        XCTAssert(app.buttons["deliveryMethodButton"].waitForExistence(timeout: 5))
        attachScreenshot(named: "04-Settings")
    }

    /// iPhone surfaces tab buttons under `app.tabBars`. iPad's floating
    /// tab bar exposes each entry as both an outer button + an inner cell,
    /// so a plain match throws "multiple matching elements." Use the
    /// first match in either spot.
    private func tapTab(_ label: String) {
        let inTabBar = app.tabBars.buttons[label].firstMatch
        if inTabBar.waitForExistence(timeout: 1) {
            inTabBar.tap()
            return
        }
        app.buttons.matching(identifier: label).firstMatch.tap()
    }

    func testCaptureHormoneDetail() {
        // Don't gate on the "Patches" title — on iPad split-view the title
        // can be in a sidebar. Wait directly for the cell we plan to tap.
        let cell = app.buttons["HormoneCell_1"]
        XCTAssert(cell.waitForExistence(timeout: 8))
        cell.tap()

        // Confirmation dialog appears with Change / Edit / Remove / Cancel.
        let editButton = app.buttons["Edit"]
        XCTAssert(editButton.waitForExistence(timeout: 2))
        // Capture the dialog itself first.
        attachScreenshot(named: "05-HormoneActions")
        // Then drill into detail.
        editButton.tap()
        XCTAssert(app.staticTexts["Edit Hormone"].waitForExistence(timeout: 3))
        attachScreenshot(named: "06-HormoneDetail")
    }

    // MARK: - Helpers

    private func attachScreenshot(named name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.lifetime = .keepAlways
        attachment.name = name
        add(attachment)
    }
}
