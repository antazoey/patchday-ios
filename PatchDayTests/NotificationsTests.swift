//
//  NotificationsTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 4/26/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay


class NotificationsTests: XCTestCase {
    
    override func setUp() {
        
    }
    
    func testRequestExpiredHormoneNotification_whenTurnedOffInSettings_doesNotRequest() {
        let center = MockNotificationCenter()
        let settings = MockSettings()
        settings.notifications = NotificationsUD(false)
        let sdk = MockSDK()
        sdk.settings = settings
        
        let factory = MockNotificationFactory()
        let mockNotification = MockNotification()
        factory.createExpiredHormoneNotificationReturnValue = mockNotification
        
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        
        let mockHormone = MockHormone()
        mockHormone.siteName = "TestSite"
        
        notifications.requestExpiredHormoneNotification(for: mockHormone)
        XCTAssert(mockNotification.requestCallCount == 0)
    }
    
    func testRequestExpiredHormoneNotification_requestsWithExpectedParameters() {
        let center = MockNotificationCenter()
        
        let sites = MockSiteSchedule()
        sites.suggested = MockSite()
        
        let hormones = MockHormoneSchedule()
        hormones.totalExpired = 2
        
        let settings = MockSettings()
        settings.notifications = NotificationsUD(true)
        settings.notificationsMinutesBefore = NotificationsMinutesBeforeUD(23)
        let sdk = MockSDK()
        sdk.settings = settings
        sdk.sites = sites
        sdk.hormones = hormones
        
        let factory = MockNotificationFactory()
        let mockNotification = MockNotification()
        factory.createExpiredHormoneNotificationReturnValue = mockNotification
        
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        
        let mockHormone = MockHormone()
        mockHormone.siteName = "TestSite"
        
        notifications.requestExpiredHormoneNotification(for: mockHormone)
        XCTAssert(factory.createExpiredHormoneNotificationCallArgs[0].hormone.id == mockHormone.id)
        XCTAssert(factory.createExpiredHormoneNotificationCallArgs[0].suggestedSiteName == sites.suggested?.name)
        XCTAssert(factory.createExpiredHormoneNotificationCallArgs[0].notificationsMinutesBefore == 23)
        XCTAssert(factory.createExpiredHormoneNotificationCallArgs[0].totalHormonesExpired == 2)
        XCTAssert(mockNotification.requestCallCount == 1)
    }
    
    func testCancelAllExpiredHormoneNotifications_cancelsAllHormones() {
        let mockSettings = MockSettings()
        mockSettings.quantity = QuantityUD(4)
        let mockHormones = MockHormoneSchedule()
        mockHormones.all = [MockHormone(), MockHormone(), MockHormone(), MockHormone()]
        let sdk = MockSDK()
        sdk.settings = mockSettings
        sdk.hormones = mockHormones
        
        let center = MockNotificationCenter()
        let factory = MockNotificationFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.cancelAllExpiredHormoneNotifications()
        
        XCTAssert(center.removeNotificationsCallArgs[0] == [
            mockHormones[0]?.id.uuidString,
            mockHormones[1]?.id.uuidString,
            mockHormones[2]?.id.uuidString,
            mockHormones[3]?.id.uuidString
            ]
        )
    }
    
    func testCancelExpiredHormoneNotificationByIndex_cancelsExpectedHormone() {
        let mockHormones = MockHormoneSchedule()
        mockHormones.all = [MockHormone(), MockHormone(), MockHormone(), MockHormone()]
        let sdk = MockSDK()
        sdk.hormones = mockHormones
        let center = MockNotificationCenter()
        let factory = MockNotificationFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.cancelExpiredHormoneNotification(at: 2)
        XCTAssert(center.removeNotificationsCallArgs[0] == [mockHormones[2]!.id.uuidString])
    }
    
    func testCancelExpiredHormoneNotificationByObject_cancelsExpectedHormone() {
        let mockHormones = MockHormoneSchedule()
        mockHormones.all = [MockHormone(), MockHormone(), MockHormone(), MockHormone()]
        let sdk = MockSDK()
        sdk.hormones = mockHormones
        let center = MockNotificationCenter()
        let factory = MockNotificationFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.cancelExpiredHormoneNotification(for: mockHormones[1]!)
        XCTAssert(center.removeNotificationsCallArgs[0] == [mockHormones[1]!.id.uuidString])
    }
    
    func testCancelRangeOfExpiredHormoneNotifications_cancelsExpectedRange() {
        let mockHormones = MockHormoneSchedule()
        mockHormones.all = [MockHormone(), MockHormone(), MockHormone(), MockHormone()]
        let sdk = MockSDK()
        sdk.hormones = mockHormones
        let center = MockNotificationCenter()
        let factory = MockNotificationFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.cancelRangeOfExpiredHormoneNotifications(from: 2, to: 6)
        XCTAssert(center.removeNotificationsCallArgs[0] == [mockHormones[2]?.id.uuidString, mockHormones[3]?.id.uuidString])
    }
    
    func testCancelRangeOfExpiredHormoneNotifications_whenEndGreaterThanBegin_doesNotCallCancel() {
        let sdk = MockSDK()
        let center = MockNotificationCenter()
        let factory = MockNotificationFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.cancelRangeOfExpiredHormoneNotifications(from: 8, to: 6)
        XCTAssert(center.removeNotificationsCallArgs.count == 0)
    }
    
    func testCancelRangeOfExpiredHormoneNotifications_whenNoHormoneInRange_doesNotCallCancel() {
        let sdk = MockSDK()
        let center = MockNotificationCenter()
        let factory = MockNotificationFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.cancelRangeOfExpiredHormoneNotifications(from: 2, to: 4)
        XCTAssert(center.removeNotificationsCallArgs.count == 0)
    }
}
