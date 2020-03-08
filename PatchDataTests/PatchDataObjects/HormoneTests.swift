//
//  HormoneTest.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/12/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchData


class HormoneTests: XCTestCase {
    
    let testId = UUID()
    let testDateThatIsNow = Date()
    let testSiteId = UUID()
    
    private func createEmptyHormone(useDefaultDate: Bool=false) -> Hormone {
        let date = useDefaultDate ? Date(timeIntervalSince1970: 0) : nil
        let data = HormoneStruct(testId, testSiteId, nil, date, nil)
        let props = HormoneScheduleProperties(
            ExpirationIntervalUD(.TwiceWeekly), .Patches, NotificationsMinutesBeforeUD(0)
        )
        return Hormone(hormoneData: data, scheduleProperties: props)
    }
    
    private func createHormoneForExpirationTesting(_ expiration: ExpirationInterval) -> Hormone {
        let hormone = createEmptyHormone()
        hormone.date = testDateThatIsNow
        hormone.expirationInterval = ExpirationIntervalUD(expiration)
        return hormone
    }
    
    private func createTwiceWeeklyHormoneThatIsExpiredByOneDay() -> Hormone {
        let hormone = createEmptyHormone()
        hormone.expirationInterval = ExpirationIntervalUD(.TwiceWeekly)
        hormone.date = Date(timeIntervalSinceNow: -388800)
        return hormone
    }
    
    func testSetSiteId_setsSiteBackUpNameToNil() {
        let hormone = createEmptyHormone()
        hormone.siteNameBackUp = "start"
        hormone.siteId = testSiteId
        XCTAssertNil(hormone.siteNameBackUp)
    }
    
    func testSetSiteId_whenSettingToNil_doesNotClearSiteBackUpName() {
        let hormone = createEmptyHormone()
        hormone.siteNameBackUp = "Test"
        hormone.siteId = nil
        XCTAssertEqual("Test", hormone.siteNameBackUp)
    }
    
    func testSetSiteId_whenSettingToNil_setsToNil() {
        let hormone = createEmptyHormone()
        hormone.siteId = UUID()
        hormone.siteId = nil
        XCTAssertNil(hormone.siteId)
    }
    
    func testExpiration_whenExpirationIntervalIsEveryTwoWeeks_returnsExpectedDate() {
        let hormone = createHormoneForExpirationTesting(.TwiceWeekly)
        let expected = Calendar.current.date(byAdding: .hour, value: 84, to: testDateThatIsNow)
        let actual = hormone.expiration
        XCTAssertEqual(expected, actual)
    }
    
    func testExpiration_whenExpirationIntervalIsOnceAWeek_returnsExpectedDate() {
        let hormone = createHormoneForExpirationTesting(.OnceWeekly)
        let expected = Calendar.current.date(byAdding: .hour, value: 168, to: testDateThatIsNow)
        let actual = hormone.expiration
        XCTAssertEqual(expected, actual)
    }
    
    func testExpiration_whenExpirationIntervalIsTwiceAWeek_returnsExpectedDate() {
        let hormone = createHormoneForExpirationTesting(.EveryTwoWeeks)
        let expected = Calendar.current.date(byAdding: .hour, value: 336, to: testDateThatIsNow)
        let actual = hormone.expiration
        XCTAssertEqual(expected, actual)
    }
    
    func testExpiration_whenDateIsDefault_returnsNil() {
        let hormone = createEmptyHormone(useDefaultDate: true)
        XCTAssertNil(hormone.expiration)
    }
    
    func testExpirationString_whenExpirationIsnil_returnsThreeDots() {
        let hormone = createEmptyHormone()
        let expected = "..."
        let actual = hormone.expirationString
        XCTAssertEqual(expected, actual)
    }
    
    func testExpirationString_whenExpirationIsDefault_returnsThreeDots() {
        let hormone = createEmptyHormone(useDefaultDate: true)
        let expected = "..."
        let actual = hormone.expirationString
        XCTAssertEqual(expected, actual)
    }
    
    func testExpirationString_whenExpirationIsYesterday_includesWordYesterday() {
        let hormone = createTwiceWeeklyHormoneThatIsExpiredByOneDay()
        XCTAssert(hormone.expirationString.contains("Yesterday"))
    }
    
    func testIsExpired_whenExpirationDateIsBeforeNow_returnsTrue() {
        let hormone = createTwiceWeeklyHormoneThatIsExpiredByOneDay()
        XCTAssert(hormone.isExpired)
    }
    
    func testIsExpired_whenExpirationDateIsAfterNow_returnsFalse() {
        let hormone = createEmptyHormone()
        hormone.expirationInterval = ExpirationIntervalUD(.TwiceWeekly)
        hormone.date = testDateThatIsNow
        XCTAssertFalse(hormone.isExpired)
    }
    
    func testIsExpired_whenDateIsDefault_returnsFalse() {
        let hormone = createEmptyHormone(useDefaultDate: true)
        XCTAssertFalse(hormone.isExpired)
    }

    func testIsPastNotificationTime_whenNowIsBeforeNotificationTime_returnsFalse() {
        let notExpiredHormone = createHormoneForExpirationTesting(.EveryTwoWeeks)
        XCTAssertFalse(notExpiredHormone.isPastNotificationTime)
    }
    
    func testIsPastNotificationTime_whenNowIsAfterNotificationTime_returnsTrue() {
        let expiredHormone = createTwiceWeeklyHormoneThatIsExpiredByOneDay()
        XCTAssertTrue(expiredHormone.isPastNotificationTime)
    }
    
    func testIsPastNotificationTime_whenIsPastNotificationTimeButBeforeExpirationTime_returnsTrue() {
        let hormone = createEmptyHormone()
        hormone.expirationInterval = ExpirationIntervalUD(.TwiceWeekly)
        hormone.notificationsMinutesBefore = NotificationsMinutesBeforeUD(30)
        
        // 10 minutes past notification time and 20 minutes before expiration
        let calendar = Calendar.current
        hormone.date = calendar.date(byAdding: .minute, value: -5020, to: Date())!
        
        XCTAssertTrue(hormone.isPastNotificationTime)
    }
    
    func testExpiresOvernight_whenExpired_returnsFalse() {
        let expiredHormone = createTwiceWeeklyHormoneThatIsExpiredByOneDay()
        XCTAssertFalse(expiredHormone.expiresOvernight)
    }
    
    func testExpiresOvernight_whenExpirationTimeIsBetweenSixAMAndMidnight_returnsTrue() {
        let hormone = createEmptyHormone()
        hormone.expirationInterval = ExpirationIntervalUD(.OnceWeekly)

        let calendar = Calendar.current
        
        // Make the hormone date applied at 3am.
        hormone.date = calendar.date(bySettingHour: 3, minute: 0, second: 0, of: Date())!
        
        XCTAssertTrue(hormone.expiresOvernight)
    }
    
    func testExpiresOvernight_whenExpirationTimeIsAtNoon_returnsFalse() {
        let hormone = createEmptyHormone()
        hormone.expirationInterval = ExpirationIntervalUD(.OnceWeekly)

        let calendar = Calendar.current
        
        // Make the hormone date applied at 3am.
        hormone.date = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        
        XCTAssertFalse(hormone.expiresOvernight)
    }
    
    func testSiteNameBackUp_whenHasSiteIdAndSiteNameBackUp_returnsNil() {
        let hormone = createEmptyHormone()
        hormone.siteId = UUID()
        hormone.siteNameBackUp = "Right Ass Cheek"
        XCTAssertNil(hormone.siteNameBackUp)
    }
    
    func testIsEmpty_whenHasDefaultDateAndNilSiteIdAndNilSiteNameBackUp_returnsTrue() {
        let hormone = createEmptyHormone()
        hormone.siteId = nil
        hormone.date = Date(timeIntervalSince1970: 0)
        hormone.siteNameBackUp = nil
        XCTAssert(hormone.isEmpty)
    }
    
    func testIsEmpty_whenHasDefaultDateAndSiteIdAndNilSiteNameBackUp_returnsFalse() {
        let hormone = createEmptyHormone()
        hormone.siteId = UUID()
        hormone.date = Date(timeIntervalSince1970: 0)
        hormone.siteNameBackUp = nil
        XCTAssertFalse(hormone.isEmpty)
    }
    
    func testIsEmpty_whenHasRecentDateAndNilSiteIdAndNilSiteNameBackUp_returnsFalse() {
        let hormone = createEmptyHormone()
        hormone.siteId = nil
        hormone.date = Date()
        hormone.siteNameBackUp = nil
        XCTAssertFalse(hormone.isEmpty)
    }
    
    func testIsEmpty_whenHasRecentDateAndNilSiteIdAndSiteNameBackUp_returnsFalse() {
        let hormone = createEmptyHormone()
        hormone.siteId = nil
        hormone.date = Date(timeIntervalSince1970: 0)
        hormone.siteNameBackUp = "Right Ass Cheek"
        XCTAssertFalse(hormone.isEmpty)
    }
    
    func testHasDate_whenHasNilSiteIdAndSiteNameBackUp_returnsTrue() {
        let hormone = createEmptyHormone()
        hormone.siteId = nil
        hormone.siteNameBackUp = "Right Ass Cheek"
        XCTAssertTrue(hormone.hasSite)
    }
    
    func testHasDate_whenHasSiteIdAndNilSiteNameBackUp_returnsTrue() {
        let hormone = createEmptyHormone()
        hormone.siteId = UUID()
        hormone.siteNameBackUp = nil
        XCTAssertTrue(hormone.hasSite)
    }
    
    func testHasDate_whenDateIsDefault_returnsFalse() {
        let hormone = createEmptyHormone()
        hormone.date = Date(timeIntervalSince1970: 0)
        XCTAssertFalse(hormone.hasDate)
    }
    
    func testHasDate_whenDateIsRecent_returnsTrue() {
        let hormone = createEmptyHormone()
        hormone.date = Date()
        XCTAssertTrue(hormone.hasDate)
    }
    
    func testStamp_setsDateToNow() {
        let hormone = createEmptyHormone()
        hormone.stamp()
        XCTAssert(hormone.date.timeIntervalSince(Date()) < 0.1)
    }
    
    func testReset_setsAllPropsToNil() {
        let hormone = createTwiceWeeklyHormoneThatIsExpiredByOneDay()
        hormone.reset()
        XCTAssert(
            hormone.date == Date(timeIntervalSince1970: 0)
            && hormone.siteId == nil
            && hormone.siteNameBackUp == nil
        )
    }
}
