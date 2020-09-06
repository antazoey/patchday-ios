//
//  PillsViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/28/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class PillsViewModelTests: XCTestCase {

    private let tableView = UITableView()
    private let testPill = MockPill()

    private func createViewModel() -> PillsViewModel {
        let alertFactory = MockAlertFactory()
        let deps = MockDependencies()
        (deps.sdk?.pills as! MockPillSchedule).all = [testPill]
        return PillsViewModel(
            pillsTableView: self.tableView, alertFactory: alertFactory, dependencies: deps
        )
    }

    func testCreatePillCellSwipeActions_whenCalled_deletesPill() {
        let viewModel = createViewModel()
        let expected = 3
        let index = IndexPath(row: expected, section: 0)
        let actions = viewModel.createPillCellSwipeActions(index: index)
        actions.actions[0].handler(UIContextualAction(), UIView(), {_ in })
        let actual = (viewModel.sdk?.pills as! MockPillSchedule).deleteCallArgs[0]
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(UIColor.red, actions.actions[0].backgroundColor)
    }

    func testPresentPillActions_whenChooseTake_callsCompleter() {
        let viewModel = createViewModel()
        var completerCalled = false
        let completer = { completerCalled = true }
        viewModel.presentPillActions(
            at: 0,
            viewController: UIViewController(),
            takePillCompletion: completer
        )
        let handlers = (viewModel.alerts as! MockAlertFactory).createPillActionsCallArgs[0].1
        handlers.takePill()
        XCTAssert(completerCalled)
    }

    func testTakePill_callsSwallow() {
        let viewModel = createViewModel()
        viewModel.takePill(at: 0)
        let pills = viewModel.sdk?.pills as! MockPillSchedule
        XCTAssertEqual(1, pills.swallowIdCallArgs.count)
    }

    func testTakePill_reflectsPillsInTabs() {
        let viewModel = createViewModel()
        let tabs = viewModel.tabs as! MockTabs
        tabs.reflectPillsCallCount = 0
        viewModel.takePill(at: 0)
        XCTAssertEqual(1, tabs.reflectPillsCallCount)
    }

    func testTakePill_requestNotification() {
        let viewModel = createViewModel()
        viewModel.takePill(at: 0)
        (viewModel.pills as! MockPillSchedule).swallowIdCallArgs[0].1!()  // Call closure
        let notifications = viewModel.notifications as! MockNotifications
        XCTAssertEqual(testPill.id, notifications.requestDuePillNotificationCallArgs[0].id)
    }
}
