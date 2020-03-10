//
// Created by Juliya Smith on 2/11/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchData


class PDSettingsTests: XCTestCase {

    private let mockSettingsWriter = MockUserDefaultsWriter()
    private let state = PDState()
    private let mockHormones = MockHormoneSchedule()
    private let mockSites = MockSiteSchedule()

    private func createSettings() -> PDSettings {
        PDSettings(
            writer: mockSettingsWriter, state: state, hormones: mockHormones, sites: mockSites
        )
    }

    func testSetDeliveryMethod_replacesMethod() {
        let settings = createSettings()  // Defaults to Patches
        settings.setDeliveryMethod(to: .Injections)
        XCTAssert(mockSettingsWriter.replaceStoredDeliveryMethodCallArgs[0] == DeliveryMethod.Injections)
    }

    func testSetDeliveryMethod_sharedData() {
        let settings = createSettings()  // Defaults to Patches
        settings.setDeliveryMethod(to: .Injections)
        let expected = 1
        let actual = mockHormones.shareDataCallCount
        XCTAssertEqual(expected, actual)
    }

    func testSetDeliveryMethod_updatesState() {
        let settings = createSettings()  // Defaults to Patches
        settings.setDeliveryMethod(to: .Injections)
        XCTAssertTrue(state.theDeliveryMethodHasMutated)
    }
    
    func testSetDeliveryMethod_resetsSites() {
        let settings = createSettings()
        settings.setDeliveryMethod(to: .Injections)
        XCTAssert(mockSites.resetCallCount == 1)
    }

    func testSetQuantity_whenQuantityNotInSupportedRange_doesNotReplaceQuantity() {
        let settings = createSettings()
        let badNewQuantity = PickerOptions.quantities.count + 1
        settings.setQuantity(to: badNewQuantity)
        XCTAssert(mockSettingsWriter.quantity.rawValue != badNewQuantity)
    }

    func testSetQuantity_whenQuantityIsInSupportedRange_replacesQuantity() {
        let settings = createSettings()
        let newQuantity = PickerOptions.quantities.count
        settings.setQuantity(to: newQuantity)
        XCTAssertEqual(newQuantity, mockSettingsWriter.quantity.rawValue)
    }

    func testSetQuantity_whenQuantityIsIncreasing_fillsInHormones() {
        let settings = createSettings()  // Starts out at count of 4
        mockSettingsWriter.quantity = QuantityUD(2)
        settings.setQuantity(to: 2)
        settings.setQuantity(to: 4)
        
        let expected = 4  // fillIn takes a count as the argument (it fills in hormones to reach the new count)
        let actual = mockHormones.fillInCallArgs[0]
        XCTAssertEqual(expected, actual)
    }

    func testSetQuantity_whenQuantityIsIncreasing_updatesState() {
        let settings = createSettings()  // Starts out at count of 4
        settings.setQuantity(to: 2)
        settings.setQuantity(to: 4)
        XCTAssertTrue(state.theQuantityHasIncreased)
        XCTAssertFalse(state.theQuantityHasDecreased)
    }

    func testSetQuantity_whenQuantityIsDecreasing_deletesHormones() {
        state.theQuantityHasIncreased = true
        let settings = createSettings()  // Starts out at count of 4
        settings.setQuantity(to: 2)
        XCTAssertFalse(state.theQuantityHasIncreased)
        XCTAssertTrue(state.theQuantityHasDecreased)
    }
}
