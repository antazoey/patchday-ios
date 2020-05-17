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

	func testDatePickerDate_whenHormoneDateIsDefaultAndNoDateSelected_returnsCurrentDate() {
		let hormone = MockHormone()
		hormone.date = DateFactory.createDefaultDate()
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.datePickerDate
		let expected = Date()
		XCTAssert(PDTest.equiv(expected, actual))
	}
	
	func testDatePickerDate_whenDateSelectedFromSelections_returnsSelectedDate() {
		let hormone = MockHormone()
		let viewModel = HormoneDetailViewModel(hormone, handler)
		let testDate = Date()
		viewModel.selections.date = testDate
		let actual = viewModel.datePickerDate
		XCTAssertEqual(testDate, actual)
	}

	func testDatePickerDate_whenNoDateSelected_usesHormoneDate() {
		let hormone = MockHormone()
		let testDate = Date()
		hormone.date = testDate
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.datePickerDate
		XCTAssertEqual(testDate, actual)
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
	
	func testSelectDateButtonStartText_returnsExpectedSiteName() {
		let hormone = MockHormone()
		let testSite = "MY SEXY ASS"
		hormone.hasSite = true
		hormone.siteName = testSite
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.selectSiteTextFieldStartText
		XCTAssertEqual(testSite, actual)
	}
	
	func testSelectSiteTextFieldStartText_whenHormoneHasNoSite_returnsSelectString() {
		let hormone = MockHormone()
		hormone.hasSite = false
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.selectSiteTextFieldStartText
		let expected = ActionStrings.Select
		XCTAssertEqual(expected, actual)
	}
	
	func testSelectSiteTextFieldStartText_whenHormonesHasSite_returnsHormoneSiteName() {
		let hormone = MockHormone()
		hormone.hasSite = true
		hormone.siteName = "MY SEXY ASS"
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.selectSiteTextFieldStartText
		let expected = hormone.siteName
		XCTAssertEqual(expected, actual)
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
	
	func testHormoneIndex_whenGivenValidIndex_returnsIndexOfHormone() {
		let hormone = MockHormone()
		let schedule = dependencies.sdk?.hormones as! MockHormoneSchedule
		schedule.indexOfReturnValue = 1
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.hormoneIndex
		let expected = 1
		XCTAssertEqual(expected, actual)
	}
	
	func testHormoneIndex_whenNotGivenInvalidIndex_returnsNegativeOne() {
		let hormone = MockHormone()
		let schedule = dependencies.sdk?.hormones as! MockHormoneSchedule
		schedule.indexOfReturnValue = nil
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.hormoneIndex
		let expected = -1
		XCTAssertEqual(expected, actual)
	}
	
	func testSiteStartRow_whenSiteIndexSelected_returnsSelectedSiteIndex() {
		let hormone = MockHormone()
		let site = MockSite()
		site.order = 3
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		viewModel.selections.site = site
		let actual = viewModel.siteStartRow
		let expected = site.order
		XCTAssertEqual(expected, actual)
	}
	
	func testSiteStartRow_whenNoSiteIndexSelectedAndNoSite_returnsZero() {
		let hormone = MockHormone()
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.siteStartRow
		let expected = 0
		XCTAssertEqual(expected, actual)
	}
	
	func testSiteStartRow_whenNoSiteIndexSelectedAndSiteHasValidOrder_returnsSiteOrder() {
		let site = MockSite()
		site.order = 2
		let hormone = MockHormone()
		hormone.siteId = site.id
		let sites = dependencies.sdk?.sites as! MockSiteSchedule
		sites.count = 4
		sites.subscriptIdReturnValue = site
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.siteStartRow
		let expected = 2
		XCTAssertEqual(expected, actual)
	}
	
	func testSiteStartRow_whenNoSiteIndexSelectedAndSiteHasOrderOutOfRange_returnsZero() {
		let site = MockSite()
		site.order = 5
		let hormone = MockHormone()
		hormone.siteId = site.id
		let sites = dependencies.sdk?.sites as! MockSiteSchedule
		sites.count = 4
		sites.subscriptIdReturnValue = site
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.siteStartRow
		let expected = 0
		XCTAssertEqual(expected, actual)
	}
	
	func testSiteStartRow_whenNoSiteIndexSelectedAndSiteHasValidOrder_selectsSite() {
		let site = MockSite()
		site.order = 2
		let hormone = MockHormone()
		hormone.siteId = site.id
		let sites = dependencies.sdk?.sites as! MockSiteSchedule
		sites.count = 4
		sites.subscriptIdReturnValue = site
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		_ = viewModel.siteStartRow
		
		let expected = site
		let actual = viewModel.selections.site
		XCTAssertEqual(expected.id, actual!.id)
	}
	
	func testSiteCount_whenSdkNil_returnsZero() {
		dependencies.sdk = nil
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		let expected = 0
		let actual = viewModel.siteCount
		XCTAssertEqual(expected, actual)
	}
	
	func testSiteCount_returnsCountFromSdk() {
		let sites = dependencies.sdk?.sites as! MockSiteSchedule
		sites.count = 11
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		let expected = sites.count
		let actual = viewModel.siteCount
		XCTAssertEqual(expected, actual)
	}
	
	func testAutoPickedDateText_returnsFormattedNow() {
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		let actual = viewModel.autoPickedDateText
		let expected = PDDateFormatter.formatDate(Date())
		XCTAssertEqual(expected, actual)
	}
	
	func testAutoPickedDateText_selectsNowAsDate() {
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		_ = viewModel.autoPickedDateText
		let actual = viewModel.selections.date!
		let expected = Date()
		XCTAssert(PDTest.equiv(expected, actual))
	}
	
	func testAutoPickedExpirationDateText_returnsExpectedFormattedExpirationDate() {
		let hormone = MockHormone()
		let date = Date()
		hormone.createExpirationDateReturnValue = date
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let expected = PDDateFormatter.formatDay(date)
		let actual = viewModel.autoPickedExpirationDateText
		XCTAssertEqual(expected, actual)
	}
	
	func testAutoPickedExpirationDateText_whenHormoneFailsToCreateDate_returnsPlaceholder() {
		let hormone = MockHormone()
		hormone.createExpirationDateReturnValue = nil
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.autoPickedExpirationDateText
		let expected = DotDotDot
		XCTAssertEqual(expected, actual)
	}
	
	func testGetSiteName_whenNameNotFound_returnsNil() {
		let sites = dependencies.sdk?.sites as! MockSiteSchedule
		sites.names = ["Name1", "Name2"]
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		XCTAssertNil(viewModel.getSiteName(at: 3))
	}
	
	func testGetSiteName_returnsExpectedName() {
		let sites = dependencies.sdk?.sites as! MockSiteSchedule
		sites.names = ["Name1", "Name2"]
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		let actual = viewModel.getSiteName(at: 1)
		let expected = "Name2"
		XCTAssertEqual(expected, actual)
	}
	
	func testCreateHormoneViewStrings_createsExpectedStrings() {
		let hormone = MockHormone()
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let actual = viewModel.createHormoneViewStrings()
		XCTAssertEqual("Date and time applied: ", actual.dateAndTimePlacedText)
		XCTAssertEqual("Expires: ", actual.expirationText)
		XCTAssertEqual("Site: ", actual.siteLabelText)
	}
	
	func testTrySelectSite_whenSiteDoesNotExistAtRow_returnsNil() {
		let hormone = MockHormone()
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		XCTAssertNil(viewModel.trySelectSite(at: 54))
	}
	
	func testTrySelectSite_whenSiteExists_returnsSite() {
		let site = MockSite()
		let sites = dependencies.sdk?.sites as! MockSiteSchedule
		sites.subscriptIndexReturnValue = site
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		let actual = viewModel.trySelectSite(at: 3)
		let expected = site.name
		XCTAssertEqual(actual, expected)
	}
	
	func testTrySelectSite_whenSiteExists_selectsSite() {
		let site = MockSite()
		let sites = dependencies.sdk?.sites as! MockSiteSchedule
		sites.subscriptIndexReturnValue = site
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		let actual = viewModel.trySelectSite(at: 3)
		let expected = viewModel.selections.site!.name
		XCTAssertEqual(actual, expected)
	}
	
	func testSaveSelections_whenDateSelected_callsSetHormoneDate() {
		let hormone = MockHormone()
		let date = Date()
		let hormones = dependencies.sdk?.hormones as! MockHormoneSchedule
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		viewModel.selections.date = date
		viewModel.saveSelections()
		let actual = hormones.setDateByIdCallArgs[0]
		let expected = (hormone.id, date)
		XCTAssertEqual(expected.0, actual.0)
		XCTAssertEqual(expected.1, actual.1)
	}
	
	func testSaveSelections_whenSiteSelected_callsSetHormoneSite() {
		let hormone = MockHormone()
		let site = MockSite()
		let hormones = dependencies.sdk?.hormones as! MockHormoneSchedule
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		viewModel.selections.site = site
		viewModel.saveSelections()
		let actual = hormones.setSiteByIdCallArgs[0]
		let expected = (hormone.id, site)
		XCTAssertEqual(expected.0, actual.0)
		XCTAssertEqual(expected.1.id, actual.1.id)
	}
	
	func testSaveSelections_whenSiteSelectedAndSiteIsSuggested_incrementsSiteIndex() {
		let hormone = MockHormone()
		let site = MockSite()
		let hormones = dependencies.sdk?.hormones as! MockHormoneSchedule
		let sites = dependencies.sdk?.sites as! MockSiteSchedule
		sites.suggested = site
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		viewModel.selections.site = site
		viewModel.saveSelections()
		let didIncrement = hormones.setSiteByIdCallArgs[0].2
		XCTAssert(didIncrement)
	}
	
	func testSaveSelections_whenSiteSelectedAndSiteIsNotSuggested_doesNotIncrementSiteIndex() {
		let hormone = MockHormone()
		let site = MockSite()
		let hormones = dependencies.sdk?.hormones as! MockHormoneSchedule
		let sites = dependencies.sdk?.sites as! MockSiteSchedule
		sites.suggested = MockSite()
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		viewModel.selections.site = site
		viewModel.saveSelections()
		let didIncrement = hormones.setSiteByIdCallArgs[0].2
		XCTAssertFalse(didIncrement)
	}
	
	func testSaveSelections_reflectsBadge() {
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		viewModel.saveSelections()
		let actual = (dependencies.badge as! MockBadge).reflectCallCount
		XCTAssertEqual(1, actual)
	}
	
	func testSaveSelections_requestNotification() {
		let hormone = MockHormone()
		hormone.isPastNotificationTime = false
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let notifications = dependencies.notifications as! MockNotifications
		viewModel.saveSelections()
		let actual = notifications.requestExpiredHormoneNotificationCallArgs[0].id
		let expected = hormone.id
		XCTAssertEqual(expected, actual)
	}
	
	func testSaveSelections_reflectsTabs() {
		let hormone = MockHormone()
		hormone.isPastNotificationTime = false
		let viewModel = HormoneDetailViewModel(hormone, handler, dependencies)
		let tabs = dependencies.tabs as! MockTabs
		viewModel.saveSelections()
		let actual = tabs.reflectHormoneCharacteristicsCount
		let expected = 1
		XCTAssertEqual(expected, actual)
	}
	
	func testExtractSiteNameFromTextField_whenTextFieldHasNoText_returnsNewSite() {
		let expected = SiteStrings.NewSite
		let textField = UITextField()
		textField.text = nil
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		let actual = viewModel.extractSiteNameFromTextField(textField)
		XCTAssertEqual(expected, actual)
	}
	
	func testExtractSiteNameFromTextField_whenTextFieldTextIsEmptyString_returnsNewSite() {
		let expected = SiteStrings.NewSite
		let textField = UITextField()
		textField.text = ""
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		let actual = viewModel.extractSiteNameFromTextField(textField)
		XCTAssertEqual(expected, actual)
	}
	
	func testExtractSiteNameFromTextField_whenTextFieldTextIsEmptyString_returnsText() {
		let text = "Text"
		let expected = text
		let textField = UITextField()
		textField.text = text
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		let actual = viewModel.extractSiteNameFromTextField(textField)
		XCTAssertEqual(expected, actual)
	}
	
	func testPresentNewSiteAlert_presentsAlertWithHandlerThatWhenCalledInsertsNewSite() {
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		let site = "Right Thigh"
		viewModel.presentNewSiteAlert(newSiteName: site)
		let handlers = (dependencies.alerts as! MockAlerts).presentNewSiteAlertCallArgs[0]
		handlers.handleNewSite()
		let actual = (dependencies.sdk?.sites as! MockSiteSchedule).insertNewCallArgs[0]
		XCTAssertEqual(site, actual.0)
		XCTAssert(actual.1)
	}
	
	func testPresentNewSiteAlert_presentsAlertWithHandlerWithClosureThatCallsUpdateViewsHandler() {
		let viewModel = HormoneDetailViewModel(MockHormone(), handler, dependencies)
		let site = "Right Thigh"
		viewModel.presentNewSiteAlert(newSiteName: site)
		let handlers = (dependencies.alerts as! MockAlerts).presentNewSiteAlertCallArgs[0]
		handlers.handleNewSite()
		let closure = (dependencies.sdk?.sites as! MockSiteSchedule).insertNewCallArgs[0].2
		closure!()
		XCTAssertEqual(1, HormoneDetailViewModelTests.handlerCallCount)
	}
}
