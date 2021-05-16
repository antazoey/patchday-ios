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

    func testOpen_selectsActivator() {
        let activator = UIButton()
        activator.isSelected = false
        let pickerView = SettingsPicker()
        pickerView.activator = activator
        pickerView.open()
        XCTAssertTrue(activator.isSelected)
    }
}
