//
// Created by Juliya Smith on 2/11/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

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
}
