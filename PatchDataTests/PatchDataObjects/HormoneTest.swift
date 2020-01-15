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
        let data = HormoneStruct(nil, testSiteId, nil, date, nil)
        let props = HormoneScheduleProperties(ExpirationIntervalUD(), .Patches, NotificationsMinutesBeforeUD())
        return Hormone(hormoneData: data, scheduleProperties: props)
    }
    
    private func createHormoneForExpirationTesting(_ expiration: ExpirationInterval) -> Hormone {
        let hormone = createEmptyHormone()
        hormone.date = testDateThatIsNow
        hormone.expirationInterval = ExpirationIntervalUD(expiration)
        return hormone
    }
    
    private func createTwiceAWeekHormoneThatIsExpiredByOneDay() -> Hormone {
        let hormone = createEmptyHormone()
        hormone.expirationInterval = ExpirationIntervalUD(.TwiceAWeek)
        hormone.date = Date(timeIntervalSinceNow: -388800)
        return hormone
    }
    
    func testSetSiteId_setSiteBackUpNameToNil() {
        let hormone = createEmptyHormone()
        hormone.siteNameBackUp = "start"
        hormone.siteId = UUID()
        XCTAssertNil(hormone.siteNameBackUp)
    }
    
    func testExpiration_whenExpirationIntervalIsEveryTwoWeeks_returnsExpectedDate() {
        let hormone = createHormoneForExpirationTesting(.TwiceAWeek)
        let expected = Calendar.current.date(byAdding: .hour, value: 84, to: testDateThatIsNow)
        let actual = hormone.expiration
        XCTAssertEqual(expected, actual)
    }
    
    func testExpiration_whenExpirationIntervalIsOnceAWeek_returnsExpectedDate() {
        let hormone = createHormoneForExpirationTesting(.OnceAWeek)
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
        let hormone = createTwiceAWeekHormoneThatIsExpiredByOneDay()
        XCTAssert(hormone.expirationString.contains("Yesterday"))
    }
    
    func testIsExpired_whenExpirationDateIsBeforeNow_returnsTrue() {
        let hormone = createTwiceAWeekHormoneThatIsExpiredByOneDay()
        XCTAssert(hormone.isExpired)
    }
    
    func testIsExpired_whenExpirationDateIsAfterNow_returnsFalse() {
        let hormone = createEmptyHormone()
        hormone.expirationInterval = ExpirationIntervalUD(.TwiceAWeek)
        hormone.date = Date()
        XCTAssertFalse(hormone.isExpired)
    }
    
    func testIsExpired_whenDateIsDefault_returnsFalse() {
        let hormone = createEmptyHormone(useDefaultDate: true)
        XCTAssertFalse(hormone.isExpired)
    }
    
    func testIsEqualTo_whenHormoneHasSameIdAsOtherHormone_returnsTrue() {
        let hormoneOne = createEmptyHormone()
        let hormoneTwo = createEmptyHormone()
        hormoneOne.id = testId
        hormoneTwo.id = testId
        XCTAssert(hormoneOne.isEqualTo(hormoneTwo) && hormoneTwo.isEqualTo(hormoneOne))
    }
    
    func testIsEqualTo_whenHormoneHasDifferentIdThanOtherHormone_returnsFalse() {
        let hormoneOne = createEmptyHormone()
        let hormoneTwo = createEmptyHormone()
        hormoneOne.id = testId
        hormoneTwo.id = UUID()
        XCTAssert(!hormoneOne.isEqualTo(hormoneTwo) && !hormoneTwo.isEqualTo(hormoneOne))
    }
    
    func testIsPastNotificationTime_whenNowIsBeforeNotificationTime_returnsFalse() {
        let notExpiredHormone = createHormoneForExpirationTesting(.EveryTwoWeeks)
        XCTAssertFalse(notExpiredHormone.isPastNotificationTime)
    }
    
    func testIsPastNotificationTime_whenNowIsAfterNotificationTime_returnsTrue() {
        let expiredHormone = createTwiceAWeekHormoneThatIsExpiredByOneDay()
        XCTAssertTrue(expiredHormone.isPastNotificationTime)
    }
    
    func testIsPastNotificationTime_whenIsPastNotificationTimeButBeforeExpirationTime_returnsTrue() {
        let hormone = createEmptyHormone()
        hormone.expirationInterval = ExpirationIntervalUD(.TwiceAWeek)
        hormone.notificationsMinutesBefore = NotificationsMinutesBeforeUD(30)
        
        // 10 minutes past notification time and 20 minutes before expiration
        let calendar = Calendar.current
        hormone.date = calendar.date(byAdding: .minute, value: -5020, to: Date())!
        
        XCTAssertTrue(hormone.isPastNotificationTime)
    }
}
