//
//  ExpirationIntervalPickerTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/16/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class ExpirationIntervalPickerTests: XCTestCase {

    func testForIntervals_returnsSelfWithExpectedProperties() {
        let indexer = MockSettingsPickerIndexer()
        indexer.expirationIntervalStartIndex = 3
        let picker = ExpirationInteravlSettingsPicker()
        picker.indexer = indexer
        let actual = picker.forIntervals
        XCTAssertEqual(picker, actual as! ExpirationInteravlSettingsPicker)
        XCTAssertEqual(.ExpirationInterval, actual.setting)
        XCTAssertEqual(SettingsOptions.expirationIntervals, actual.options)
        XCTAssertEqual(3, picker.getStartRow())
    }

    func testForXDays_returnsSelfWithExpectedProperties() {
        let indexer = MockSettingsPickerIndexer()
        indexer.xDaysStartIndex = 5
        let picker = ExpirationInteravlSettingsPicker()
        picker.indexer = indexer
        let actual = picker.forXDays
        XCTAssertEqual(picker, actual as! ExpirationInteravlSettingsPicker)
        XCTAssertEqual(.XDays, actual.setting)
        XCTAssertEqual(SettingsOptions.xDaysValues, actual.options)
        XCTAssertEqual(5, picker.getStartRow())
    }
}
