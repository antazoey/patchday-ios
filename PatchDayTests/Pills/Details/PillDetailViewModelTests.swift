//
//  PillDetailsTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/30/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class PillDetailViewModelTests: XCTestCase {

	private var dependencies: MockDependencies! = nil

	@discardableResult
	private func setupPill() -> MockPill {
		let pill = MockPill()
		dependencies = MockDependencies()
		let schedule = dependencies.sdk?.pills as! MockPillSchedule
		schedule.all = [pill]
		return pill
	}

	func testIsNewPill_whenNameIsNewPill_returnsTrue() {
		let pill = setupPill()
		pill.name = PillStrings.NewPill
		let viewModel = PillDetailViewModel(0, dependencies: dependencies)
		XCTAssertTrue(viewModel.isNewPill)
	}

	func testIsNewPill_whenNameIsNotNewPill_returnsFalse() {
		let pill = setupPill()
		pill.name = "Spiro"
		let viewModel = PillDetailViewModel(0, dependencies: dependencies)
		XCTAssertFalse(viewModel.isNewPill)
	}
}
