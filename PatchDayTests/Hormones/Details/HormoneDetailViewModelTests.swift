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

	private let dependencies = MockDependencies()
	private static var handlerCallCount = 0
	private let handler: () -> Void = { HormoneDetailViewModelTests.handlerCallCount += 1 }

	func testDatePickerDate_whenDateIsNil_returnsCurrentDate() {
		let hormone = MockHormone()
		hormone.date = DateFactory.createDefaultDate()
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		XCTAssert(Date().timeIntervalSince(viewModel.datePickerDate) < 0.01)
	}
	
	func testDateSelected_whenHormoneDateIsDefaultAndNoDateSelected_returnsNil() {
		let hormone = MockHormone()
		hormone.date = DateFactory.createDefaultDate()
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		XCTAssertNil(viewModel.dateSelected)
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
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.dateSelected
		XCTAssertEqual(testDate, actual)
	}
	
	func testDateSelectedText_returnsExpectedDateString() {
		let hormone = MockHormone()
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let testDate = Date()
		viewModel.dateSelected = testDate
		let expected = PDDateFormatter.formatDate(testDate)
		let actual = viewModel.dateSelectedText
		XCTAssertEqual(expected, actual)
	}
	
	func testSelectDateButtonStartText_whenHormoneHasNoDate_returnsSelectString() {
		let hormone = MockHormone()
		hormone.hasDate = false
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.selectDateButtonStartText
		let expected = ActionStrings.Select
		XCTAssertEqual(expected, actual)
	}
	
	func testSelectDateButtonStartText_returnsFormattedHormoneDate() {
		let testDate = Date()
		let hormone = MockHormone()
		hormone.hasDate = true
		hormone.date = testDate
		let expected = PDDateFormatter.formatDate(testDate)
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.selectDateButtonStartText
		XCTAssertEqual(expected, actual)
	}
	
	func testSelectSiteTextFieldStartText_whenHormoneHasNoSite_returnsSelectString() {
		let hormone = MockHormone()
		hormone.hasSite = false
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.selectSiteTextFieldStartText
		let expected = ActionStrings.Select
		XCTAssertEqual(expected, actual)
	}
	
	func testSelectDateButtonStartText_returnsExpectedSiteName() {
		let hormone = MockHormone()
		let testSite = "MY SEXY ASS"
		hormone.hasSite = true
		hormone.siteName = testSite
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.selectSiteTextFieldStartText
		XCTAssertEqual(testSite, actual)
	}
	
	func testExpirationDateText_whenNoDateSelected_returnsFormatedDayOfHormoneExpiration() {
		let testDate = Date()
		let hormone = MockHormone()
		let expInt = ExpirationIntervalUD(.TwiceWeekly)
		hormone.date = testDate
		hormone.expirationInterval = expInt
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		viewModel.selections.date = nil
		
		let expectedDate = DateFactory.createExpirationDate(
			expirationInterval: expInt, to: testDate
		)
		let expected = PDDateFormatter.formatDay(expectedDate!)
		let actual = viewModel.expirationDateText
		XCTAssertEqual(expected, actual)
	}
	
	func testExpirationDateText_whenHormoneDateIsDefaultAndNoDateSelected_returnsPlaceholder() {
		let hormone = MockHormone()
		let expInt = ExpirationIntervalUD(.TwiceWeekly)
		hormone.date = DateFactory.createDefaultDate()
		hormone.expirationInterval = expInt
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		viewModel.selections.date = nil
		
		let expected = DotDotDot
		let actual = viewModel.expirationDateText
		XCTAssertEqual(expected, actual)
	}
	
	func testExpirationDateText_whenDateSelected_returnsFormattedDateSelected() {
		let testDate = Date()
		let hormone = MockHormone()
		let expInt = ExpirationIntervalUD(.TwiceWeekly)
		hormone.date = DateFactory.createDefaultDate()
		hormone.expirationInterval = expInt
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		viewModel.selections.date = testDate
		
		let expectedDate = DateFactory.createExpirationDate(
			expirationInterval: expInt, to: testDate
		)
		let expected = PDDateFormatter.formatDay(expectedDate!)
		let actual = viewModel.expirationDateText
		XCTAssertEqual(expected, actual)
	}
}
