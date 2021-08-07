//
//  PillNotificationActionHandlerTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/2/20.

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class PillNotificationActionHandlerTests: PDTestCase {

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
        PDAssertEmpty(pills.swallowIdCallArgs)
    }

    func testHandlePill_whenPillNotInSchedule_doesNotHandle() {
        let pills = MockPillSchedule()
        let badge = MockBadge()
        let handler = PillNotificationActionHandler(pills, badge)
        let pill = MockPill()
        handler.handlePill(pillId: pill.id.uuidString)
        PDAssertEmpty(pills.swallowIdCallArgs)
    }

    func testHandlePill_handles() {
        let handler = setUpHandler()
        handler.handlePill(pillId: mockPill.id.uuidString)
        XCTAssertEqual(mockPill.id, pills.swallowIdCallArgs[0].0)

        // Exceute closure and verify
        pills.swallowIdCallArgs[0].1!()
        XCTAssertEqual(1, PillNotificationActionHandlerTests.requesterCallCount)
        PillNotificationActionHandlerTests.requesterCallCount = 0
        XCTAssertEqual(1, badge.reflectCallCount)
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
        XCTAssertEqual(1, badge.reflectCallCount)
        PillNotificationActionHandlerTests.requesterCallCount = 0
    }
}
