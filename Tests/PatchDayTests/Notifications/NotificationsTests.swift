//
//  NotificationsTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 4/26/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class NotificationsTests: XCTestCase {

    private let mockHormones: [Hormonal] = [MockHormone(), MockHormone(), MockHormone(), MockHormone()]
    private let mockNotification = MockNotification()
    private let mockSite = MockSite()

    private func createSDK(totalExpired: Int = 0, settings: MockSettings? = nil) -> MockSDK {
        let settings = settings ?? createSettings()
        let hormones = createMockHormones()
        let sites = createMockSites()
        let sdk = MockSDK()
        sdk.hormones = hormones
        sdk.settings = settings
        sdk.sites = sites
        sdk.totalAlerts = totalExpired
        return sdk
    }

    private func createMockHormones() -> MockHormoneSchedule {
        let hormones = MockHormoneSchedule()
        hormones.all = mockHormones
        return hormones
    }

    private func createMockSites() -> MockSiteSchedule {
        let sites = MockSiteSchedule()
        sites.suggested = mockSite
        return sites
    }

    private func createFactory() -> MockNotificationFactory {
        let factory = MockNotificationFactory()
        factory.createExpiredHormoneNotificationReturnValue = mockNotification
        factory.createDuePillNotificationReturnValue = mockNotification
        factory.createOvernightExpiredHormoneNotificationReturnValue = mockNotification
        return factory
    }

    private func createSettings(on: Bool = true, minutesBefore: Int = 0, quantity: Int = 4) -> MockSettings {
        let settings = MockSettings()
        settings.notifications = NotificationsUD(on)
        settings.notificationsMinutesBefore = NotificationsMinutesBeforeUD(minutesBefore)
        settings.quantity = QuantityUD(quantity)
        return settings
    }

    private func createTestHormone() -> MockHormone {
        let mockHormone = MockHormone()
        mockHormone.siteName = "TestSite"
        return mockHormone
    }

    private func createTestPill(isDue: Bool = true, notify: Bool = true) -> MockPill {
        let pill = MockPill()
        pill.isDue = isDue
        pill.notify = notify
        return pill
    }

    func testCancelAllExpiredHormoneNotifications_cancelsAllHormones() {
        let sdk = createSDK()
        let center = MockNotificationCenter()
        let factory = MockNotificationFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.cancelAllExpiredHormoneNotifications()

        XCTAssertEqual([
            mockHormones[0].id.uuidString,
            mockHormones[1].id.uuidString,
            mockHormones[2].id.uuidString,
            mockHormones[3].id.uuidString
        ], center.removeNotificationsCallArgs[0]
        )
    }

    func testCancelExpiredHormoneNotificationByObject_cancelsExpectedHormone() {
        let sdk = createSDK()
        let center = MockNotificationCenter()
        let factory = MockNotificationFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.cancelExpiredHormoneNotification(for: mockHormones[1])
        XCTAssertEqual([mockHormones[1].id.uuidString], center.removeNotificationsCallArgs[0])
    }

    func testCancelRangeOfExpiredHormoneNotifications_cancelsExpectedRange() {
        let sdk = createSDK()
        let center = MockNotificationCenter()
        let factory = MockNotificationFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.cancelRangeOfExpiredHormoneNotifications(from: 2, to: 6)
        let callArgs = center.removeNotificationsCallArgs[0]
        XCTAssertEqual([mockHormones[2].id.uuidString, mockHormones[3].id.uuidString], callArgs)
    }

    func testCancelRangeOfExpiredHormoneNotifications_whenEndGreaterThanBegin_doesNotCallCancel() {
        let sdk = MockSDK()
        let center = MockNotificationCenter()
        let factory = MockNotificationFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.cancelRangeOfExpiredHormoneNotifications(from: 8, to: 6)
        XCTAssertEqual(0, center.removeNotificationsCallArgs.count)
    }

    func testCancelRangeOfExpiredHormoneNotifications_whenNoHormoneInRange_doesNotCallCancel() {
        let sdk = MockSDK()
        let center = MockNotificationCenter()
        let factory = MockNotificationFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.cancelRangeOfExpiredHormoneNotifications(from: 2, to: 4)
        XCTAssertEqual(0, center.removeNotificationsCallArgs.count)
    }

    func testRequestExpiredHormoneNotification_whenTurnedOffInSettings_doesNotRequest() {
        let center = MockNotificationCenter()
        let sdk = createSDK(settings: createSettings(on: false))
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        let mockHormone = createTestHormone()
        notifications.requestExpiredHormoneNotification(for: mockHormone)
        XCTAssertEqual(0, mockNotification.requestCallCount)
    }

    func testRequestExpiredHormoneNotification_requestsWithExpectedParameters() {
        let center = MockNotificationCenter()
        let settings = createSettings(on: true, minutesBefore: 23)
        let sdk = createSDK(totalExpired: 2, settings: settings)
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        let mockHormone = createTestHormone()
        notifications.requestExpiredHormoneNotification(for: mockHormone)

        XCTAssertEqual(mockHormone.id, factory.createExpiredHormoneNotificationCallArgs[0].id)
        XCTAssertEqual(1, mockNotification.requestCallCount)
    }

    func testRequestRangeOfExpiredHormoneNotifications_whenBeginGreaterThanEnd_doesNotRequest() {
        let sdk = createSDK()
        let center = MockNotificationCenter()
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.requestRangeOfExpiredHormoneNotifications(from: 18, to: 1)
        XCTAssertEqual(0, mockNotification.requestCallCount)
    }

    func testRequestRangeOfExpiredHormoneNotifications_cancelsBeforeRequesting() {
        let sdk = createSDK()
        let center = MockNotificationCenter()
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.requestRangeOfExpiredHormoneNotifications(from: 2, to: 3)
        XCTAssertEqual(1, center.removeNotificationsCallArgs.count)
    }

    func testRequestRangeOfExpiredHormoneNotifications_whenNotificationsIsOff_doesNotRequest() {
        let sdk = createSDK(settings: createSettings(on: false))
        let center = MockNotificationCenter()
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.requestRangeOfExpiredHormoneNotifications(from: 18, to: 1)
        XCTAssertEqual(0, mockNotification.requestCallCount)
    }

    func testRequestRangeOfExpiredHormoneNotifications_cancelsExpectedHormones() {
        let sdk = createSDK()
        let center = MockNotificationCenter()
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.requestRangeOfExpiredHormoneNotifications(from: 2, to: 3)
        XCTAssertEqual(
            [mockHormones[2].id.uuidString, mockHormones[3].id.uuidString],
            center.removeNotificationsCallArgs[0]
        )
    }

    func testRequestRangeOfExpiredHormoneNotifications_requests() {
        let sdk = createSDK()
        let center = MockNotificationCenter()
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.requestRangeOfExpiredHormoneNotifications(from: 2, to: 3)
        XCTAssertEqual(2, mockNotification.requestCallCount)
    }

    func testRequestAllExpiredHormoneNotifications_requestsExpectedNumberOfNotifications() {
        let sdk = createSDK(settings: createSettings(quantity: 4))
        let center = MockNotificationCenter()
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        notifications.requestAllExpiredHormoneNotifications()
        XCTAssertEqual(4, mockNotification.requestCallCount)
    }

    func testRequestDuePillNotification_whenPillIsNotified_doesNotRequest() {
        let sdk = createSDK(totalExpired: 3)
        let center = MockNotificationCenter()
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        let pill = createTestPill(isDue: true, notify: false)
        notifications.requestDuePillNotification(pill)
        XCTAssertEqual(0, factory.createDuePillNotificationCallArgs.count)
    }

    func testRequestDuePillNotification_whenPillIsDueAndNotified_requests() {
        let sdk = createSDK(totalExpired: 3)
        let center = MockNotificationCenter()
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        let pill = createTestPill(isDue: true, notify: true)
        notifications.requestDuePillNotification(pill)
        XCTAssertEqual(pill.id, factory.createDuePillNotificationCallArgs[0].id)
        XCTAssertEqual(1, mockNotification.requestCallCount)
    }

    func testCancelDuePillNotification_cancels() {
        let sdk = createSDK(totalExpired: 3)
        let center = MockNotificationCenter()
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        let pill = createTestPill(isDue: true, notify: true)
        notifications.cancelDuePillNotification(pill)
        XCTAssertEqual([pill.id.uuidString], center.removeNotificationsCallArgs[0])
    }

    func testRequestOvernightExpirationNotification_whenHormoneDoesNotExpire_doesNotRequest() {
        let sdk = createSDK(totalExpired: 3)
        let center = MockNotificationCenter()
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        let hormone = createTestHormone()
        hormone.expiration = nil
        notifications.requestOvernightExpirationNotification(for: hormone)
        XCTAssertEqual(0, mockNotification.requestCallCount)
    }

    func testRequestOvernightExpirationNotification_whenHormoneDoesNotExpireOvernight_doesNotRequest() {
        let sdk = createSDK(totalExpired: 3)
        let center = MockNotificationCenter()
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)
        let hormone = createTestHormone()
        hormone.expiration = Date()
        hormone.expiresOvernight = false
        notifications.requestOvernightExpirationNotification(for: hormone)
        XCTAssertEqual(0, mockNotification.requestCallCount)
    }

    func testRequestOvernightExpirationNotification_usesExpectedTime() {
        let sdk = createSDK(totalExpired: 3)
        let center = MockNotificationCenter()
        let factory = createFactory()
        let notifications = Notifications(sdk: sdk, center: center, factory: factory)

        let hormone = createTestHormone()
        hormone.expiration = Date()
        hormone.expiresOvernight = true
        let cal = Calendar.current
        let eight = cal.date(bySettingHour: 20, minute: 0, second: 0, of: hormone.expiration!)
        let eightYesterday = cal.date(byAdding: .day, value: -1, to: eight!)

        notifications.requestOvernightExpirationNotification(for: hormone)
        XCTAssertEqual(eightYesterday, factory.createOvernightExpiredHormoneNotificationCallArgs[0])
        XCTAssertEqual(1, mockNotification.requestCallCount)
    }
}
