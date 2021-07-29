//
//  PillCellActionAlertTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/1/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class PillCellActionAlertTests: XCTestCase {

    private let testDaysOneValue = "5"
    private let testDaysTwoValue = "7"

    func testPresent_whenPillInXDaysOffPositionGreaterThanOne_doesNotHaveUndoTakeAction() {
        var mockPill = createPillTakenToday()
        mockPill = setPillAsXDaysOnXDaysOff(mockPill, daysPosition: 3, isOn: false)
        let handlers = PillCellActionHandlers(
            goToDetails: {}, takePill: {}, undoTakePill: {}
        )
        let alert = PillCellActionAlert(pill: mockPill, handlers: handlers)

        alert.present()

        let actual = alert.alert.actions
        let expected = ["Edit", "Cancel", "Take"]
        assertHasActions(expected, actual)
    }

    func testPresent_whenPillInXDaysOffPositionEqualToOneAndTakenToday_doesHaveUndoTakeAction() {
        var mockPill = createPillTakenToday()
        mockPill = setPillAsXDaysOnXDaysOff(createPillTakenToday(), daysPosition: 1, isOn: false)

        let handlers = PillCellActionHandlers(
            goToDetails: {}, takePill: {}, undoTakePill: {}
        )
        let alert = PillCellActionAlert(pill: mockPill, handlers: handlers)

        alert.present()

        let actual = alert.alert.actions
        let expected = ["Edit", "Cancel", "Take", "Undo Take"]
        assertHasActions(expected, actual)
    }

    func testPresent_whenPillXDaysInOnPosition_doesHaveUndoTakeAction() {
        var mockPill = createPillTakenToday()
        mockPill = setPillAsXDaysOnXDaysOff(createPillTakenToday(), daysPosition: 3, isOn: true)
        let handlers = PillCellActionHandlers(
            goToDetails: {}, takePill: {}, undoTakePill: {}
        )
        let alert = PillCellActionAlert(pill: mockPill, handlers: handlers)

        alert.present()

        let actual = alert.alert.actions
        let expected = ["Edit", "Cancel", "Take", "Undo Take"]
        assertHasActions(expected, actual)
    }

    func testPresent_whenPillNotYetTakenToday_doesNotHaveUndoTakeAction() {
        let mockPill = MockPill()
        mockPill.timesTakenToday = 0
        mockPill.expirationInterval = PillExpirationInterval(.EveryDay)
        let handlers = PillCellActionHandlers(
            goToDetails: {}, takePill: {}, undoTakePill: {}
        )
        let alert = PillCellActionAlert(pill: mockPill, handlers: handlers)

        alert.present()

        let actual = alert.alert.actions
        let expected = ["Edit", "Cancel", "Take"]
        assertHasActions(expected, actual)
    }

    func testPresent_whenPillTakenTodayAndHasEveryDaySchedule_doesHaveUndoTakeAction() {
        let mockPill = createPillTakenToday()
        mockPill.expirationInterval = PillExpirationInterval(.EveryDay)
        let handlers = PillCellActionHandlers(
            goToDetails: {}, takePill: {}, undoTakePill: {}
        )
        let alert = PillCellActionAlert(pill: mockPill, handlers: handlers)

        alert.present()

        let actual = alert.alert.actions
        let expected = ["Edit", "Cancel", "Take", "Undo Take"]
        assertHasActions(expected, actual)
    }

    func testPresent_whenPillFullyTaken_doesNotHaveTakeAction() {
        let mockPill = createPillTakenToday(isDone: true)
        mockPill.expirationInterval = PillExpirationInterval(.EveryDay)
        let handlers = PillCellActionHandlers(
            goToDetails: {}, takePill: {}, undoTakePill: {}
        )
        let alert = PillCellActionAlert(pill: mockPill, handlers: handlers)

        alert.present()

        let actual = alert.alert.actions
        let expected = ["Edit", "Cancel", "Undo Take"]
        assertHasActions(expected, actual)
    }

    private func createPillTakenToday(isDone: Bool=false) -> MockPill {
        let mockPill = MockPill()
        mockPill.timesTakenToday = 1
        mockPill.lastTaken = Date()
        mockPill.isDone = isDone
        mockPill.timesaday = isDone ? 1 : 2
        return mockPill
    }

    private func setPillAsXDaysOnXDaysOff(
        _ mockPill: MockPill, daysPosition: Int=1, isOn: Bool=true
    ) -> MockPill {
        let isOnValue = isOn ? "on" : "off"
        let xDays = "\(testDaysOneValue)-\(testDaysTwoValue)-\(isOnValue)-\(daysPosition)"
        mockPill.expirationInterval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: xDays)
        return mockPill
    }

    private func assertHasActions(
        _ expectedActionTitles: [String], _ alertActions: [UIAlertAction]
    ) {
        if expectedActionTitles.count != alertActions.count {
            let actualTitles = alertActions.map { $0.title! }
            let actualTitlesString = actualTitles.joined(separator: ", ")
            XCTFail("Actual titles (\(actualTitles.count)): \(actualTitlesString)")
            return
        }

        var index = 0
        for expected in expectedActionTitles {
            guard let actual = alertActions[index].title else {
                XCTFail("Encountered nil action title.")
                return
            }

            XCTAssertEqual(expected, actual)
            index += 1
        }
    }
}
