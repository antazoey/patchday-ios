//
//  PillsViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/28/20.

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
            pillsTableView: tableView, alertFactory: alerts, table: table, dependencies: deps
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

    func testPillsCount_whenEnbabled_returnsPillsCount() {
        let viewModel = createViewModel()
        (deps.sdk?.settings as! MockSettings).pillsEnabled = PillsEnabledUD(true)
        (deps.sdk?.pills as! MockPillSchedule).all = [testPill, testPill, testPill, testPill]
        let actual = viewModel.pillsCount
        XCTAssertEqual(4, actual)
    }

    func testPillsCount_whenDisabled_returnsZero() {
        let viewModel = createViewModel()
        (deps.sdk?.settings as! MockSettings).pillsEnabled = PillsEnabledUD(false)
        (deps.sdk?.pills as! MockPillSchedule).all = [testPill, testPill, testPill, testPill]
        let actual = viewModel.pillsCount
        XCTAssertEqual(0, actual)
    }

    func testEnabled_returnsValueFromSettings() {
        let viewModel = createViewModel()
        (deps.sdk?.settings as! MockSettings).pillsEnabled = PillsEnabledUD(false)
        XCTAssertFalse(viewModel.enabled)
        (deps.sdk?.settings as! MockSettings).pillsEnabled = PillsEnabledUD(true)
        XCTAssertTrue(viewModel.enabled)
    }

    func testEnabled_whenNilSdk_returnsTrue() {
        let deps = MockDependencies()
        deps.sdk = nil
        let viewModel = PillsViewModel(
            pillsTableView: tableView, alertFactory: alerts, table: table, dependencies: deps
        )
        XCTAssertTrue(viewModel.enabled)
    }

    func testTogglePillsEnabled_whenSettingToTrueAndIsAlreadyTrue_doesNotSet() {
        let viewModel = createViewModel()
        let mockSettings = deps.sdk?.settings as! MockSettings
        mockSettings.pillsEnabled = PillsEnabledUD(true)
        viewModel.togglePillsEnabled(true)
        let callArgs = mockSettings.setPillsEnabledCallArgs
        XCTAssertEqual(0, callArgs.count)
    }

    func testTogglePillsEnabled_whenSettingToFalseAndIsAlreadyFalse_doesNotSet() {
        let viewModel = createViewModel()
        let mockSettings = deps.sdk?.settings as! MockSettings
        mockSettings.pillsEnabled = PillsEnabledUD(false)
        viewModel.togglePillsEnabled(false)
        let callArgs = mockSettings.setPillsEnabledCallArgs
        XCTAssertEqual(0, callArgs.count)
    }

    func testTogglePillsEnabled_whenSettingToTrue_setsToTrue() {
        let viewModel = createViewModel()
        let mockSettings = deps.sdk?.settings as! MockSettings
        mockSettings.pillsEnabled = PillsEnabledUD(false)
        viewModel.togglePillsEnabled(true)
        let didSetToTrue = mockSettings.setPillsEnabledCallArgs[0]
        XCTAssert(didSetToTrue)
    }

    func testTogglePillsEnabled_whenSettingToFalse_setsToFalse() {
        let viewModel = createViewModel()
        let mockSettings = deps.sdk?.settings as! MockSettings
        mockSettings.pillsEnabled = PillsEnabledUD(true)
        viewModel.togglePillsEnabled(false)
        let didSetToTrue = mockSettings.setPillsEnabledCallArgs[0]
        XCTAssertFalse(didSetToTrue)
    }

    func testTogglePillsEnabled_whenSettingToTrue_callsTabsReflectPills() {
        let viewModel = createViewModel()
        let mockSettings = deps.sdk?.settings as! MockSettings
        mockSettings.pillsEnabled = PillsEnabledUD(false)
        let tabs = deps.tabs as! MockTabs
        tabs.reflectPillsCallCount = 0  // Reset mock
        viewModel.togglePillsEnabled(true)
        XCTAssertEqual(1, tabs.reflectPillsCallCount)
    }

    func testTogglePillsEnabled_whenSettingToFalse_callsTabsClearPills() {
        let viewModel = createViewModel()
        let mockSettings = deps.sdk?.settings as! MockSettings
        mockSettings.pillsEnabled = PillsEnabledUD(true)
        let tabs = deps.tabs as! MockTabs
        viewModel.togglePillsEnabled(false)
        XCTAssertEqual(1, tabs.clearPillsCallCount)
    }

    func testTogglePillsEnabled_whenSettingToTrue_cancelsAndReRequestsAllPillNotifications() {
        let viewModel = createViewModel()
        let mockSettings = deps.sdk?.settings as! MockSettings
        mockSettings.pillsEnabled = PillsEnabledUD(false)
        let notifications = deps.notifications as! MockNotifications
        viewModel.togglePillsEnabled(true)
        XCTAssertEqual(1, notifications.cancelAllDuePillNotificationsCallCount)
        XCTAssertEqual(1, notifications.requestAllDuePillNotificationsCallCount)
    }

    func testTogglePillsEnabled_whenSettingToFalse_cancelsAndNotDoesReRequestAllPillNotifications() {
        let viewModel = createViewModel()
        let mockSettings = deps.sdk?.settings as! MockSettings
        mockSettings.pillsEnabled = PillsEnabledUD(true)
        let notifications = deps.notifications as! MockNotifications
        viewModel.togglePillsEnabled(false)
        XCTAssertEqual(1, notifications.cancelAllDuePillNotificationsCallCount)
        XCTAssertEqual(0, notifications.requestAllDuePillNotificationsCallCount)
    }

    func testTogglePillsEnabled_setsWidget() {
        let viewModel = createViewModel()
        let mockSettings = deps.sdk?.settings as! MockSettings
        mockSettings.pillsEnabled = PillsEnabledUD(true)
        let widget = deps.widget as! MockWidget
        viewModel.togglePillsEnabled(false)
        XCTAssertEqual(1, widget.setCallCount)
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
            reloadViews: {}
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
            reloadViews: completer
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
            reloadViews: {}
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
            reloadViews: {}
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
            reloadViews: {}
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
            reloadViews: {}
        )
        let handlers = (viewModel.alerts as! MockAlertFactory).createPillActionsCallArgs[0].1
        tabs.reflectPillsCallCount = 0  // reset prior to test
        handlers.takePill()
        (viewModel.pills as! MockPillSchedule).swallowIdCallArgs[0].1!()  // Call closure
        XCTAssertEqual(0, table.subscriptCallArgs[0])
    }

    func testPresentPillActions_whenChoosesTakeAction_configuresCell() {
        let viewModel = createViewModel()
        let tabs = deps.tabs as! MockTabs
        viewModel.presentPillActions(
            at: 0,
            viewController: UIViewController(),
            reloadViews: {}
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
        let viewController = UIViewController()
        pills.insertNewReturnValue = nil
        pills.indexOfReturnsValue = 1
        viewModel.goToNewPillDetails(pillsViewController: viewController)
        let callArgs = nav.goToPillDetailsCallArgs
        XCTAssertEqual(0, callArgs.count)
    }

    func testGoToNewPillDetails_navigates() {
        let viewModel = createViewModel()
        let nav = deps.nav as! MockNav
        let pills = deps.sdk?.pills as! MockPillSchedule
        let viewController = UIViewController()
        let newPill = MockPill()
        pills.insertNewReturnValue = newPill
        pills.indexOfReturnsValue = 1
        pills.all = [testPill, newPill]
        viewModel.goToNewPillDetails(pillsViewController: viewController)
        let callArgs = nav.goToPillDetailsCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual(1, callArgs[0].0)
        XCTAssertEqual(viewController, callArgs[0].1)
    }

    func testGoToPillDetails_navigates() {
        let nav = deps.nav as! MockNav
        let viewModel = createViewModel()
        let viewController = UIViewController()
        viewModel.goToPillDetails(pillIndex: 0, pillsViewController: viewController)
        XCTAssertEqual(0, nav.goToPillDetailsCallArgs[0].0)
        XCTAssertEqual(viewController, nav.goToPillDetailsCallArgs[0].1)
    }

    func testGoToPillDetails_whenPillIndexNegative_doesNotNavigates() {
        let nav = deps.nav as! MockNav
        let viewModel = createViewModel()
        let viewController = UIViewController()
        viewModel.goToPillDetails(pillIndex: -1, pillsViewController: viewController)
        XCTAssertEqual(0, nav.goToPillDetailsCallArgs.count)
    }

    func testGoToPillDetails_whenPillIndexGreaterThanCount_doesNotNavigates() {
        let nav = deps.nav as! MockNav
        let viewModel = createViewModel()
        let viewController = UIViewController()
        viewModel.goToPillDetails(pillIndex: 5, pillsViewController: viewController)
        XCTAssertEqual(0, nav.goToPillDetailsCallArgs.count)
    }
}
