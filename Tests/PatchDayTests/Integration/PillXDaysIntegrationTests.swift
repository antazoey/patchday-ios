//
//  PillXDaysIntegrationTests.swift
//  PDTest
//
//  Created by Juliya Smith on 8/7/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest
import PatchData

@testable
import PatchDay

// swiftlint:disable function_body_length
class PillXDaysIntegrationTests {

    var tests: [PillXDaysIntegrationTest] {
        [
            PillXDaysIntegrationTest(daysOne: 2, daysTwo: 2)
        ]
    }

    func run(file: StaticString = #filePath, line: UInt = #line) {
        #if targetEnvironment(simulator)
        for test in tests {
            test.setUp()
            test.run(file: file, line: line)
        }
        #endif
    }
}

class PillXDaysIntegrationTest {

    private let daysOne: Int
    private let daysTwo: Int

    private let now = MockNow()
    private var sdk = PatchData()
    private let dependencies = MockDependencies()
    private let newPillIndex = 2
    private let viewController = UIViewController()
    private let tableView = UITableView()
    private let mockPillsTable = MockPillsTable()
    private var alertFactory: AlertFactory!
    private var detailViewModel: PillDetailViewModel!

    init(daysOne: Int, daysTwo: Int) {
        self.daysOne = daysOne
        self.daysTwo = daysTwo
    }

    func setUp() {
        sdk.resetAll()
        dependencies.sdk = sdk
        alertFactory = AlertFactory(sdk: sdk, tabs: dependencies.tabs)

        // Create new pill for tests
        XCTAssertEqual(newPillIndex, sdk.pills.count)
        pillsViewModel.goToNewPillDetails(pillsViewController: viewController)
        XCTAssertEqual(newPillIndex + 1, sdk.pills.count)

        setDetailViewModel()
    }

    func run(file: StaticString = #filePath, line: UInt = #line) {
        detailViewModel.setTimesaday(1)
        selectXDays()
        takeAndAssert(expectedPositionText: "Current position: 1 of 2 (on)", file: file, line: line)
        fastForward(hours: 24, file: file, line: line)
        takeAndAssert(expectedPositionText: "Current position: 2 of 2 (on)", file: file, line: line)
        fastForward(hours: 24 * 2, file: file, line: line)
        assertPositionText(expected: "Current position: 1 of 2 (off)", file: file, line: line)
        fastForward(hours: 24 * 3)
        assertPositionText(expected: "Current position: 2 of 2 (off)", file: file, line: line)
        fastForward(hours: 24 * 4, file: file, line: line)
        takeAndAssert(expectedPositionText: "Current position: 1 of 2 (on)", file: file, line: line)
    }

    private func fastForward(hours: Int, file: StaticString = #filePath, line: UInt = #line) {
        now.now = TestDateFactory.createTestDate(hoursFrom: hours, file: file, line: line)
        pillSchedule._now = now
        for swallowable in pillSchedule.all {
            let pill = swallowable as! Pill
            pill._now = now
        }
        sdk.pills.awaken()
        setDetailViewModel()
        XCTAssertEqual(0, detailViewModel.pill!.timesTakenToday, file: file, line: line)
        let days = hours / 24
        let (expectedPosition, expectedIsOn) = getNextPosition(
            daysFromNow: days, dayOneLimit: dayOne, dayTwoLimit: dayTwo, file: file, line: line
        )
        let isOnString = expectedIsOn ? "on" : "off"
        let max = [true: self.dayOne, false: self.dayTwo][expectedIsOn]!
        let expected = "Current position: \(expectedPosition) of \(max) (\(isOnString))"
        tprint(expected)
        let actual = detailViewModel.daysPositionText
        if expected != actual {
            XCTFail("\(expected) not equal to \(actual)", file: file, line: line)
            return
        }
    }

    private func getNextPosition(
        daysFromNow: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (Index, Bool) {
        let defaultReturn = (1, true)
        if daysFromNow < 1 {
            XCTFail("daysFromNow should be positive.", file: file, line: line)
            return defaultReturn
        }
        var position = 1
        var isOn = true
        let getMax = [true: daysOne, false: daysTwo]
        for i in 1...daysFromNow {
            guard let max = getMax[isOn] else {
                XCTFail("Unhandled boolean value in getMax")
                return defaultReturn
            }
            position = i + 1
            if position > max {
                position = 1
                isOn = !isOn
            }
        }
        return (position, isOn)
    }

    private func setDetailViewModel() {
        detailViewModel = PillDetailViewModel(newPillIndex, dependencies: dependencies, now: now)
    }

    private func selectXDays(file: StaticString = #filePath, line: UInt = #line) {
        detailViewModel.selectExpirationInterval(getXDaysOptionIndex(file: file, line: line))
        XCTAssertEqual(.XDaysOnXDaysOff, detailViewModel.expirationInterval, file: file, line: line)
        XCTAssertEqual("Days on:", detailViewModel.daysOneLabelText, file: file, line: line)
        XCTAssertEqual("Days off:", detailViewModel.daysTwoLabelText, file: file, line: line)

        detailViewModel.selectFromDaysPicker(daysOne - 1, daysNumber: 1)
        detailViewModel.selectFromDaysPicker(daysTwo - 1, daysNumber: 2)
        XCTAssertEqual("\(daysOne)", detailViewModel.daysOn, file: file, line: line)
        XCTAssertEqual("\(daysTwo)", detailViewModel.daysOff, file: file, line: line)
        detailViewModel.save()
    }

    private func getXDaysOptionIndex(file: StaticString = #filePath, line: UInt = #line) -> Index {
        let intervalOptions = PillStrings.Intervals.all
        guard let indexToSelect = intervalOptions.firstIndex(
            where: { $0 == PillStrings.Intervals.XDaysOnXDaysOff }
        ) else {
            XCTFail("Unable to select .XDaysOnXDaysOff", file: file, line: line)
            return -1
        }
        return indexToSelect
    }

    private func takeAndAssert(
        expectedPositionText: String, file: StaticString = #filePath, line: UInt = #line
    ) {
        let actual = detailViewModel.daysPositionText
        XCTAssertEqual(expectedPositionText, actual, file: file, line: line)
        take(file: file, line: line)
        XCTAssertEqual(expectedPositionText, actual, file: file, line: line)
    }

    private func take(
        timesTodaySoFar: Int = 1, file: StaticString = #filePath, line: UInt = #line
    ) {
        pillsViewModel.takePill(at: newPillIndex)
        let actual = detailViewModel.pill!.timesTakenToday
        XCTAssertEqual(timesTodaySoFar, actual, file: file, line: line)
    }

    private func assertPositionText(
        expected: String, file: StaticString = #filePath, line: UInt = #line
    ) {
        XCTAssertEqual(expected, detailViewModel.daysPositionText, file: file, line: line)
    }
}

// swiftlint:enable function_body_length
