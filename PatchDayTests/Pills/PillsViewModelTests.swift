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

	private func createViewModel() -> PillsViewModel {
		let alertFactory = MockAlertFactory()
		let deps = MockDependencies()
		(deps.sdk?.pills as! MockPillSchedule).all = [MockPill()]
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
}
