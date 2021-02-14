//
//  SiteImagesTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/28/20.

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class SiteImagesTests: XCTestCase {

    func testSubsript_forUnsitedPatch() {
        let hormone = MockHormone()
        hormone.hasSite = false
        hormone.deliveryMethod = .Patches
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.placeholderPatch
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forPatchesRightGlute() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Patches
        hormone.siteImageId = SiteStrings.RightGlute
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.patchRightGlute
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forPatchesLeftGlute() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Patches
        hormone.siteImageId = SiteStrings.LeftGlute
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.patchLeftGlute
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forPatchesLeftAbdomen() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Patches
        hormone.siteImageId = SiteStrings.LeftAbdomen
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.patchLeftAbdomen
        XCTAssertEqual(expected, actual)
    }
    func testSubscript_forPatchesRightAbdomen() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Patches
        hormone.siteImageId = SiteStrings.RightAbdomen
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.patchRightAbdomen
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forCustomPatch() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Patches
        hormone.siteImageId = "custom"
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.customPatch
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forUnsitedInjection() {
        let hormone = MockHormone()
        hormone.hasSite = false
        hormone.deliveryMethod = .Injections
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.placeholderInjection
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forInjectionsLeftQuad() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Injections
        hormone.siteImageId = SiteStrings.LeftQuad
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.injectionLeftQuad
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forInjectionsRightQuad() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Injections
        hormone.siteImageId = SiteStrings.RightQuad
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.injectionRightQuad
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forInjectionsLeftDelt() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Injections
        hormone.siteImageId = SiteStrings.LeftDelt
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.injectionLeftDelt
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forInjectionsRightDelt() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Injections
        hormone.siteImageId = SiteStrings.RightDelt
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.injectionRightDelt
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forInjectionsLeftGlute() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Injections
        hormone.siteImageId = SiteStrings.LeftGlute
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.injectionLeftGlute
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forInjectionsRightGlute() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Injections
        hormone.siteImageId = SiteStrings.RightGlute
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.injectionRightGlute
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forCustomInjection() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Injections
        hormone.siteImageId = "Custom"
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.customInjection
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forUnsitedGel() {
        let hormone = MockHormone()
        hormone.hasSite = false
        hormone.deliveryMethod = .Gel
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.placeholderGel
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forGelArms() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Gel
        hormone.siteImageId = SiteStrings.Arms
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.arms
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_forCustomGel() {
        let hormone = MockHormone()
        hormone.hasSite = true
        hormone.deliveryMethod = .Gel
        hormone.siteImageId = "Custom"
        let params = SiteImageDeterminationParameters(hormone: hormone)
        let actual = SiteImages[params]
        let expected = SiteImages.customGel
        XCTAssertEqual(expected, actual)
    }
}
