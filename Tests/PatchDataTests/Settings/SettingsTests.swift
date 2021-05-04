//
// Created by Juliya Smith on 2/11/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest

@testable
import PatchData

class SettingsTests: XCTestCase {

    private let mockSettingsWriter = MockUserDefaultsWriter()
    private let mockHormones = MockHormoneSchedule()
    private let mockSites = MockSiteSchedule()

    private func createSettings() -> Settings {
        Settings(writer: mockSettingsWriter, hormones: mockHormones, sites: mockSites)
    }

    func testSetDeliveryMethod_replacesMethod() {
        let settings = createSettings() // Defaults to Patches
        settings.setDeliveryMethod(to: .Injections)
        let actual = mockSettingsWriter.replaceStoredDeliveryMethodCallArgs[0]
        XCTAssertEqual(.Injections, actual)
    }

    func testSetDeliveryMethod_sharedData() {
        let settings = createSettings() // Defaults to Patches
        settings.setDeliveryMethod(to: .Injections)
        let expected = 1
        let actual = mockHormones.shareDataCallCount
        XCTAssertEqual(expected, actual)
    }

    func testSetDeliveryMethod_resetsSites() {
        let settings = createSettings()
        settings.setDeliveryMethod(to: .Injections)
        XCTAssertEqual(1, mockSites.resetCallCount)
    }

    func testSetDeliveryMethod_whenSettingToPatches_setsQuantityToDefault() {
        let settings = createSettings()
        settings.setDeliveryMethod(to: .Injections)
        mockSettingsWriter.resetMock()

        settings.setDeliveryMethod(to: .Patches)

        let callArgs = mockSettingsWriter.replaceStoredQuantityCallArgs
        if callArgs.count < 1 {
            XCTFail("Set quantity was never called")
            return
        }
        XCTAssertEqual(DefaultQuantities.Hormone[.Patches], callArgs[0])
    }

    func testSetDeliveryMethod_whenSettingToInjections_setsQuantityToDefault() {
        let settings = createSettings()

        settings.setDeliveryMethod(to: .Injections)

        let callArgs = mockSettingsWriter.replaceStoredQuantityCallArgs
        if callArgs.count < 1 {
            XCTFail("Set quantity was never called")
            return
        }
        XCTAssertEqual(DefaultQuantities.Hormone[.Injections], callArgs[0])
    }

    func testSetDeliveryMethod_whenSettingToGel_setsQuantityToDefault() {
        let settings = createSettings()

        settings.setDeliveryMethod(to: .Gel)

        let callArgs = mockSettingsWriter.replaceStoredQuantityCallArgs
        if callArgs.count < 1 {
            XCTFail("Set quantity was never called")
            return
        }
        XCTAssertEqual(DefaultQuantities.Hormone[.Gel], callArgs[0])
    }

    func testSetQuantity_whenQuantityNotInSupportedRange_doesNotReplaceQuantity() {
        let settings = createSettings()
        let badNewQuantity = SettingsOptions.quantities.count + 1
        settings.setQuantity(to: badNewQuantity)
        XCTAssert(mockSettingsWriter.quantity.rawValue != badNewQuantity)
    }

    func testSetQuantity_whenQuantityIsInSupportedRange_replacesQuantity() {
        let settings = createSettings()
        let newQuantity = SettingsOptions.quantities.count
        settings.setQuantity(to: newQuantity)
        XCTAssertEqual(newQuantity, mockSettingsWriter.quantity.rawValue)
    }

    func testSetQuantity_whenQuantityIsIncreasing_fillsInHormones() {
        let settings = createSettings() // Starts out at count of 4
        mockSettingsWriter.quantity = QuantityUD(2)
        settings.setQuantity(to: 2)
        settings.setQuantity(to: 4)

        // fillIn takes a count as the argument (it fills in hormones to reach the new count)
        let expected = 4
        let actual = mockHormones.fillInCallArgs[0]
        XCTAssertEqual(expected, actual)
    }

    func testSetExpirationInterval_setsIntervalUsingExpectedValue() {
        let settings = createSettings()

        // Testing 3 calls
        settings.setExpirationInterval(to: SettingsOptions.OnceEveryTwoWeeks)
        settings.setExpirationInterval(to: SettingsOptions.EveryXDays)
        settings.setExpirationInterval(to: SettingsOptions.OnceWeekly)

        let callArgs = mockSettingsWriter.replaceStoredExpirationIntervalCallArgs
        XCTAssertEqual(3, callArgs.count)
        XCTAssertEqual(.EveryTwoWeeks, callArgs[0])
        XCTAssertEqual(.EveryXDays, callArgs[1])
        XCTAssertEqual(.OnceWeekly, callArgs[2])
    }

    func testSetXDays_setsXDays() {
        let settings = createSettings()
        settings.setXDays(to: "3")
        let callArgs = mockSettingsWriter.replaceStoredXDaysCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual("3", callArgs[0])
    }

    func testSetSiteIndex_setsSiteIndex() {
        let settings = createSettings()
        settings.setSiteIndex(to: 3)
        let callArgs = mockSettingsWriter.replaceStoredSiteIndexCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual(3, callArgs[0])
    }

    func testSetNotifications_setsNotifications() {
        let settings = createSettings()
        settings.setNotifications(to: false)
        let callArgs = mockSettingsWriter.replaceStoredNotificationsCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual(false, callArgs[0])
    }

    func testSetNotificationsMinutesBefore_setsNotificationsMinutesBefore() {
        let settings = createSettings()
        settings.setNotificationsMinutesBefore(to: 32)
        let callArgs = mockSettingsWriter.replaceStoredNotificationsMinutesBeforeCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual(32, callArgs[0])
    }

    func testSetMentionedDisclaimer_setsMentionedDisclaimer() {
        let settings = createSettings()
        settings.setMentionedDisclaimer(to: true)
        let callArgs = mockSettingsWriter.replaceStoredMentionedDisclaimerCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual(true, callArgs[0])
    }

    func testSetPillsEnabled_setsPillsEnabled() {
        let settings = createSettings()
        settings.setPillsEnabled(to: false)
        let callArgs = mockSettingsWriter.replaceStoredPillsEnabledCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual(false, callArgs[0])
    }

    func testReset_resets() {
        let settings = createSettings()
        settings.reset(defaultSiteCount: 2)
        let callArgs = mockSettingsWriter.resetCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual(2, callArgs[0])
    }
}
