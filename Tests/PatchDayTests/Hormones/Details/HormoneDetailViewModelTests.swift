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

    private var dependencies = MockDependencies()
    private static var handlerCallCount = 0
    private let handler: () -> Void = { HormoneDetailViewModelTests.handlerCallCount += 1 }

    @discardableResult
    private func setupHormone() -> MockHormone {
        let hormone = MockHormone()
        dependencies = MockDependencies()
        let schedule = dependencies.sdk?.hormones as! MockHormoneSchedule
        schedule.all = [hormone]
        return hormone
    }

    func testDateSelected_whenHormoneDateIsDefaultAndNoDateSelected_returnsNil() {
        let hormone = setupHormone()
        hormone.date = DateFactory.createDefaultDate()
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        XCTAssertNil(viewModel.dateSelected)
    }

    func testDateSelected_whenDateSelectedFromSelections_returnsSelectedDate() {
        let hormone = setupHormone()
        let viewModel = HormoneDetailViewModel(0, handler)
        viewModel.hormoneId = hormone.id
        let testDate = Date()
        viewModel.selections.date = testDate
        let actual = viewModel.dateSelected
        XCTAssertEqual(testDate, actual)
    }

    func testDateSelected_whenNoDateSelected_usesHormoneDate() {
        let hormone = setupHormone()
        let testDate = Date()
        hormone.date = testDate
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.dateSelected
        XCTAssertEqual(testDate, actual)
    }

    func testDateSelectedText_returnsExpectedDateString() {
        let hormone = setupHormone()
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let testDate = Date()
        viewModel.dateSelected = testDate
        let expected = PDDateFormatter.formatDate(testDate)
        let actual = viewModel.dateSelectedText
        XCTAssertEqual(expected, actual)
    }

    func testDatePickerDate_whenHormoneDateIsDefaultAndNoDateSelected_returnsCurrentDate() {
        let hormone = setupHormone()
        hormone.date = DateFactory.createDefaultDate()
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.datePickerDate
        let expected = Date()
        XCTAssert(PDTest.equiv(expected, actual))
    }

    func testDatePickerDate_whenDateSelectedFromSelections_returnsSelectedDate() {
        let hormone = setupHormone()
        let viewModel = HormoneDetailViewModel(0, handler)
        let testDate = Date()
        viewModel.selections.date = testDate
        viewModel.hormoneId = hormone.id
        let actual = viewModel.datePickerDate
        XCTAssertEqual(testDate, actual)
    }

    func testDatePickerDate_whenNoDateSelected_usesHormoneDate() {
        let hormone = setupHormone()
        let testDate = Date()
        hormone.date = testDate
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.datePickerDate
        XCTAssertEqual(testDate, actual)
    }

    func testSelectDateStartText_returnsExpectedSiteName() {
        let hormone = setupHormone()
        let testSite = "MY SEXY ASS"
        hormone.hasSite = true
        hormone.siteName = testSite
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.selectSiteStartText
        XCTAssertEqual(testSite, actual)
    }

    func testSelectSiteStartText_whenHormoneHasNoSite_returnsSelectString() {
        let hormone = setupHormone()
        hormone.hasSite = false
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.selectSiteStartText
        let expected = ActionStrings.Select
        XCTAssertEqual(expected, actual)
    }

    func testSelectSiteStartText_whenHormonesHasSite_returnsHormoneSiteName() {
        let hormone = setupHormone()
        hormone.hasSite = true
        hormone.siteName = "MY SEXY ASS"
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.selectSiteStartText
        let expected = hormone.siteName
        XCTAssertEqual(expected, actual)
    }

    func testSelectSiteStartText_whenHormoneHasSiteWithEmptyString_returnsNewSiteString() {
        let hormone = setupHormone()
        hormone.hasSite = true
        hormone.siteName = ""
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.selectSiteStartText
        let expected = SiteStrings.NewSite
        XCTAssertEqual(expected, actual)
    }

    func testExpirationDateText_whenNoDateSelected_returnsFormatedDayOfHormoneExpiration() {
        let testDate = Date()
        let hormone = setupHormone()
        let expInt = ExpirationIntervalUD(.TwiceWeekly)
        hormone.date = testDate
        hormone.expirationInterval = expInt
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        viewModel.selections.date = nil

        let expectedDate = DateFactory.createExpirationDate(
            expirationInterval: expInt, to: testDate
        )
        let expected = PDDateFormatter.formatDay(expectedDate!)
        let actual = viewModel.expirationDateText
        XCTAssertEqual(expected, actual)
    }

    func testExpirationDateText_whenHormoneDateIsDefaultAndNoDateSelected_returnsPlaceholder() {
        let hormone = setupHormone()
        let expInt = ExpirationIntervalUD(.TwiceWeekly)
        hormone.date = DateFactory.createDefaultDate()
        hormone.expirationInterval = expInt
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        viewModel.selections.date = nil

        let expected = DotDotDot
        let actual = viewModel.expirationDateText
        XCTAssertEqual(expected, actual)
    }

    func testExpirationDateText_whenDateSelected_returnsFormattedDateSelected() {
        let testDate = Date()
        let hormone = setupHormone()
        let expInt = ExpirationIntervalUD(.TwiceWeekly)
        hormone.date = DateFactory.createDefaultDate()
        hormone.expirationInterval = expInt
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        viewModel.selections.date = testDate

        let expectedDate = DateFactory.createExpirationDate(
            expirationInterval: expInt, to: testDate
        )
        let expected = PDDateFormatter.formatDay(expectedDate!)
        let actual = viewModel.expirationDateText
        XCTAssertEqual(expected, actual)
    }

    func testSiteStartRow_whenSiteIndexSelected_returnsSelectedSiteIndex() {
        let hormone = setupHormone()
        let site = MockSite()
        site.order = 3
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        viewModel.selections.site = site
        let actual = viewModel.siteStartRow
        let expected = site.order
        XCTAssertEqual(expected, actual)
    }

    func testSiteStartRow_whenNoSiteIndexSelectedAndNoSite_returnsZero() {
        let hormone = setupHormone()
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.siteStartRow
        let expected = 0
        XCTAssertEqual(expected, actual)
    }

    func testSiteStartRow_whenNoSiteIndexSelectedAndSiteHasValidOrder_returnsSiteOrder() {
        let site = MockSite()
        site.order = 2
        let hormone = setupHormone()
        hormone.siteId = site.id
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite(), MockSite()]
        sites.subscriptIdReturnValue = site
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.siteStartRow
        let expected = 2
        XCTAssertEqual(expected, actual)
    }

    func testSiteStartRow_whenNoSiteIndexSelectedAndSiteHasOrderOutOfRange_returnsZero() {
        let site = MockSite()
        site.order = 5
        let hormone = setupHormone()
        hormone.siteId = site.id
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite(), MockSite()]
        sites.subscriptIdReturnValue = site
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.siteStartRow
        let expected = 0
        XCTAssertEqual(expected, actual)
    }

    func testSiteStartRow_whenNoSiteIndexSelectedAndSiteHasValidOrder_selectsSite() {
        let site = MockSite()
        site.order = 2
        let hormone = setupHormone()
        hormone.siteId = site.id
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite(), MockSite()]
        sites.subscriptIdReturnValue = site
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        _ = viewModel.siteStartRow

        let expected = site
        let actual = viewModel.selections.site
        XCTAssertEqual(expected.id, actual!.id)
    }

    func testSiteCount_whenSdkNil_returnsZero() {
        dependencies.sdk = nil
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        let expected = 0
        let actual = viewModel.siteCount
        XCTAssertEqual(expected, actual)
    }

    func testSiteCount_returnsCountFromSdk() {
        setupHormone()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite(), MockSite()]
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        let expected = sites.count
        let actual = viewModel.siteCount
        XCTAssertEqual(expected, actual)
    }

    func testAutoPickedExpirationDateText_returnsExpectedFormattedExpirationDate() {
        let hormone = setupHormone()
        let date = Date()
        hormone.createExpirationDateReturnValue = date
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let expected = PDDateFormatter.formatDay(date)
        let actual = viewModel.autoPickedExpirationDateText
        XCTAssertEqual(expected, actual)
    }

    func testAutoPickedExpirationDateText_whenHormoneFailsToCreateDate_returnsPlaceholder() {
        let hormone = setupHormone()
        hormone.createExpirationDateReturnValue = nil
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        let actual = viewModel.autoPickedExpirationDateText
        let expected = DotDotDot
        XCTAssertEqual(expected, actual)
    }

    func testSelectSuggestedSite_selectSite() {
        setupHormone()
        let sites = dependencies.sdk!.sites as! MockSiteSchedule
        let site = MockSite()
        site.name = "Test site"
        sites.suggested = site
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        _ = viewModel.selectSuggestedSite()
        let expected = site.id
        let actual = viewModel.selections.site?.id
        XCTAssertEqual(expected, actual)
    }

    func testSelectSuggestedSite_returnsExpectedSiteName() {
        setupHormone()
        let sites = dependencies.sdk!.sites as! MockSiteSchedule
        let site = MockSite()
        site.name = "Test site"
        sites.suggested = site
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        let actual = viewModel.selectSuggestedSite()
        let expected = site.name
        XCTAssertEqual(expected, actual)
    }

    func testSelectSuggestedSite_whenSiteHasNoName_returnsNewSiteString() {
        setupHormone()
        let sites = dependencies.sdk!.sites as! MockSiteSchedule
        let site = MockSite()
        site.name = ""
        sites.suggested = site
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        let actual = viewModel.selectSuggestedSite()
        let expected = SiteStrings.NewSite
        XCTAssertEqual(expected, actual)
    }

    func testGetSiteName_whenNameNotFound_returnsNil() {
        setupHormone()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.names = ["Name1", "Name2"]
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        XCTAssertNil(viewModel.getSiteName(at: 3))
    }

    func testGetSiteName_returnsExpectedName() {
        let hormone = setupHormone()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.names = ["Name1", "Name2"]
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.getSiteName(at: 1)
        let expected = "Name2"
        XCTAssertEqual(expected, actual)
    }

    func testCreateHormoneViewStrings_createsExpectedStrings() {
        let hormone = setupHormone()
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.createHormoneViewStrings()!
        XCTAssertEqual("Date and time applied: ", actual.dateAndTimePlacedText)
        XCTAssertEqual("Expires: ", actual.expirationText)
        XCTAssertEqual("Site: ", actual.siteLabelText)
    }

    func testTrySelectSite_whenSiteDoesNotExistAtRow_returnsNil() {
        let hormone = setupHormone()
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        XCTAssertNil(viewModel.trySelectSite(at: 54))
    }

    func testTrySelectSite_whenSiteExists_returnsSite() {
        let hormone = setupHormone()
        let site = MockSite()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.subscriptIndexReturnValue = site
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.trySelectSite(at: 3)
        let expected = site.name
        XCTAssertEqual(expected, actual)
    }

    func testTrySelectSite_whenSiteExists_selectsSite() {
        let hormone = setupHormone()
        let site = MockSite()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.subscriptIndexReturnValue = site
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.trySelectSite(at: 3)
        let expected = viewModel.selections.site!.name
        XCTAssertEqual(expected, actual)
    }

    func testTrySelectSite_whenHormoneHasNoDateAndNoneSelected_selectsNow() {
        let hormone = setupHormone()
        hormone.date = DateFactory.createDefaultDate()
        hormone.hasDate = false
        let site = MockSite()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.subscriptIndexReturnValue = site
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        viewModel.trySelectSite(at: 3)
        let actual = viewModel.selections.date!
        XCTAssert(PDTest.equiv(actual, Date()))
    }

    func testTrySelectSite_whenHormoneHasDateAndNoneSelected_doesNotSelectNow() {
        let hormone = setupHormone()
        hormone.date = DateFactory.createDate(daysFromNow: -1)!
        hormone.hasDate = true
        let site = MockSite()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.subscriptIndexReturnValue = site
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.trySelectSite(at: 3)
        XCTAssertNil(viewModel.selections.date)
    }

    func testTrySelectSite_whenHormoneHasDateAndDateIsSelected_doesNotSelectNow() {
        let hormone = setupHormone()
        hormone.date = DateFactory.createDefaultDate()
        hormone.hasDate = false
        let site = MockSite()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.subscriptIndexReturnValue = site
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.selections.date = DateFactory.createDate(daysFromNow: -8)
        viewModel.trySelectSite(at: 3)
        let actual = viewModel.selections.date!
        XCTAssertFalse(PDTest.equiv(actual, Date()))
    }

    func testSaveSelections_whenDateSelected_callsSetHormoneDate() {
        let hormone = setupHormone()
        let date = Date()
        let hormones = dependencies.sdk?.hormones as! MockHormoneSchedule
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        viewModel.selections.date = date
        viewModel.saveSelections()
        let actual = hormones.setDateByIdCallArgs[0]
        let expected = (hormone.id, date)
        XCTAssertEqual(expected.0, actual.0)
        XCTAssertEqual(expected.1, actual.1)
    }

    func testSaveSelections_whenSiteSelected_callsSetHormoneSite() {
        let hormone = setupHormone()
        let site = MockSite()
        let hormones = dependencies.sdk?.hormones as! MockHormoneSchedule
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        viewModel.selections.site = site
        viewModel.saveSelections()
        let actual = hormones.setSiteByIdCallArgs[0]
        let expected = (hormone.id, site)
        XCTAssertEqual(expected.0, actual.0)
        XCTAssertEqual(expected.1.id, actual.1.id)
    }

    func testSaveSelections_reflectsBadge() {
        let hormone = setupHormone()
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        viewModel.saveSelections()
        let actual = (dependencies.badge as! MockBadge).reflectCallCount
        XCTAssertEqual(1, actual)
    }

    func testSaveSelections_requestNotification() {
        let hormone = setupHormone()
        hormone.isPastNotificationTime = false
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let notifications = dependencies.notifications as! MockNotifications
        viewModel.saveSelections()
        let actual = notifications.requestExpiredHormoneNotificationCallArgs[0].id
        let expected = hormone.id
        XCTAssertEqual(expected, actual)
    }

    func testSaveSelections_reflectsTabs() {
        let hormone = setupHormone()
        hormone.isPastNotificationTime = false
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let tabs = dependencies.tabs as! MockTabs
        viewModel.saveSelections()
        let actual = tabs.reflectHormonesCallCount
        let expected = 1
        XCTAssertEqual(expected, actual)
    }

    func testSaveSelections_savesSiteNameIfNoSiteAndHasSiteName() {
        let hormone = setupHormone()
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        viewModel.selections.site = nil
        viewModel.selections.siteName = "TEST"
        viewModel.saveSelections()
        let callArgs = (viewModel.sdk!.hormones as! MockHormoneSchedule).setSiteNameCallArgs[0]
        XCTAssertEqual(hormone.id, callArgs.0)
        XCTAssertEqual(callArgs.1, "TEST")
    }

    func testHandleIfUnsaved_whenNoChanges_stillPops() {
        let hormone = setupHormone()
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let viewController = UIViewController()
        viewModel.handleIfUnsaved(viewController)
        XCTAssertEqual(viewController, (viewModel.nav! as! MockNav).popCallArgs[0])
    }

    func testExtractSiteNameFromTextField_whenTextFieldHasNoText_returnsEmptyString() {
        let hormone = setupHormone()
        let expected = ""
        let textField = UITextField()
        textField.text = nil
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.extractSiteNameFromTextField(textField)
        XCTAssertEqual(expected, actual)
    }

    func testExtractSiteNameFromTextField_whenTextFieldTextIsEmptyString_returnsText() {
        let hormone = setupHormone()
        let text = "Text"
        let expected = text
        let textField = UITextField()
        textField.text = text
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let actual = viewModel.extractSiteNameFromTextField(textField)
        XCTAssertEqual(expected, actual)
    }

    func testPresentNewSiteAlert_whenNewSiteNameIsEmptyString_doesNotPresent() {
        let hormone = setupHormone()
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        let site = ""
        viewModel.presentNewSiteAlert(newSiteName: site)
        let callCount = alertFactory.createNewSiteAlertCallArgs.count
        XCTAssertEqual(0, callCount)
        XCTAssertEqual(0, alertFactory.createNewSiteAlertReturnValue.presentCallCount)
    }

    func testPresentNewSiteAlert_presentsAlertWithHandlerThatWhenCalledInsertsNewSite() {
        let hormone = setupHormone()
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        let site = "Right Thigh"
        viewModel.presentNewSiteAlert(newSiteName: site)
        viewModel.hormoneId = hormone.id
        let handlers = alertFactory.createNewSiteAlertCallArgs[0]
        handlers.handleNewSite()
        let actual = (dependencies.sdk?.sites as! MockSiteSchedule).insertNewCallArgs[0]
        XCTAssertEqual(site, actual.0)
    }

    func testPresentNewSiteAlert_presentsAlertWithHandlerWithClosureThatCallsUpdateViewsHandler() {
        let hormone = setupHormone()
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        let site = "Right Thigh"
        viewModel.presentNewSiteAlert(newSiteName: site)
        viewModel.hormoneId = hormone.id
        let handlers = alertFactory.createNewSiteAlertCallArgs[0]
        handlers.handleNewSite()
        let closure = (dependencies.sdk?.sites as! MockSiteSchedule).insertNewCallArgs[0].1
        closure!()
        XCTAssertEqual(1, HormoneDetailViewModelTests.handlerCallCount)
    }

    func testPresentNewSiteAlert_presentsAlertWithHandlerWithClosureThatSelectsNewSiteFromInsert() {
        let hormone = setupHormone()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        let site = MockSite()
        sites.insertNewReturnValue = site
        let alertFactory = MockAlertFactory()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        viewModel.hormoneId = hormone.id
        viewModel.presentNewSiteAlert(newSiteName: "Test")
        let handlers = alertFactory.createNewSiteAlertCallArgs[0]
        handlers.handleNewSite()
        let expected = site.id
        let actual = viewModel.selections.site?.id
        XCTAssertEqual(expected, actual)
    }
}
