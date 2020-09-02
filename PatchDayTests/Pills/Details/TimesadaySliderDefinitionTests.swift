//
//  TimesdaySliderDefinitionTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/30/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class TimesadaySliderDefinitionTests: XCTestCase {
    func testConvertTimesadayToSliderValue_whenTimesadayIsOne_returnsOne() {
        let expected = Float(1.0)
        let actual = TimesadaySliderDefinition.convertTimesadayToSliderValue(timesaday: 1)
        XCTAssertEqual(expected, actual)
    }

    func testConvertTimesadayToSliderValue_whenTimesadayIsGreaterThanOne_returnsTimesdayPlusTwo() {
        let expected = Float(5.0)
        let actual = TimesadaySliderDefinition.convertTimesadayToSliderValue(timesaday: 3)
        XCTAssertEqual(expected, actual)
    }

    func testConvertTimesadayToSliderValue_whenTimesadayIsZero_returnsOne() {
        let expected = Float(1.0)
        let actual = TimesadaySliderDefinition.convertTimesadayToSliderValue(timesaday: 0)
        XCTAssertEqual(expected, actual)
    }

    func testConvertSliderValueToTimesaday_whenSliderValueIsTwo_returnsTwo() {
        let expected = 2
        let actual = TimesadaySliderDefinition.convertSliderValueToTimesaday(sliderValue: 2.0)
        XCTAssertEqual(expected, actual)
    }

    func testConvertSliderValueToTimesaday_whenSliderValueIsGreaterThanTwo_returnsTwo() {
        let expected = 2
        let actual = TimesadaySliderDefinition.convertSliderValueToTimesaday(sliderValue: 2.3)
        XCTAssertEqual(expected, actual)
    }

    func testConvertSliderValueToTimesaday_whenSliderValueIsLessThanTwo_returnsOne() {
        let expected = 1
        let actual = TimesadaySliderDefinition.convertSliderValueToTimesaday(sliderValue: 1.3)
        XCTAssertEqual(expected, actual)
    }

    func testValueIsGreaterThanOne_onlyReturnsTrueWhenIsAboveThresholdOfTwo() {
        XCTAssertFalse(TimesadaySliderDefinition.valueIsGreaterThanOne(timesday: 1.01))
        XCTAssertFalse(TimesadaySliderDefinition.valueIsGreaterThanOne(timesday: 0.99))
        XCTAssertTrue(TimesadaySliderDefinition.valueIsGreaterThanOne(timesday: 2.0))
    }
}
