//
//  SettingsPickerActivatorTests.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/19/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class SettingsPickerActivatorTests: XCTestCase {

    func testGetSettingFromButtonRestorationId_whenIsDeliveryMethodButtton_returnsDeliveryMethodSetting() {
        let button = SettingsPickerActivator()
        button.restorationIdentifier = "deliveryMethodButton"
        let actual = button.getSettingFromButtonRestorationId()
        XCTAssertEqual(.DeliveryMethod, actual)
    }

    func testGetSettingFromButtonRestorationId_whenIsExpirationIntervalArrowButtton_returnsDeliveryMethodSetting() {
        let button = SettingsPickerActivator()
        button.restorationIdentifier = "deliveryMethodArrowButton"
        let actual = button.getSettingFromButtonRestorationId()
        XCTAssertEqual(.DeliveryMethod, actual)
    }

    func testGetSettingFromButtonRestorationId_whenIsExpirationIntervalButtton_returnsExpirationIntervalSetting() {
        let button = SettingsPickerActivator()
        button.restorationIdentifier = "expirationIntervalButton"
        let actual = button.getSettingFromButtonRestorationId()
        XCTAssertEqual(.ExpirationInterval, actual)
    }

    func testGetSettingFromButtonRestorationId_whenIsDeliveryMethodArrowButtton_returnsExpirationIntervalSetting() {
        let button = SettingsPickerActivator()
        button.restorationIdentifier = "expirationIntervalArrowButton"
        let actual = button.getSettingFromButtonRestorationId()
        XCTAssertEqual(.ExpirationInterval, actual)
    }

    func testGetSettingFromButtonRestorationId_whenIsQuantityButtton_returnsQuantitySetting() {
        let button = SettingsPickerActivator()
        button.restorationIdentifier = "quantityButton"
        let actual = button.getSettingFromButtonRestorationId()
        XCTAssertEqual(.Quantity, actual)
    }

    func testGetSettingFromButtonRestorationId_whenIsQuantityArrowButtton_returnsQuantitySetting() {
        let button = SettingsPickerActivator()
        button.restorationIdentifier = "quantityArrowButton"
        let actual = button.getSettingFromButtonRestorationId()
        XCTAssertEqual(.Quantity, actual)
    }
}
