//
//  PillXDaysIntegrationTestCase.swift
//  PDTest
//
//  Created by Juliya Smith on 8/8/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import XCTest
import PDKit
import PDTest
import PatchData

@testable
import PatchDay

class PillXDaysIntegrationTestCase: PDIntegrationTestCase {

    private var timesaday = 0
    private var daysOne = 0
    private var daysTwo = 0
    private var daysGap = 0
    private var currentDay = 0

    private let newPillIndex = 2
    private let viewController = UIViewController()
    private let tableView = UITableView()
    private let mockPillsTable = MockPillsTable()
    private var alertFactory: AlertFactory!
    private var pillsViewModel: PillsViewModel!
    private var detailViewModel: PillDetailViewModel!

    private var pills: PillSchedule {
        sdk.pills as! PillSchedule
    }

    func runTest(
        timesaday: Int,
        daysOne: Int,
        daysTwo: Int,
        daysGap: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        setUpTest(timesaday: timesaday, daysOne: daysOne, daysTwo: daysTwo, daysGap: daysGap)
        let daysToIncrement = self.daysOne + self.daysTwo + 1
        for i in 0...daysToIncrement {
            let (position, max, isOn) = getPosition(
                daysAfterStart: self.daysGap * i, file: file, line: line
            )
            let expected = createExpectedText(position: position, max: max, isOn: isOn)
            takeAndAssert(expectedPositionText: expected, file: file, line: line)
            fastForward(days: self.daysGap * (i + 1), file: file, line: line)
            currentDay += 1
        }
    }

    func setUpTest(timesaday: Int, daysOne: Int, daysTwo: Int, daysGap: Int) {
        self.timesaday = timesaday
        self.daysOne = daysOne
        self.daysTwo = daysTwo
        self.daysGap = daysGap
        alertFactory = AlertFactory(sdk: sdk, tabs: dependencies.tabs)
        let table = MockPillsTable()
        pillsViewModel = PillsViewModel(
            alertFactory: alertFactory,
            table: table,
            dependencies: dependencies,
            now: now
        )

        let failMessage = "Failed during test setup"

        // Create new pill for tests
        XCTAssertEqual(newPillIndex, sdk.pills.count, failMessage)
        pillsViewModel.goToNewPillDetails(pillsViewController: viewController)
        XCTAssertEqual(newPillIndex + 1, sdk.pills.count, failMessage)

        setDetailViewModel()

        detailViewModel.setTimesaday(self.timesaday)
        selectXDays(failMessage: failMessage)
    }

    private func selectXDays(failMessage: String) {
        detailViewModel.selectExpirationInterval(getXDaysOptionIndex(failMessage: failMessage))
        XCTAssertEqual(.XDaysOnXDaysOff, detailViewModel.expirationInterval, failMessage)
        XCTAssertEqual("Days on:", detailViewModel.daysOneLabelText, failMessage)
        XCTAssertEqual("Days off:", detailViewModel.daysTwoLabelText, failMessage)

        detailViewModel.selectFromDaysPicker(daysOne - 1, daysNumber: 1)
        detailViewModel.selectFromDaysPicker(daysTwo - 1, daysNumber: 2)
        XCTAssertEqual("\(daysOne)", detailViewModel.daysOn, failMessage)
        XCTAssertEqual("\(daysTwo)", detailViewModel.daysOff, failMessage)
        detailViewModel.save()
    }

    private func getXDaysOptionIndex(
        failMessage: String, file: StaticString = #filePath, line: UInt = #line
    ) -> Index {
        let intervalOptions = PillStrings.Intervals.all
        guard let indexToSelect = intervalOptions.firstIndex(
            where: { $0 == PillStrings.Intervals.XDaysOnXDaysOff }
        ) else {
            XCTFail("Unable to select .XDaysOnXDaysOff - \(failMessage)", file: file, line: line)
            return -1
        }
        return indexToSelect
    }

    private func takeAndAssert(expectedPositionText: String, file: StaticString = #filePath, line: UInt = #line) {
        let actual = detailViewModel.daysPositionText
        let expected = expectedPositionText
        XCTAssertEqual(expected, actual, "beforeTake, day=\(currentDay)", file: file, line: line)
        take(file: file, line: line)
        XCTAssertEqual(expected, actual, "afterTake, day=\(currentDay)", file: file, line: line)
    }

    private func take(file: StaticString = #filePath, line: UInt = #line) {
        pillsViewModel.takePill(at: newPillIndex)
        setDetailViewModel()
        guard let pill = detailViewModel.pill else {
            XCTFail("Pill is nil")
            return
        }
        let actual = pill.timesTakenToday
        let expected = pill.expirationInterval.xDaysIsOn! ? 1 : 0
        let message = "Pill was not taken expected number of times"
        XCTAssertEqual(expected, actual, message, file: file, line: line)
    }

    private func fastForward(days: Int, file: StaticString = #filePath, line: UInt = #line) {
        setAllPillsNow(daysFromActualNow: days)
        pills.awaken()
        setDetailViewModel()

        guard let pill = detailViewModel.pill else {
            XCTFail("Pill is nil")
            return
        }

        if days > 0, pill.timesTakenToday != 0 {
            let prefix = "Pill did not awaken correctly"
            let timesTakenString = "timesTakenToday still \(pill.timesTakenToday)"
            XCTFail("\(prefix); \(timesTakenString); currentDay \(currentDay)")
            return
        }
        let (expectedPosition, expectedMax, expectedIsOn) = getPosition(
            daysAfterStart: days, file: file, line: line
        )
        let expected = createExpectedText(
            position: expectedPosition, max: expectedMax, isOn: expectedIsOn
        )
        let actual = detailViewModel.daysPositionText
        XCTAssertEqual(expected, actual, file: file, line: line)
    }

    private func setAllPillsNow(
        daysFromActualNow: Int, file: StaticString = #filePath, line: UInt = #line
    ) {
        now.now = TestDateFactory.createTestDate(
            daysFrom: daysFromActualNow, file: file, line: line
        )
        pills._now = now
        for swallowable in pills.all {
            guard let pill = swallowable as? Pill else {
                XCTFail("Not of type Pill.")
                return
            }
            pill._now = now
        }
        if daysFromActualNow > 0 {
            verifyPillNotWokeUp(file: file, line: line)
        }
    }

    private func verifyPillNotWokeUp(file: StaticString = #filePath, line: UInt = #line) {
        for pill in pills.all {
            let failMessage = "pill woke up today when it should have reset"
            XCTAssertFalse(pill.wokeUpToday, failMessage, file: file, line: line)
        }
    }

    private func setDetailViewModel() {
        detailViewModel = PillDetailViewModel(newPillIndex, dependencies: dependencies, now: now)
    }

    /// Returns position information based on the current days from the testing start date.
    private func getPosition(
        daysAfterStart: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (Index, Int, Bool) {
        let defaultReturn = (-1, -1, true)
        if daysAfterStart < 0 {
            XCTFail("daysFromNow should be positive.", file: file, line: line)
            return defaultReturn
        }
        var position = 1
        var isOn = true
        let getMax = [true: daysOne, false: daysTwo]
        var max = -1
        for i in 0...daysAfterStart {
            max = getMax[isOn] ?? -1
            position = i + 1
            if position > max {
                position = 1
                isOn = !isOn
            }
        }
        return (position, max, isOn)
    }

    private func createExpectedText(position: Int, max: Int, isOn: Bool) -> String {
        let isOnString = isOn ? "on" : "off"
        return "Current position: \(position) of \(max) (\(isOnString))"
    }

    private func assertPositionText(
        expected: String, file: StaticString = #filePath, line: UInt = #line
    ) {
        let failMessage = "day=\(currentDay)"
        let actual = detailViewModel.daysPositionText
        XCTAssertEqual(expected, actual, failMessage, file: file, line: line)
    }
}
