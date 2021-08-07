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

    #if targetEnvironment(simulator)
    private let now = MockNow()
    private var sdk = PatchData()
    private let dependencies = MockDependencies()
    private let newPillIndex = 2
    private let viewController = UIViewController()
    private let tableView = UITableView()
    private let mockPillsTable = MockPillsTable()
    private var alertFactory: AlertFactory!
    private var detailViewModel: PillDetailViewModel!

    var tests: [(StaticString, UInt) -> Void] {
        [
            oncePerDayIn2DaysOn2DaysOff
        ]
    }

    var pillSchedule: PillSchedule {
        dependencies.sdk!.pills as! PillSchedule
    }

    var pillsViewModel: PillsViewModel {
        PillsViewModel(
            pillsTableView: tableView,
            alertFactory: alertFactory,
            table: mockPillsTable,
            dependencies: dependencies
        )
    }

    func run(file: StaticString = #filePath, line: UInt = #line) {
        for test in tests {
            setUp()
            test(file, line)
        }
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

    // MARK: - Test timeaday=1, dayOne=2, dayTwo=2

    func oncePerDayIn2DaysOn2DaysOff(file: StaticString = #filePath, line: UInt = #line) {
        detailViewModel.setTimesaday(1)

        let dayOne = 2
        let dayTwo = 2
        selectXDays(dayOne: dayOne, dayTwo: dayTwo)

        takeAndAssert(expectedPositionText: "Current position: 1 of 2 (on)")
        fastForward(hours: 24, dayOne: dayOne, dayTwo: dayTwo)
        takeAndAssert(expectedPositionText: "Current position: 2 of 2 (on)")
        fastForward(hours: 24 * 2, dayOne: dayOne, dayTwo: dayTwo)
        assertPositionText(expected: "Current position: 1 of 2 (off)")
        fastForward(hours: 24 * 3, dayOne: dayOne, dayTwo: dayTwo)
        assertPositionText(expected: "Current position: 2 of 2 (off)")
        fastForward(hours: 24 * 4, dayOne: dayOne, dayTwo: dayTwo)
        takeAndAssert(expectedPositionText: "Current position: 1 of 2 (on)")
    }

    private func setDetailViewModel() {
        detailViewModel = PillDetailViewModel(newPillIndex, dependencies: dependencies, now: now)
    }

    private func fastForward(hours: Int, dayOne: Int, dayTwo: Int) {
        now.now = TestDateFactory.createTestDate(hoursFrom: hours)
        pillSchedule._now = now
        for swallowable in pillSchedule.all {
            let pill = swallowable as! Pill
            pill._now = now
        }
        sdk.pills.awaken()
        setDetailViewModel()
        XCTAssertEqual(0, detailViewModel.pill!.timesTakenToday)
        let (expectedPosition, expectedIsOn) = getNextPosition(
            daysFromNow: hours / 24, dayOneLimit: dayOne, dayTwoLimit: dayTwo
        )
        let isOnString = expectedIsOn ? "on" : "off"
        let max = [true: dayOne, false: dayTwo][expectedIsOn]!
        let expected = "Current position: \(expectedPosition) of \(max) (\(isOnString))"
        let actual = detailViewModel.daysPositionText
        if expected != actual {
            XCTFail("\(expected) not equal to \(actual)")
            return
        }
    }

    private func getNextPosition(
        daysFromNow: Int, dayOneLimit: Int, dayTwoLimit: Int
    ) -> (Index, Bool) {
        let defaultReturn = (1, true)
        if daysFromNow < 1 {
            XCTFail("daysFromNow should be positive.")
            return defaultReturn
        }
        var position = 1
        var isOn = true
        let getMax = [true: dayOneLimit, false: dayTwoLimit]
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

    private func selectXDays(dayOne: Int, dayTwo: Int) {
        detailViewModel.selectExpirationInterval(getXDaysOptionIndex())
        XCTAssertEqual(.XDaysOnXDaysOff, detailViewModel.expirationInterval)
        XCTAssertEqual("Days on:", detailViewModel.daysOneLabelText)
        XCTAssertEqual("Days off:", detailViewModel.daysTwoLabelText)

        detailViewModel.selectFromDaysPicker(dayOne - 1, daysNumber: 1)
        detailViewModel.selectFromDaysPicker(dayTwo - 1, daysNumber: 2)
        XCTAssertEqual("\(dayOne)", detailViewModel.daysOn)
        XCTAssertEqual("\(dayTwo)", detailViewModel.daysOff)
        detailViewModel.save()
    }

    private func getXDaysOptionIndex() -> Index {
        let intervalOptions = PillStrings.Intervals.all
        guard let indexToSelect = intervalOptions.firstIndex(
            where: { $0 == PillStrings.Intervals.XDaysOnXDaysOff }
        ) else {
            XCTFail("Unable to select .XDaysOnXDaysOff")
            return -1
        }
        return indexToSelect
    }

    private func takeAndAssert(expectedPositionText: String) {
        XCTAssertEqual(expectedPositionText, detailViewModel.daysPositionText)
        take()
        XCTAssertEqual(expectedPositionText, detailViewModel.daysPositionText)
    }

    private func take(timesTodaySoFar: Int = 1) {
        pillsViewModel.takePill(at: newPillIndex)
        XCTAssertEqual(timesTodaySoFar, detailViewModel.pill!.timesTakenToday)
    }

    private func assertPositionText(expected: String) {
        XCTAssertEqual(expected, detailViewModel.daysPositionText)
    }
    #endif
}
// swiftlint:enable function_body_length
