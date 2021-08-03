//
//  HormoneDetailViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/2/20.

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class HormoneDetailViewModelTests: XCTestCase {

    private var dependencies: MockDependencies!
    private var alertFactory: MockAlertFactory!
    private var viewModel: HormoneDetailViewModel!
    private static var handlerCallCount = 0
    private let handler: () -> Void = { HormoneDetailViewModelTests.handlerCallCount += 1 }
    private var now: PDNow!
    private var hormone: MockHormone!

    override func setUp() {
        dependencies = MockDependencies()
        alertFactory = MockAlertFactory()
        now = PDNow()
        viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies, now)
        hormone = setupHormone()
        viewModel.hormoneId = hormone.id
    }

    @discardableResult
    private func setupHormone() -> MockHormone {
        let hormone = MockHormone()
        let schedule = dependencies.sdk?.hormones as! MockHormoneSchedule
        schedule.all = [hormone]
        return hormone
    }

    func testHormone_returnsExpectedHormone() {
        guard let actual = viewModel.hormone else {
            XCTFail("Hormone was nil")
            return
        }
        XCTAssertEqual(hormone.id, actual.id)
    }

    func testDateSelected_whenHormoneDateIsDefaultAndNoDateSelected_returnsNil() {
        let hormone = setupHormone()
        hormone.date = DateFactory.createDefaultDate()
        XCTAssertNil(viewModel.dateSelected)
    }

    func testDateSelected_whenDateSelectedFromSelections_returnsSelectedDate() {
        let testDate = Date()
        viewModel.selections.date = testDate
        let actual = viewModel.dateSelected
        XCTAssertEqual(testDate, actual)
    }

    func testDateSelected_whenNoDateSelected_usesHormoneDate() {
        let testDate = Date()
        hormone.date = testDate
        let actual = viewModel.dateSelected
        XCTAssertEqual(testDate, actual)
    }

    func testDateSelectedText_returnsExpectedDateString() {
        let testDate = Date()
        viewModel.dateSelected = testDate
        let expected = PDDateFormatter.formatDate(testDate)
        let actual = viewModel.dateSelectedText
        XCTAssertEqual(expected, actual)
    }

    func testDatePickerDate_whenHormoneDateIsDefaultAndNoDateSelected_returnsCurrentDate() {
        hormone.date = DateFactory.createDefaultDate()
        let actual = viewModel.datePickerDate
        PDAssertNow(actual)
    }

    func testDatePickerDate_whenDateSelectedFromSelections_returnsSelectedDate() {
        let testDate = Date()
        viewModel.selections.date = testDate
        let actual = viewModel.datePickerDate
        XCTAssertEqual(testDate, actual)
    }

    func testDatePickerDate_whenNoDateSelected_usesHormoneDate() {
        let testDate = Date()
        hormone.date = testDate
        let actual = viewModel.datePickerDate
        XCTAssertEqual(testDate, actual)
    }

    func testSelectSiteStartText_returnsExpectedSiteName() {
        let testSite = "MY SEXY ASS"
        hormone.hasSite = true
        hormone.siteName = testSite
        let actual = viewModel.selectSiteStartText
        XCTAssertEqual(testSite, actual)
    }

    func testSelectSiteStartText_whenHormoneHasNoSite_returnsSelectString() {
        hormone.hasSite = false
        let actual = viewModel.selectSiteStartText
        let expected = ActionStrings.Select
        XCTAssertEqual(expected, actual)
    }

    func testSelectSiteStartText_whenHormonesHasSite_returnsHormoneSiteName() {
        hormone.hasSite = true
        hormone.siteName = "MY SEXY ASS"
        let actual = viewModel.selectSiteStartText
        let expected = hormone.siteName
        XCTAssertEqual(expected, actual)
    }

    func testSelectSiteStartText_whenHormoneHasSiteWithEmptyString_returnsNewSiteString() {
        hormone.hasSite = true
        hormone.siteName = ""
        let actual = viewModel.selectSiteStartText
        let expected = SiteStrings.NewSite
        XCTAssertEqual(expected, actual)
    }

    func testExpirationDateText_whenNoDateSelected_returnsFormatedDayOfHormoneExpiration() {
        let testDate = Date()
        let expInt = ExpirationIntervalUD(.TwiceWeekly)
        hormone.date = testDate
        hormone.expirationInterval = expInt
        viewModel.selections.date = nil

        let expectedDate = DateFactory.createExpirationDate(
            expirationInterval: expInt, to: testDate
        )
        let expected = PDDateFormatter.formatDay(expectedDate!)
        let actual = viewModel.expirationDateText
        XCTAssertEqual(expected, actual)
    }

    func testExpirationDateText_whenHormoneDateIsDefaultAndNoDateSelected_returnsPlaceholder() {
        let expInt = ExpirationIntervalUD(.TwiceWeekly)
        hormone.date = DateFactory.createDefaultDate()
        hormone.expirationInterval = expInt
        viewModel.selections.date = nil

        let expected = PlaceholderStrings.DotDotDot
        let actual = viewModel.expirationDateText
        XCTAssertEqual(expected, actual)
    }

    func testExpirationDateText_whenDateSelected_returnsFormattedDateSelected() {
        let testDate = Date()
        let expInt = ExpirationIntervalUD(.TwiceWeekly)
        hormone.date = DateFactory.createDefaultDate()
        hormone.expirationInterval = expInt
        viewModel.selections.date = testDate

        let expectedDate = DateFactory.createExpirationDate(
            expirationInterval: expInt, to: testDate
        )
        let expected = PDDateFormatter.formatDay(expectedDate!)
        let actual = viewModel.expirationDateText
        XCTAssertEqual(expected, actual)
    }

    func testExpirationDateText_whenDateMoreThanSevenDaysAway_returnsExpectedDateString() {
        let testDate = DateFactory.createDate(byAddingMonths: 3, to: Date())!
        let expInt = ExpirationIntervalUD(.TwiceWeekly)
        hormone.date = DateFactory.createDefaultDate()
        hormone.expirationInterval = expInt
        viewModel.selections.date = testDate

        let expectedDate = DateFactory.createExpirationDate(
            expirationInterval: expInt, to: testDate
        )
        let expected = PDDateFormatter.formatDate(expectedDate!)
        let actual = viewModel.expirationDateText
        XCTAssertEqual(expected, actual)
    }

    func testSiteStartRow_whenSiteIndexSelected_returnsSelectedSiteIndex() {
        let site = MockSite()
        site.order = 3
        viewModel.selections.site = site
        let actual = viewModel.siteStartRow
        let expected = site.order
        XCTAssertEqual(expected, actual)
    }

    func testSiteStartRow_whenNoSiteIndexSelectedAndNoSite_returnsZero() {
        let actual = viewModel.siteStartRow
        let expected = 0
        XCTAssertEqual(expected, actual)
    }

    func testSiteStartRow_whenNoSiteIndexSelectedAndSiteHasValidOrder_returnsSiteOrder() {
        let site = MockSite()
        site.order = 2
        hormone.siteId = site.id
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite(), MockSite()]
        sites.subscriptIdReturnValue = site
        let actual = viewModel.siteStartRow
        let expected = 2
        XCTAssertEqual(expected, actual)
    }

    func testSiteStartRow_whenNoSiteIndexSelectedAndSiteHasOrderGreaterThanCount_returnsZero() {
        let site = MockSite()
        site.order = 5
        hormone.siteId = site.id
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite(), MockSite()]
        sites.subscriptIdReturnValue = site
        let actual = viewModel.siteStartRow
        let expected = 0
        XCTAssertEqual(expected, actual)
    }

    func testSiteStartRow_whenNoSiteIndexSelectedAndSiteHasNegativeIndex_returnsZero() {
        let site = MockSite()
        site.order = -1
        hormone.siteId = site.id
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite(), MockSite()]
        sites.subscriptIdReturnValue = site
        let actual = viewModel.siteStartRow
        let expected = 0
        XCTAssertEqual(expected, actual)
    }

    func testSiteStartRow_whenNoSiteIndexSelectedAndSiteHasValidOrder_selectsSite() {
        let site = MockSite()
        site.order = 2
        hormone.siteId = site.id
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite(), MockSite()]
        sites.subscriptIdReturnValue = site
        _ = viewModel.siteStartRow

        let expected = site
        let actual = viewModel.selections.site
        XCTAssertEqual(expected.id, actual!.id)
    }

    func testSiteCount_whenSdkNil_returnsZero() {
        dependencies.sdk = nil
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies)
        let expected = 0
        let actual = viewModel.siteCount
        XCTAssertEqual(expected, actual)
    }

    func testSiteCount_returnsCountFromSdk() {
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite(), MockSite()]
        let actual = viewModel.siteCount
        XCTAssertEqual(4, actual)
    }

    func testAutoPickedDate_whenUsingStaticExpirationTimes_returnsExpectedDate() {
        let hormones = dependencies.sdk?.hormones as! MockHormoneSchedule
        hormones.useStaticExpirationTime = true
        let testDate = TestDateFactory.createTestDate(hoursFrom: -40)
        hormone.expiration = testDate
        let actual = viewModel.autoPickedDate
        let expected = TestDateFactory.createTestDate(at: testDate)
        PDAssertEquiv(expected, actual)
    }

    func testAutoPickedDate_whenUsingDynamicExpirationTimes_returnsExpectedDate() {
        let hormones = dependencies.sdk?.hormones as! MockHormoneSchedule
        hormones.useStaticExpirationTime = false
        let testDate = TestDateFactory.createTestDate(hoursFrom: -2)
        hormone.expiration = testDate
        let now = PDNow()
        let viewModel = HormoneDetailViewModel(0, handler, alertFactory, dependencies, now)
        let actual = viewModel.autoPickedDate
        let expected = now.now
        PDAssertEquiv(expected, actual)
    }

    func testAutoPickedExpirationDateText_returnsExpectedFormattedExpirationDate() {
        let date = Date()
        hormone.createExpirationDateReturnValue = date
        let expected = PDDateFormatter.formatDay(date)
        let actual = viewModel.autoPickedExpirationDateText
        XCTAssertEqual(expected, actual)
    }

    func testAutoPickedExpirationDateText_whenHormoneFailsToCreateDate_returnsPlaceholder() {
        hormone.createExpirationDateReturnValue = nil
        let actual = viewModel.autoPickedExpirationDateText
        let expected = PlaceholderStrings.DotDotDot
        XCTAssertEqual(expected, actual)
    }

    func testSelectSuggestedSite_selectSite() {
        let sites = dependencies.sdk!.sites as! MockSiteSchedule
        let site = MockSite()
        site.name = "Test site"
        sites.suggested = site
        _ = viewModel.selectSuggestedSite()
        let expected = site.id
        let actual = viewModel.selections.site?.id
        XCTAssertEqual(expected, actual)
    }

    func testSelectSuggestedSite_returnsExpectedSiteName() {
        let sites = dependencies.sdk!.sites as! MockSiteSchedule
        let site = MockSite()
        site.name = "Test site"
        sites.suggested = site
        let actual = viewModel.selectSuggestedSite()
        let expected = site.name
        XCTAssertEqual(expected, actual)
    }

    func testSelectSuggestedSite_whenSiteHasNoName_returnsNewSiteString() {
        let sites = dependencies.sdk!.sites as! MockSiteSchedule
        let site = MockSite()
        site.name = ""
        sites.suggested = site
        let actual = viewModel.selectSuggestedSite()
        let expected = SiteStrings.NewSite
        XCTAssertEqual(expected, actual)
    }

    func testGetSiteName_whenNameNotFound_returnsNil() {
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.names = ["Name1", "Name2"]
        XCTAssertNil(viewModel.getSiteName(at: 3))
    }

    func testGetSiteName_returnsExpectedName() {
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.names = ["Name1", "Name2"]
        let actual = viewModel.getSiteName(at: 1)
        let expected = "Name2"
        XCTAssertEqual(expected, actual)
    }

    func testCreateHormoneViewStrings_createsExpectedStrings() {
        let actual = viewModel.createHormoneViewStrings()!
        XCTAssertEqual("Application date and time: ", actual.dateAndTimePlacedText)
        XCTAssertEqual("Exp:", actual.expirationText)
        XCTAssertEqual("Site: ", actual.siteLabelText)
    }

    func testTrySelectSite_whenSiteDoesNotExistAtRow_returnsNil() {
        XCTAssertNil(viewModel.trySelectSite(at: 54))
    }

    func testTrySelectSite_whenSiteExists_returnsSite() {
        let site = MockSite()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.subscriptIndexReturnValue = site
        let actual = viewModel.trySelectSite(at: 3)
        let expected = site.name
        XCTAssertEqual(expected, actual)
    }

    func testTrySelectSite_whenSiteExists_selectsSite() {
        let site = MockSite()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.subscriptIndexReturnValue = site
        let actual = viewModel.trySelectSite(at: 3)
        let expected = viewModel.selections.site!.name
        XCTAssertEqual(expected, actual)
    }

    func testTrySelectSite_whenHormoneHasNoDateAndNoneSelected_selectsNow() {
        hormone.date = DateFactory.createDefaultDate()
        hormone.hasDate = false
        let site = MockSite()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.subscriptIndexReturnValue = site
        viewModel.trySelectSite(at: 3)
        guard let actual = viewModel.selections.date else {
            XCTFail("There is no date selected")
            return
        }
        PDAssertNow(actual)
    }

    func testTrySelectSite_whenHormoneHasDateAndNoneSelected_doesNotSelectNow() {
        hormone.date = DateFactory.createDate(daysFrom: -1)!
        hormone.hasDate = true
        let site = MockSite()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.subscriptIndexReturnValue = site
        viewModel.trySelectSite(at: 3)
        XCTAssertNil(viewModel.selections.date)
    }

    func testTrySelectSite_whenHormoneHasDateAndDateIsSelected_doesNotSelectNow() {
        hormone.date = DateFactory.createDefaultDate()
        hormone.hasDate = false
        let site = MockSite()
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        sites.subscriptIndexReturnValue = site
        viewModel.selections.date = DateFactory.createDate(daysFrom: -8)
        viewModel.trySelectSite(at: 3)
        let actual = viewModel.selections.date!
        PDAssertNotNow(actual)
    }

    func testSaveSelections_whenDateSelected_callsSetHormoneDate() {
        let date = Date()
        let hormones = dependencies.sdk?.hormones as! MockHormoneSchedule
        viewModel.selections.date = date
        viewModel.saveSelections()
        let actual = hormones.setDateByIdCallArgs[0]
        let expected = (hormone.id, date)
        XCTAssertEqual(expected.0, actual.0)
        XCTAssertEqual(expected.1, actual.1)
    }

    func testSaveSelections_whenSiteSelected_callsSetHormoneSite() {
        let site = MockSite()
        let hormones = dependencies.sdk?.hormones as! MockHormoneSchedule
        viewModel.selections.site = site
        viewModel.saveSelections()
        let actual = hormones.setSiteByIdCallArgs[0]
        let expected = (hormone.id, site)
        XCTAssertEqual(expected.0, actual.0)
        XCTAssertEqual(expected.1.id, actual.1.id)
    }

    func testSaveSelections_reflectsBadge() {
        viewModel.saveSelections()
        let actual = (dependencies.badge as! MockBadge).reflectCallCount
        XCTAssertEqual(1, actual)
    }

    func testSaveSelections_requestNotification() {
        hormone.isPastNotificationTime = false
        let notifications = dependencies.notifications as! MockNotifications
        viewModel.saveSelections()
        let actual = notifications.requestExpiredHormoneNotificationCallArgs[0].id
        let expected = hormone.id
        XCTAssertEqual(expected, actual)
    }

    func testSaveSelections_reflectsTabs() {
        hormone.isPastNotificationTime = false
        let tabs = dependencies.tabs as! MockTabs
        viewModel.saveSelections()
        let actual = tabs.reflectHormonesCallCount
        let expected = 1
        XCTAssertEqual(expected, actual)
    }

    func testSaveSelections_savesSiteNameIfNoSiteAndHasSiteName() {
        viewModel.selections.site = nil
        viewModel.selections.siteName = "TEST"
        viewModel.saveSelections()
        let callArgs = (viewModel.sdk!.hormones as! MockHormoneSchedule).setSiteNameCallArgs[0]
        XCTAssertEqual(hormone.id, callArgs.0)
        XCTAssertEqual(callArgs.1, "TEST")
    }

    func testHandleIfUnsaved_whenNoChanges_stillPops() {
        let viewController = UIViewController()
        viewModel.handleIfUnsaved(viewController)
        XCTAssertEqual(viewController, (viewModel.nav! as! MockNav).popCallArgs[0])
    }

    func testExtractSiteNameFromTextField_whenTextFieldHasNoText_returnsEmptyString() {
        let expected = ""
        let textField = UITextField()
        textField.text = nil
        let actual = viewModel.extractSiteNameFromTextField(textField)
        XCTAssertEqual(expected, actual)
    }

    func testExtractSiteNameFromTextField_whenTextFieldTextIsEmptyString_returnsText() {
        let text = "Text"
        let expected = text
        let textField = UITextField()
        textField.text = text
        let actual = viewModel.extractSiteNameFromTextField(textField)
        XCTAssertEqual(expected, actual)
    }

    func testPresentNewSiteAlert_whenNewSiteNameIsEmptyString_doesNotPresent() {
        let site = ""
        viewModel.presentNewSiteAlert(newSiteName: site)
        let callCount = alertFactory.createNewSiteAlertCallArgs.count
        XCTAssertEqual(0, callCount)
        XCTAssertEqual(0, alertFactory.createNewSiteAlertReturnValue.presentCallCount)
    }

    func testPresentNewSiteAlert_presentsAlertWithHandlerThatWhenCalledInsertsNewSite() {
        let site = "Right Thigh"
        viewModel.presentNewSiteAlert(newSiteName: site)
        let handlers = alertFactory.createNewSiteAlertCallArgs[0]
        handlers.handleNewSite()
        let actual = (dependencies.sdk?.sites as! MockSiteSchedule).insertNewCallArgs[0]
        XCTAssertEqual(site, actual.0)
    }

    func testPresentNewSiteAlert_presentsAlertWithHandlerWithClosureThatCallsUpdateViewsHandler() {
        let site = "Right Thigh"
        viewModel.presentNewSiteAlert(newSiteName: site)
        let handlers = alertFactory.createNewSiteAlertCallArgs[0]
        handlers.handleNewSite()
        let closure = (dependencies.sdk?.sites as! MockSiteSchedule).insertNewCallArgs[0].1
        closure!()
        XCTAssertEqual(1, HormoneDetailViewModelTests.handlerCallCount)
    }

    func testPresentNewSiteAlert_presentsAlertWithHandlerWithClosureThatSelectsNewSiteFromInsert() {
        let sites = dependencies.sdk?.sites as! MockSiteSchedule
        let site = MockSite()
        sites.insertNewReturnValue = site
        viewModel.presentNewSiteAlert(newSiteName: "Test")
        let handlers = alertFactory.createNewSiteAlertCallArgs[0]
        handlers.handleNewSite()
        let expected = site.id
        let actual = viewModel.selections.site?.id
        XCTAssertEqual(expected, actual)
    }
}
