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
