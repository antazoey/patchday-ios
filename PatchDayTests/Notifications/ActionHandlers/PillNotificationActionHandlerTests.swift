//
//  PillNotificationActionHandlerTests.swift
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


class PillNotificationActionHandlerTests: XCTestCase {
	func testHandlePill_whenGivenFakeId_doesNotHandle() {
		let pills = MockPillSchedule()
		let badge = MockBadge()
		let handler = PillNotificationActionHandler(pills, badge)
		handler.handlePill(pillId: "Fake ID")
		XCTAssertEqual(0, pills.swallowIdCallArgs.count)
	}
	
	func testHandlePill_whenPillNotInSchedule_doesNotHandle() {
		let pills = MockPillSchedule()
		let badge = MockBadge()
		let handler = PillNotificationActionHandler(pills, badge)
		let pill = MockPill()
		handler.handlePill(pillId: pill.id.uuidString)
		XCTAssertEqual(0, pills.swallowIdCallArgs.count)
	}
	
	func testHandlePill_handles() {
		let pills = MockPillSchedule()
		let pill = MockPill()
		pills.all = [pill]
		let badge = MockBadge()
		let handler = PillNotificationActionHandler(pills, badge)
		handler.handlePill(pillId: pill.id.uuidString)
		XCTAssertEqual(1, pills.swallowIdCallArgs.count)
	}
	
	func testHandlePill_whenRequestPillNotificationIsSet_requests() {
		let pills = MockPillSchedule()
		let pill = MockPill()
		pills.all = [pill]
		let badge = MockBadge()
		let handler = PillNotificationActionHandler(pills, badge)
		var requesterCallCount = 0
		let requester: (Swallowable) -> (Void) = { _ in requesterCallCount += 1 }
		handler.requestPillNotification = requester
		handler.handlePill(pillId: pill.id.uuidString)
		XCTAssertEqual(1, requesterCallCount)
	}
	
	func testHandlePill_decrementsBadge() {
		let pills = MockPillSchedule()
		let pill = MockPill()
		pills.all = [pill]
		let badge = MockBadge()
		let handler = PillNotificationActionHandler(pills, badge)
		handler.handlePill(pillId: pill.id.uuidString)
		XCTAssertEqual(1, badge.decrementCallCount)
	}
}
