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
	func testInit_whenUsingHormone_setsExpectedProperties() {
		let hormone = MockHormone()
		hormone.deliveryMethod = .Injections
		hormone.siteName = "Test"
		hormone.hasSite = true
		let params = SiteImageDeterminationParameters(hormone: hormone)
		XCTAssertEqual(.Injections, params.deliveryMethod)
		XCTAssertEqual("Test", params.siteName)
	}

	func testInit_whenUsingHormoneHasNoSite_setsSiteNameToNil() {
		let hormone = MockHormone()
		hormone.deliveryMethod = .Injections
		hormone.hasSite = false
		let params = SiteImageDeterminationParameters(hormone: hormone)
		XCTAssertNil(params.siteName)
	}

	func testInit_whenGivenNil_setsToExpectedProperties() {
		let params = SiteImageDeterminationParameters(hormone: nil)
		XCTAssertNil(params.siteName)
		XCTAssertEqual(DefaultSettings.DeliveryMethodValue, params.deliveryMethod)
	}
}
