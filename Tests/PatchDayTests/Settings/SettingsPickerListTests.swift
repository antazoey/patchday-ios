//
//  SettingsPickerListTests.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class SettingsPickerListTests: XCTestCase {
    private let quantityPicker = MockSettingsPicker()
    private let deliveryMethodPicker = MockSettingsPicker()
    private let expirationIntervalPicker = MockSettingsPicker()

    public var list: SettingsPickerList {
        SettingsPickerList(
            quantityPicker: quantityPicker,
            deliveryMethodPicker: deliveryMethodPicker,
            expirationIntervalPicker: expirationIntervalPicker
        )
    }

    func testAll_returnsPickersFromInit() {
        XCTAssertEqual(quantityPicker, list.all[0] as! MockSettingsPicker)
        XCTAssertEqual(deliveryMethodPicker, list.all[1] as! MockSettingsPicker)
        XCTAssertEqual(expirationIntervalPicker, list.all[2] as! MockSettingsPicker)
    }

    func testSubscript_whenGivenQuantity_returnsQuantityPicker() {
        XCTAssertEqual(quantityPicker, list[.Quantity] as! MockSettingsPicker)
    }

    func testSubscript_whenGivenDeliveryMethod_returnsDeliveryMethodPicker() {
        XCTAssertEqual(deliveryMethodPicker, list[.DeliveryMethod] as! MockSettingsPicker)
    }

    func testSubscript_whenGivenExpirationInterval_returnsExpirationIntervalPicker() {
        XCTAssertEqual(expirationIntervalPicker, list[.ExpirationInterval] as! MockSettingsPicker)
    }

    func testSubscript_whenGivenSettingsWithNoPicker_returnsNil() {
        XCTAssertNil(list[.Notifications])
        XCTAssertNil(list[.NotificationsMinutesBefore])
        XCTAssertNil(list[.PillsEnabled])
    }

    func testSelect_whenGiveSettingsWithNoPicker_returnsNil() {
        XCTAssertNil(list.select(.Notifications))
        XCTAssertNil(list.select(.NotificationsMinutesBefore))
        XCTAssertNil(list.select(.PillsEnabled))
    }

    func testSelect_closesPickersWithoutSelectingRowsExceptPickerOfGivenSetting() {
        list.select(.DeliveryMethod)
        let quantityCallArgs = quantityPicker.closeCallArgs
        let deliveryMethodCallArgs = deliveryMethodPicker.closeCallArgs
        let expirationIntervalCallArgs = expirationIntervalPicker.closeCallArgs
        PDAssertSingle(false, quantityCallArgs)
        PDAssertEmpty(deliveryMethodCallArgs)
        PDAssertSingle(false, expirationIntervalCallArgs)
    }

    func testSelect_returnsPickerForSetting() {
        let actual = list.select(.DeliveryMethod) as! MockSettingsPicker
        let expected = deliveryMethodPicker
        XCTAssertEqual(expected, actual)
    }
}
