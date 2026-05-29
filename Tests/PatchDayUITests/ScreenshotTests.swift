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
        // Hormones tab (default on launch).
        XCTAssert(app.staticTexts["Patches"].waitForExistence(timeout: 5))
        attachScreenshot(named: "01-Hormones")

        // Pills tab.
        app.tabBars.buttons["Pills"].tap()
        XCTAssert(app.staticTexts["Pills"].waitForExistence(timeout: 3))
        attachScreenshot(named: "02-Pills")

        // Sites tab.
        app.tabBars.buttons["Sites"].tap()
        XCTAssert(app.staticTexts["Sites"].waitForExistence(timeout: 3))
        attachScreenshot(named: "03-Sites")

        // Settings tab → scroll to top of the Settings form (the iCloud
        // section sits below the schedule controls; a single screenshot
        // captures the top half of Settings).
        app.tabBars.buttons["Settings"].tap()
        XCTAssert(app.staticTexts["Settings"].waitForExistence(timeout: 3))
        attachScreenshot(named: "04-Settings")
    }

    func testCaptureHormoneDetail() {
        XCTAssert(app.staticTexts["Patches"].waitForExistence(timeout: 5))
        // Tap the second patch (the older one, near-expired) to surface
        // the action dialog AND get into the detail screen.
        let cell = app.buttons["HormoneCell_1"]
        XCTAssert(cell.waitForExistence(timeout: 3))
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
