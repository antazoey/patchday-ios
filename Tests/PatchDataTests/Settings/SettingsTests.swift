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
        let actual = mockSettingsWriter.replaceDeliveryMethodCallArgs[0]
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

        let callArgs = mockSettingsWriter.replaceQuantityCallArgs
        if callArgs.count < 1 {
            XCTFail("Set quantity was never called")
            return
        }
        XCTAssertEqual(DefaultQuantities.Hormone[.Patches], callArgs[0])
    }

    func testSetDeliveryMethod_whenSettingToInjections_setsQuantityToDefault() {
        let settings = createSettings()

        settings.setDeliveryMethod(to: .Injections)

        let callArgs = mockSettingsWriter.replaceQuantityCallArgs
        if callArgs.count < 1 {
            XCTFail("Set quantity was never called")
            return
        }
        XCTAssertEqual(DefaultQuantities.Hormone[.Injections], callArgs[0])
    }

    func testSetDeliveryMethod_whenSettingToGel_setsQuantityToDefault() {
        let settings = createSettings()

        settings.setDeliveryMethod(to: .Gel)

        let callArgs = mockSettingsWriter.replaceQuantityCallArgs
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
        settings.setExpirationInterval(to: SettingsOptions.OnceDaily)
        settings.setExpirationInterval(to: SettingsOptions.OnceWeekly)

        let callArgs = mockSettingsWriter.replaceExpirationIntervalCallArgs
        XCTAssertEqual(3, callArgs.count)
        XCTAssertEqual(.EveryTwoWeeks, callArgs[0])
        XCTAssertEqual(.OnceDaily, callArgs[1])
        XCTAssertEqual(.OnceWeekly, callArgs[2])
    }

    func testSetExpirationInterval_whenSettingACustomInterval_setsExpectedInterval() {
        let settings = createSettings()
        settings.setExpirationInterval(to: "Every 4.5 Days")
        let callArgs = mockSettingsWriter.replaceExpirationIntervalCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(.EveryXDays, callArgs[0])
    }

    func testSetExpirationInterval_whenSettingACustomInterval_setsExpectedIntervalDays() {
        let settings = createSettings()
        settings.setExpirationInterval(to: "Every 4½ Days")
        let callArgs = mockSettingsWriter.replaceXDaysCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual("4.5", callArgs[0])
    }

    func testSetExpirationInterval_whenSettingACustomIntervalWithAHalfMark_setsExpectedIntervalDays() {
        let settings = createSettings()
        settings.setExpirationInterval(to: "Every 4½ Days")
        let callArgs = mockSettingsWriter.replaceXDaysCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual("4.5", callArgs[0])
    }

    func testSetExpirationInterval_whenSettingACustomIntervalWithDoubleDigitDays_setsExpectedIntervalDays() {
        let settings = createSettings()
        settings.setExpirationInterval(to: "Every 14 Days")
        let callArgs = mockSettingsWriter.replaceXDaysCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual("14.0", callArgs[0])
    }

    func testSetSiteIndex_setsSiteIndex() {
        let settings = createSettings()
        settings.setSiteIndex(to: 3)
        let callArgs = mockSettingsWriter.replaceSiteIndexCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(3, callArgs[0])
    }

    func testSetNotifications_setsNotifications() {
        let settings = createSettings()
        settings.setNotifications(to: false)
        let callArgs = mockSettingsWriter.replaceNotificationsCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(false, callArgs[0])
    }

    func testSetNotificationsMinutesBefore_setsNotificationsMinutesBefore() {
        let settings = createSettings()
        settings.setNotificationsMinutesBefore(to: 32)
        let callArgs = mockSettingsWriter.replaceNotificationsMinutesBeforeCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(32, callArgs[0])
    }

    func testSetMentionedDisclaimer_setsMentionedDisclaimer() {
        let settings = createSettings()
        settings.setMentionedDisclaimer(to: true)
        let callArgs = mockSettingsWriter.replaceMentionedDisclaimerCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(true, callArgs[0])
    }

    func testSetPillsEnabled_setsPillsEnabled() {
        let settings = createSettings()
        settings.setPillsEnabled(to: false)
        let callArgs = mockSettingsWriter.replacePillsEnabledCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(false, callArgs[0])
    }

    func testReset_resets() {
        let settings = createSettings()
        settings.reset(defaultSiteCount: 2)
        let callArgs = mockSettingsWriter.resetCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(2, callArgs[0])
    }
}
