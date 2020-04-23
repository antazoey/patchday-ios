//
// Created by Juliya Smith on 2/8/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit
import PDMock

class ColonStringsTests: XCTestCase {

	private let expiredDate = Date(timeIntervalSinceNow: -86000)
	private let healthyDate = Date(timeIntervalSinceNow: 86400)

	private let formatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "h:mm a"; return f }()

	private func createPatch(isExpired: Bool) -> MockHormone {
		let patch = createHormone(isExpired: isExpired)
		patch.deliveryMethod = .Patches
		return patch
	}

	private func createInjection(isExpired: Bool) -> MockHormone {
		let injection = createHormone(isExpired: isExpired)
		injection.deliveryMethod = .Injections
		return injection
	}

	private func createHormone(isExpired: Bool) -> MockHormone {
		let hormone = MockHormone()
		hormone.expiration = isExpired ? expiredDate : healthyDate
		hormone.date = Date()
		hormone.isExpired = isExpired
		return hormone
	}

	func testCreateHormoneViewStrings_whenGivenExpiredPatch_returnsExpectedStrings() {
		let patch = createPatch(isExpired: true)
        let actual = ColonStrings.createHormoneViewStrings(patch)
        XCTAssertEqual("Expired: ", actual.expirationText)
	}

	func testCreateHormoneViewStrings_whenGivenNonExpiredPatch_returnsExpectedStrings() {
		let patch = createPatch(isExpired: false)
        let actual = ColonStrings.createHormoneViewStrings(patch)
		XCTAssertEqual("Expires: ", actual.expirationText)
	}
    
    func testCreateHormoneViewStrings_whenGivenPatchThatIsNotExpiredButIsPastNotificationTime_returnsExpectedString() {
        let patch = createHormone(isExpired: false)
        patch.isPastNotificationTime = true
        let actual = ColonStrings.createHormoneViewStrings(patch)
        XCTAssertEqual("Expires soon: ", actual.expirationText)
    }

	func testCreateHormoneViewStrings_whenGivenExpiredInjection_returnsExpectedStrings() {
		let injection = createInjection(isExpired: true)
		let actual = ColonStrings.createHormoneViewStrings(injection)
		XCTAssertEqual("Next due: ", actual.expirationText)
	}

	func testGetDateTitle_whenGivenNonExpiredInjection_returnsExpectedStrings() {
		let injection = createInjection(isExpired: false)
		let actual = ColonStrings.createHormoneViewStrings(injection)
        XCTAssertEqual("Next due: ", actual.expirationText)
	}
}
