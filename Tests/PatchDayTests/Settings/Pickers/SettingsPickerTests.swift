//
//  SettingsPickerTests.swift
//  PDTest
//
//  Created by Juliya Smith on 5/4/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class SettingsPickerTests: XCTestCase {

    func testSetActivator_setsSaveTitleForSelectedState() {
        let picker = SettingsPicker()
        let button = UIButton()
        picker.activator = button
        let expected = "Save"
        let actual = button.title(for: .selected)
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_returnsOptionAtIndex() {
        let picker = SettingsPicker()
        picker.setting = .Quantity
        XCTAssertEqual("1", picker[0].string)
        XCTAssertEqual("2", picker[1].string)
    }

    func testGetStartRow_defaultsToReturningZero() {
        let picker = SettingsPicker()
        let expected = 0
        let actual = picker.getStartRow()
        XCTAssertEqual(expected, actual)
    }

    func testGetStartRow_isSettable() {
        let picker = SettingsPicker()
        picker.getStartRow = { 1 }
        let expected = 1
        let actual = picker.getStartRow()
        XCTAssertEqual(expected, actual)
    }

    func testOptions_returnsExpectedOptions() {
        let expected = SettingsOptions.deliveryMethods
        let picker = SettingsPicker()
        picker.setting = .DeliveryMethod
        let actual = picker.options
        XCTAssertEqual(expected, actual)
    }

    func testCount_returnsExpectedOptions() {
        let expected = SettingsOptions.deliveryMethods.count
        let picker = SettingsPicker()
        picker.setting = .DeliveryMethod
        let actual = picker.count
        XCTAssertEqual(expected, actual)
    }

    func testView_returnsSameInstanceAsSelf() {
        let picker = SettingsPicker()
        XCTAssertEqual(picker, picker.view)
    }

    func testOpen_selectsActivator() {
        let activator = UIButton()
        activator.isSelected = false
        let picker = SettingsPicker()
        picker.activator = activator
        picker.open()
        XCTAssertTrue(activator.isSelected)
    }

    func testOpen_callsGetStartRow() {
        let picker = SettingsPicker()
        var didCall = false
        picker.getStartRow = {
            didCall = true
            return 0
        }
        picker.open()
        XCTAssertTrue(didCall)
    }
}
