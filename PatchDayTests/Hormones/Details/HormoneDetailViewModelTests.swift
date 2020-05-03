//
//  HormoneDetailViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/2/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class HormoneDetailViewModelTests: XCTestCase {

	private static var handlerCallCount = 0
	private let handler: () -> Void = { HormoneDetailViewModelTests.handlerCallCount += 1 }

	func testDateSelected_whenDateIsDefault_returnsCurrentDate() {
		let hormone = MockHormone()
		hormone.date = DateFactory.createDefaultDate()
		let viewModel = HormoneDetailViewModel(hormone, handler)
		XCTAssert(Date().timeIntervalSince(viewModel.dateSelected) < 0.01)
	}

	func testDateSelected_whenDateSelectedFromSelections_returnsSelectedDate() {
		let hormone = MockHormone()
		let viewModel = HormoneDetailViewModel(hormone, handler)
		let testDate = Date()
		viewModel.selections.date = testDate
		let actual = viewModel.dateSelected
		XCTAssertEqual(testDate, actual)
	}

	func testDateSelected_whenNoDateSelected_usesHormoneDate() {
		let hormone = MockHormone()
		let testDate = Date()
		hormone.date = testDate
		let viewModel = HormoneDetailViewModel(hormone, handler)
		let actual = viewModel.dateSelected
		XCTAssertEqual(testDate, actual)
	}
}
