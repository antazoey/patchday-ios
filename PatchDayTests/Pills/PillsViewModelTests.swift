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
    private let deps = MockDependencies()
    private let alerts = MockAlertFactory()
    private let table = MockPillsTable()
    private let cell = MockPillCell()

    private func createViewModel() -> PillsViewModel {
        (deps.sdk?.pills as! MockPillSchedule).all = [testPill]
        table.subscriptReturnValue = cell
        return PillsViewModel(
            pillsTableView: self.tableView, alertFactory: alerts, table: table, dependencies: deps
        )
    }

    func testPills_returnsPillsFromSdk() {
        let viewModel = createViewModel()
        let pills = viewModel.pills!
        XCTAssertEqual(1, pills.count)
        XCTAssertEqual(testPill.id, pills[0]!.id)
    }

    func testPillsCount_whenNoSdk_returnsZero() {
        let deps = MockDependencies()
        deps.sdk = nil
        let viewModel = PillsViewModel(
            pillsTableView: self.tableView, alertFactory: alerts, table: table, dependencies: deps
        )
        XCTAssertEqual(0, viewModel.pillsCount)
    }

    func testPillsCount_returnsPillsCount() {
        let viewModel = createViewModel()
        (deps.sdk?.pills as! MockPillSchedule).all = [testPill, testPill, testPill, testPill]
        let actual = viewModel.pillsCount
        XCTAssertEqual(4, actual)
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

    func testTakePill_subscriptsCorrectCell() {
        let viewModel = createViewModel()
        viewModel.takePill(at: 0)
        (viewModel.pills as! MockPillSchedule).swallowIdCallArgs[0].1!()  // Call closure
        XCTAssertEqual(0, table.subscriptCallArgs[0])
    }

    func testTakePill_stampsCell() {
        let viewModel = createViewModel()
        viewModel.takePill(at: 0)
        (viewModel.pills as! MockPillSchedule).swallowIdCallArgs[0].1!()  // Call closure
        XCTAssertEqual(1, cell.stampCallCount)
    }

    func testTakePill_configuresCell() {
        let viewModel = createViewModel()
        viewModel.takePill(at: 0)
        (viewModel.pills as! MockPillSchedule).swallowIdCallArgs[0].1!()  // Call closure
        let callArgs = cell.configureCallArgs
        XCTAssertEqual(1, callArgs.count)
        let params = callArgs[0]
        XCTAssertEqual(testPill.id, params.pill.id)
        XCTAssertEqual(0, params.index)
    }

    func testDeletePill_deletesPill() {
        let viewModel = createViewModel()
        let pills = deps.sdk?.pills as! MockPillSchedule
        pills.all = [MockPill(), testPill, MockPill()]
        let testIndex = 1
        let testIndexPath = IndexPath(row: testIndex, section: 0)
        viewModel.deletePill(at: testIndexPath)
        let callArgs = pills.deleteCallArgs
        let expected = testIndex
        let actual = callArgs[0]
        XCTAssertEqual(expected, actual)
    }

    func testPresentPillActions_presentsAlertForExpectedPill() {
        let viewModel = createViewModel()
        viewModel.presentPillActions(
            at: 0,
            viewController: UIViewController(),
            takePillCompletion: {}
        )
        let alerts = deps.alerts as! MockAlertFactory
        XCTAssertEqual(1, alerts.createPillActionsReturnValue.presentCallCount)
        let creationParams = alerts.createPillActionsCallArgs
        XCTAssertEqual(1, creationParams.count)
        XCTAssertEqual(testPill.id, creationParams[0].0.id)
    }

    func testPresentPillActions_whenChoosesTakeAction_callsCompleter() {
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

    func testPresentPillActions_whenChoosesTakeAction_reflectsTabs() {
        let viewModel = createViewModel()
        let tabs = deps.tabs as! MockTabs
        viewModel.presentPillActions(
            at: 0,
            viewController: UIViewController(),
            takePillCompletion: {}
        )
        let handlers = (viewModel.alerts as! MockAlertFactory).createPillActionsCallArgs[0].1
        tabs.reflectPillsCallCount = 0  // reset prior to test
        handlers.takePill()
        XCTAssertEqual(1, tabs.reflectPillsCallCount)
    }

    func testPresentPillActions_whenChoosesTakeAction_callsSwallow() {
        let viewModel = createViewModel()
        let tabs = deps.tabs as! MockTabs
        viewModel.presentPillActions(
            at: 0,
            viewController: UIViewController(),
            takePillCompletion: {}
        )
        let handlers = (viewModel.alerts as! MockAlertFactory).createPillActionsCallArgs[0].1
        tabs.reflectPillsCallCount = 0  // reset prior to test
        handlers.takePill()
        let pills = viewModel.sdk?.pills as! MockPillSchedule
        XCTAssertEqual(1, pills.swallowIdCallArgs.count)
    }

    func testPresentPillActions_whenChoosesTakeAction_requestNotification() {
        let viewModel = createViewModel()
        let tabs = deps.tabs as! MockTabs
        viewModel.presentPillActions(
            at: 0,
            viewController: UIViewController(),
            takePillCompletion: {}
        )
        let handlers = (viewModel.alerts as! MockAlertFactory).createPillActionsCallArgs[0].1
        tabs.reflectPillsCallCount = 0  // reset prior to test
        handlers.takePill()
        (viewModel.pills as! MockPillSchedule).swallowIdCallArgs[0].1!()  // Call closure
        let notifications = viewModel.notifications as! MockNotifications
        XCTAssertEqual(testPill.id, notifications.requestDuePillNotificationCallArgs[0].id)
    }

    func testPresentPillActions_whenChoosesTakeAction_subscriptsCorrectCell() {
        let viewModel = createViewModel()
        let tabs = deps.tabs as! MockTabs
        viewModel.presentPillActions(
            at: 0,
            viewController: UIViewController(),
            takePillCompletion: {}
        )
        let handlers = (viewModel.alerts as! MockAlertFactory).createPillActionsCallArgs[0].1
        tabs.reflectPillsCallCount = 0  // reset prior to test
        handlers.takePill()
        (viewModel.pills as! MockPillSchedule).swallowIdCallArgs[0].1!()  // Call closure
        XCTAssertEqual(0, table.subscriptCallArgs[0])
    }

    func testPresentPillActions_whenChoosesTakeAction_stampsCell() {
        let viewModel = createViewModel()
        let tabs = deps.tabs as! MockTabs
        viewModel.presentPillActions(
            at: 0,
            viewController: UIViewController(),
            takePillCompletion: {}
        )
        let handlers = (viewModel.alerts as! MockAlertFactory).createPillActionsCallArgs[0].1
        tabs.reflectPillsCallCount = 0  // reset prior to test
        handlers.takePill()
        (viewModel.pills as! MockPillSchedule).swallowIdCallArgs[0].1!()  // Call closure
        XCTAssertEqual(1, cell.stampCallCount)
    }

    func testPresentPillActions_whenChoosesTakeAction_configuresCell() {
        let viewModel = createViewModel()
        let tabs = deps.tabs as! MockTabs
        viewModel.presentPillActions(
            at: 0,
            viewController: UIViewController(),
            takePillCompletion: {}
        )
        let handlers = (viewModel.alerts as! MockAlertFactory).createPillActionsCallArgs[0].1
        tabs.reflectPillsCallCount = 0  // reset prior to test
        handlers.takePill()
        (viewModel.pills as! MockPillSchedule).swallowIdCallArgs[0].1!()  // Call closure
        let callArgs = cell.configureCallArgs
        XCTAssertEqual(1, callArgs.count)
        let params = callArgs[0]
        XCTAssertEqual(testPill.id, params.pill.id)
        XCTAssertEqual(0, params.index)
    }

    func testGoToNewPillDetails_whenCreatingPillFails_doesNotNavigate() {
        let viewModel = createViewModel()
        let nav = deps.nav as! MockNav
        let pills = deps.sdk?.pills as! MockPillSchedule
        let vc = UIViewController()
        pills.insertNewReturnValue = nil
        pills.indexOfReturnsValue = 1
        viewModel.goToNewPillDetails(pillsViewController: vc)
        let callArgs = nav.goToPillDetailsCallArgs
        XCTAssertEqual(0, callArgs.count)
    }

    func testGoToNewPillDetails_navigates() {
        let viewModel = createViewModel()
        let nav = deps.nav as! MockNav
        let pills = deps.sdk?.pills as! MockPillSchedule
        let vc = UIViewController()
        let newPill = MockPill()
        pills.insertNewReturnValue = newPill
        pills.indexOfReturnsValue = 1
        pills.all = [testPill, newPill]
        viewModel.goToNewPillDetails(pillsViewController: vc)
        let callArgs = nav.goToPillDetailsCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual(1, callArgs[0].0)
        XCTAssertEqual(vc, callArgs[0].1)
    }

    func testGoToPillDetails_navigates() {
        let nav = deps.nav as! MockNav
        let viewModel = createViewModel()
        let vc = UIViewController()
        viewModel.goToPillDetails(pillIndex: 0, pillsViewController: vc)
        XCTAssertEqual(0, nav.goToPillDetailsCallArgs[0].0)
        XCTAssertEqual(vc, nav.goToPillDetailsCallArgs[0].1)
    }

    func testGoToPillDetails_whenPillIndexNegative_doesNotNavigates() {
        let nav = deps.nav as! MockNav
        let viewModel = createViewModel()
        let vc = UIViewController()
        viewModel.goToPillDetails(pillIndex: -1, pillsViewController: vc)
        XCTAssertEqual(0, nav.goToPillDetailsCallArgs.count)
    }

    func testGoToPillDetails_whenPillIndexGreaterThanCount_doesNotNavigates() {
        let nav = deps.nav as! MockNav
        let viewModel = createViewModel()
        let vc = UIViewController()
        viewModel.goToPillDetails(pillIndex: 5, pillsViewController: vc)
        XCTAssertEqual(0, nav.goToPillDetailsCallArgs.count)
    }
}
