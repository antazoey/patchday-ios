//
//  HormoneNotificationActionHandlerTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/2/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay


class HormoneNotificationActionHandlerTests: XCTestCase {
	func testHandleHormone_whenGivenInvalidId_doesNotHandle() {
		let sdk = MockSDK()
		(sdk.sites as! MockSiteSchedule).suggested = MockSite()
		let badge = MockBadge()
		let handler = HormoneNotificationActionHandler(sdk: sdk, appBadge: badge)
		let fakeId = "fake ID"  // not a UUID
		handler.handleHormone(id: fakeId)
		let hormones = sdk.hormones as! MockHormoneSchedule
		XCTAssertEqual(0, hormones.setByIdCallArgs.count)
	}
	
	func testHandleHormone_whenHormoneDoesNotHaveSuggested_doesNotHandle() {
		let sdk = MockSDK()
		let hormone = MockHormone()
		(sdk.hormones as! MockHormoneSchedule).all = [hormone]
		let badge = MockBadge()
		let handler = HormoneNotificationActionHandler(sdk: sdk, appBadge: badge)
		handler.handleHormone(id: hormone.id.uuidString)
		let hormones = sdk.hormones as! MockHormoneSchedule
		XCTAssertEqual(0, hormones.setByIdCallArgs.count)
	}
	
	func testHandleHormone_handles() {
		let sdk = MockSDK()
		(sdk.sites as! MockSiteSchedule).suggested = MockSite()
		let hormone = MockHormone()
		(sdk.hormones as! MockHormoneSchedule).all = [hormone]
		let badge = MockBadge()
		let handler = HormoneNotificationActionHandler(sdk: sdk, appBadge: badge)
		handler.handleHormone(id: hormone.id.uuidString)
		let hormones = sdk.hormones as! MockHormoneSchedule
		XCTAssertEqual(1, hormones.setByIdCallArgs.count)
	}
	
	func testHandleHormone_decrementsBadge() {
		let sdk = MockSDK()
		(sdk.sites as! MockSiteSchedule).suggested = MockSite()
		let hormone = MockHormone()
		(sdk.hormones as! MockHormoneSchedule).all = [hormone]
		let badge = MockBadge()
		let handler = HormoneNotificationActionHandler(sdk: sdk, appBadge: badge)
		handler.handleHormone(id: hormone.id.uuidString)
		XCTAssertEqual(1, badge.decrementCallCount)
	}
}
