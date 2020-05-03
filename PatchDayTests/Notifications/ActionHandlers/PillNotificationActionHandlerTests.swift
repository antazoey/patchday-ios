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

	private var mockPill = MockPill()
	private var pills = MockPillSchedule()
	private var badge = MockBadge()
	static var requesterCallCount = 0
	private var requester: (Swallowable) -> Void = { _ in requesterCallCount += 1 }

	private func setUpHandler() -> PillNotificationActionHandler {
		badge = MockBadge()
		mockPill = MockPill()
		pills.subscriptIdReturnValue = mockPill
		let handler = PillNotificationActionHandler(pills, badge)
		handler.requestPillNotification = requester
		return handler
	}

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
		let handler = setUpHandler()
		handler.handlePill(pillId: mockPill.id.uuidString)
		XCTAssertEqual(mockPill.id, pills.swallowIdCallArgs[0].0)

		// Exceute closure and verify
		pills.swallowIdCallArgs[0].1!()
		XCTAssertEqual(1, PillNotificationActionHandlerTests.requesterCallCount)
		PillNotificationActionHandlerTests.requesterCallCount = 0
		XCTAssertEqual(1, badge.decrementCallCount)
	}

	func testHandlePill_whenClosureExecuted_requestsNewNotification() {
		PillNotificationActionHandlerTests.requesterCallCount = 0
		let handler = setUpHandler()
		handler.handlePill(pillId: mockPill.id.uuidString)
		pills.swallowIdCallArgs[0].1!()
		XCTAssertEqual(1, PillNotificationActionHandlerTests.requesterCallCount)
		PillNotificationActionHandlerTests.requesterCallCount = 0
	}

	func testHandlePill_whenClosureExecuted_decrementsBadge() {
		let handler = setUpHandler()
		handler.handlePill(pillId: mockPill.id.uuidString)
		pills.swallowIdCallArgs[0].1!()
		XCTAssertEqual(1, badge.decrementCallCount)
		PillNotificationActionHandlerTests.requesterCallCount = 0
	}
}
