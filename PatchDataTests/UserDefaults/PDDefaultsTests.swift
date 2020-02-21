//
// Created by Juliya Smith on 2/11/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchData


class PDDefaultsTests: XCTestCase {

    private let mockDefaultsWriter = MockUserDefaultsWriter()
    private let state = PDState()
    private let mockHormones = MockHormoneSchedule()
    private let mockSites = MockSiteSchedule()

    private func createDefaults() -> PDSettings {
        PDSettings(writer: mockDefaultsWriter, state: state, hormones: mockHormones, sites: mockSites)
    }

    func testSetDeliveryMethod_replacesMethod() {
        let defaults = createDefaults()  // Defaults to Patches
        defaults.setDeliveryMethod(to: .Injections)
        XCTAssert(mockDefaultsWriter.deliveryMethod.value == DeliveryMethod.Injections)
    }

    func testSetDeliveryMethod_sharedData() {
        let defaults = createDefaults()  // Defaults to Patches
        defaults.setDeliveryMethod(to: .Injections)
        let expected = 1
        let actual = mockHormones.shareDataCallCount
        XCTAssertEqual(expected, actual)
    }

    func testSetDeliveryMethod_updatesState() {
        let defaults = createDefaults()  // Defaults to Patches
        defaults.setDeliveryMethod(to: .Injections)
        XCTAssertTrue(state.theDeliveryMethodHasMutated)
    }

    func testSetQuantity_whenQuantityNotInSupportedRange_doesNotReplaceQuantity() {
        let defaults = createDefaults()
        let badNewQuantity = PickerOptions.quantities.count + 1
        defaults.setQuantity(to: badNewQuantity)
        XCTAssert(mockDefaultsWriter.quantity.rawValue != badNewQuantity)
    }

    func testSetQuantity_whenQuantityIsInSupportedRange_replacesQuantity() {
        let defaults = createDefaults()
        let newQuantity = PickerOptions.quantities.count
        defaults.setQuantity(to: newQuantity)
        XCTAssertEqual(newQuantity, mockDefaultsWriter.quantity.rawValue)
    }

    func testSetQuantity_whenQuantityIsIncreasing_fillsInHormones() {
        let defaults = createDefaults()  // Starts out at count of 4
        defaults.setQuantity(to: 2)
        defaults.setQuantity(to: 4)
        let expected = 4  // fillIn takes a count as the argument (it fills in hormones to reach the new count)
        let actual = mockHormones.fillInCallArgs[0]
        XCTAssertEqual(expected, actual)
    }

    func testSetQuantity_whenQuantityIsIncreasing_updatesState() {
        let defaults = createDefaults()  // Starts out at count of 4
        defaults.setQuantity(to: 2)
        defaults.setQuantity(to: 4)
        XCTAssertTrue(state.theQuantityHasIncreased)
        XCTAssertFalse(state.theQuantityHasDecreased)
    }

    func testSetQuantity_whenQuantityIsDecreasing_deletesHormones() {
        state.theQuantityHasIncreased = true
        let defaults = createDefaults()  // Starts out at count of 4
        defaults.setQuantity(to: 2)
        XCTAssertFalse(state.theQuantityHasIncreased)
        XCTAssertTrue(state.theQuantityHasDecreased)
    }
}
