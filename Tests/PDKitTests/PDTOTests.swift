//
//  PDTOTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 5/24/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit
import PDMock

class PillAttributesTests: XCTestCase {

    func testAnyAttributeExists_whenHasNoProps_returnsFalse() {
        let attributes = PillAttributes(
            name: nil,
            expirationInterval: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssertFalse(attributes.anyAttributeExists)
    }

    func testAnyAttributeExists_whenHasName_returnsTrue() {
        let attributes = PillAttributes(
            name: "TEST",
            expirationInterval: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists)
    }

    func testAnyAttributeExists_whenHasExpirationInterval_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationInterval: PillExpirationIntervalSetting.EveryDay,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists)
    }

    func testAnyAttributeExists_whenHasTimes_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationInterval: nil,
            times: "12:30",
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists)
    }

    func testAnyAttributeExists_whenHasNotify_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationInterval: nil,
            times: nil,
            notify: false,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists)
    }

    func testAnyAttributeExists_whenHasTimesTakenToday_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationInterval: nil,
            times: nil,
            notify: nil,
            timesTakenToday: 0,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists)
    }

    func testAnyAttributeExists_whenHasLastTaken_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationInterval: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: Date(),
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists)
    }

    func testAnyAttributeExists_whenHasXDays_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationInterval: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: "1"
        )
        XCTAssert(attributes.anyAttributeExists)
    }
}

class SiteImageDeterminationParametersTests: XCTestCase {

    func testInit_whenUsingHormoneWithImageId_setsImageIdToImageId() {
        let hormone = MockHormone()
        hormone.deliveryMethod = .Injections
        hormone.siteImageId = "IMAGE_ID"
        hormone.siteName = "SITE_NAME"
        hormone.hasSite = true
        let params = SiteImageDeterminationParameters(hormone: hormone)
        XCTAssertEqual("IMAGE_ID", params.imageId)
    }

    func testInit_whenUsingHormoneThatHasEmptyStringForImageId_setsImageIdToSiteName() {
        let hormone = MockHormone()
        hormone.deliveryMethod = .Injections
        hormone.siteImageId = ""
        hormone.siteName = "SITE_NAME"
        hormone.hasSite = true
        let params = SiteImageDeterminationParameters(hormone: hormone)
        XCTAssertEqual("SITE_NAME", params.imageId)
    }

    func testInit_whenUsingHormoneHasNoSite_setsSiteNameToNil() {
        let hormone = MockHormone()
        hormone.deliveryMethod = .Injections
        hormone.hasSite = false
        let params = SiteImageDeterminationParameters(hormone: hormone)
        XCTAssertNil(params.imageId)
    }

    func testInit_whenBothSiteNameAndIdAreEmptyString_setsImageIdToNewSite() {
        let hormone = MockHormone()
        hormone.deliveryMethod = .Injections
        hormone.siteImageId = ""
        hormone.siteName = ""
        hormone.hasSite = true
        let params = SiteImageDeterminationParameters(hormone: hormone)
        XCTAssertEqual(SiteStrings.NewSite, params.imageId)
    }

    func testInit_whenGivenNil_setsToExpectedProperties() {
        let params = SiteImageDeterminationParameters(hormone: nil)
        XCTAssertNil(params.imageId)
        XCTAssertEqual(DefaultSettings.DeliveryMethodValue, params.deliveryMethod)
    }
}
