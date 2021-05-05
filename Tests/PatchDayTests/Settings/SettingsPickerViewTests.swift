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

    func testSubscript_returnsOptionAtIndex() {
        let pickerView = SettingsPicker()
        pickerView.options = ["foo", "bar"]
        XCTAssertEqual("foo", pickerView[0].string)
        XCTAssertEqual("bar", pickerView[1].string)
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
