//
//  XDaysTests.swift
//  PDKit
//
//  Created by Juliya Smith on 2/9/21.

import Foundation

import XCTest
@testable
import PDKit

class PillIExpirationIntervalXDaysTests: XCTestCase {

    func testInit_whenGivenTwoValues_returnsObjectWithExpectedProperties() {
        let xDays = PillExpirationIntervalXDays("5-8")
        assertOneIsEqual(expected: 5, xDays)
        assertTwoIsEqual(expected: 8, xDays)
    }

    func testInit_whenGivenAStartedSchedule_returnsExpectedProperties() {
        let xDays = PillExpirationIntervalXDays("5-8-on-3")
        assertOneIsEqual(expected: 5, xDays)
        assertTwoIsEqual(expected: 8, xDays)
        XCTAssert(xDays.isOn!)
        XCTAssertEqual(3, xDays.position)
    }

    func testInit_whenGivenSingleOutBoundsString_doesNotSet() {
        let xDays = PillExpirationIntervalXDays("80")
        assertAllNil(xDays)
    }

    func testInit_whenGivenDoubleOutBoundsString_doesNotSet() {
        let xDays = PillExpirationIntervalXDays("80-80")
        assertAllNil(xDays)
    }

    func testInit_whenGivenDoubleStringWithFirstOneOutOfBounds_usesNil() {
        let xDays = PillExpirationIntervalXDays("50-8")
        assertOneIsNil(xDays)
        assertTwoIsEqual(expected: 8, xDays)
    }

    func testInit_whenGivenDoubleStringWithSecondOneOutOfBounds_usesDefaultValue() {
        let xDays = PillExpirationIntervalXDays("5-80")
        assertOneIsEqual(expected: 5, xDays)
        assertTwoIsNil(xDays)
    }

    func testInit_whenGivenStartedDoubleOutBoundsString_setsToNil() {
        let xDays = PillExpirationIntervalXDays("80-80-on-3")
        assertAllNil(xDays)
    }

    func testInit_whenGarbage_usesNil() {
        let xDays = PillExpirationIntervalXDays("asdifjaldfjs.alsjkd")
        assertAllNil(xDays)
    }

    func testInit_whenGivenOnStatusButNotPosition_doesNotInitOnStatusOrPosition() {
        let xDays = PillExpirationIntervalXDays("80-80-on")
        assertNilPosition(xDays)
    }

    func testInit_whenGivenPositionGreaterThanItsOnStatus_doesNotInitOnStatusOrPosition() {
        let xDays = PillExpirationIntervalXDays("2-4-on-3")
        assertNilPosition(xDays)
    }

    func testInit_whenGivenPositionGreaterThanItsOffStatus_doesNotInitOnStatusOrPosition() {
        let xDays = PillExpirationIntervalXDays("4-2-off-3")
        assertNilPosition(xDays)
    }

    func testIsOn_whenInitWithOn_returnsTrue() {
        let xDays = PillExpirationIntervalXDays("5-13-on-1")
        XCTAssert(xDays.isOn!)
    }

    func testIsOn_whenInitWithOff_returnsFalse() {
        let xDays = PillExpirationIntervalXDays("5-13-off-1")
        XCTAssertFalse(xDays.isOn!)
    }

    func testValue_whenInitializedWithoutPosition_doesNotIncludesStartPosition() {
        let expected = "5-13"
        let xDays = PillExpirationIntervalXDays("5-13")
        let actual = xDays.value
        XCTAssertEqual(expected, actual)
    }

    func testValue_reflectsUpdates() {
        let expected = "3-9-on-1"
        let xDays = PillExpirationIntervalXDays("5-13-on-1")
        xDays.one = 3
        xDays.two = 9
        let actual = xDays.value
        XCTAssertEqual(expected, actual)
    }

    func testValue_whenSettingSecondValue_retainsFirstValue() {
        let xDays = PillExpirationIntervalXDays("5-13-on-1")
        xDays.two = 4
        let expected = "5-4-on-1"
        let actual = xDays.value
        XCTAssertEqual(expected, actual)
    }

    func testValue_whenSettingToNil_removesSecondValueAndPreservesFirst() {
        let xDays = PillExpirationIntervalXDays("5-13-on-1")
        xDays.two = nil
        let expected = "5-on-1"
        let actual = xDays.value
        XCTAssertEqual(expected, actual)
    }

    func testOne_cannotBeSetOutsideLimit() {
        let xDays = PillExpirationIntervalXDays("5-13")
        xDays.one = -1
        assertOneIsEqual(expected: 5, xDays)
        xDays.one = 26
    }

    func testOne_canBeSetWithinTheLimit() {
        let xDays = PillExpirationIntervalXDays("5-13")
        xDays.one = 6
        assertOneIsEqual(expected: 6, xDays)
        xDays.one = 2
        assertOneIsEqual(expected: 2, xDays)
    }

    func testOne_whenSettingBelowTheCurrentPosition_setsPositionToDaysOffAt1() {
        let xDays = PillExpirationIntervalXDays("5-13-on-4")
        xDays.one = 3
        assertPosition(1, false, xDays)
    }

    func testOne_whenSettingAndOff_doesNotChangePosition() {
        let xDays = PillExpirationIntervalXDays("5-13-off-2")
        xDays.one = 1
        XCTAssertEqual(2, xDays.position)
    }

    func testTwo_whenValueIsOutOfBounds_canNotBeSet() {
        let xDays = PillExpirationIntervalXDays("5-13")
        xDays.two = -1
        assertTwoIsEqual(expected: 13, xDays)
        xDays.two = 26
        assertTwoIsEqual(expected: 13, xDays)
    }

    func testTwo_whenValueIsInBounds_canBeSet() {
        let xDays = PillExpirationIntervalXDays("5-13")
        xDays.two = 3
        assertTwoIsEqual(expected: 3, xDays)
        xDays.two = 5
        assertTwoIsEqual(expected: 5, xDays)    }

    func testTwo_whenSetting_maintainsOriginalDaysOneProperty() {
        let xDays = PillExpirationIntervalXDays("5-13")
        xDays.two = 3
        assertOneIsEqual(expected: 5, xDays)
    }

    func testTwo_whenSettingFromNil_maintainsDaysOne() {
        let xDays = PillExpirationIntervalXDays("5")
        xDays.two = 3
        assertOneIsEqual(expected: 5, xDays)
    }

    func testTwo_whenSettingFromNil_sets() {
        let xDays = PillExpirationIntervalXDays("5")
        xDays.two = 3
        assertTwoIsEqual(expected: 3, xDays)
    }

    func testTwo_whenSettingBelowTheCurrentPosition_setsPositionToNewDaysTwo() {
        let xDays = PillExpirationIntervalXDays("5-13-off-4")
        xDays.two = 3
        assertPosition(1, true, xDays)
    }

    func testOffMoreThanOneDay_whenOn_returnsFalse() {
        let xDays = PillExpirationIntervalXDays("5-13-on-4")
        XCTAssertFalse(xDays.offMoreThanOneDay)
    }

    func testOffMoreThanOneDay_whenOffAtFirstPosition_returnsFalse() {
        let xDays = PillExpirationIntervalXDays("5-13-off-1")
        XCTAssertFalse(xDays.offMoreThanOneDay)
    }

    func testOffMoreThanOneDay_whenOffAtPositionGreaterThanFirst_returnsTrue() {
        let xDays = PillExpirationIntervalXDays("5-13-off-2")
        XCTAssertTrue(xDays.offMoreThanOneDay)
    }

    func testStartPositioning_setsExpectedProperties() {
        let xDays = PillExpirationIntervalXDays("5-13")
        xDays.startPositioning()
        XCTAssert(xDays.isOn!)
        XCTAssertEqual(1, xDays.position)
    }

    func testIncrementDaysPosition_whenDoesNotHaveDayOne_doesNotIncrement() {
        let xDays = PillExpirationIntervalXDays("")
        xDays.incrementDayPosition()
        assertNilPosition(xDays)
    }

    func testIncrementDaysPosition_whenDoesNotHaveDayTwo_doesNotIncrement() {
        let xDays = PillExpirationIntervalXDays("5")
        xDays.incrementDayPosition()
        assertNilPosition(xDays)
    }

    func testIncrementDaysPosition_whenDoesNotHaveOnStatus_doesNotIncrement() {
        let xDays = PillExpirationIntervalXDays("5-5")
        xDays.incrementDayPosition()
        assertNilPosition(xDays)
    }

    func testIncrementDaysPosition_whenDoesNotHavePosition_doesNotIncrement() {
        let xDays = PillExpirationIntervalXDays("5-5-on")
        xDays.incrementDayPosition()
        assertNilPosition(xDays)
    }

    func testIncrementDaysPosition_increments() {
        let xDays = PillExpirationIntervalXDays("5-5-on-1")
        xDays.incrementDayPosition()
        XCTAssertEqual(2, xDays.position)
    }

    func testIncrementDaysPosition_maintainsOnStatusAsExpected() {
        let xDays = PillExpirationIntervalXDays("5-5-on-1")
        xDays.incrementDayPosition()
        XCTAssert(xDays.isOn!)
        xDays.incrementDayPosition()
        XCTAssert(xDays.isOn!)
        xDays.incrementDayPosition()
        XCTAssert(xDays.isOn!)
    }

    func testIncrementDaysPosition_whenDaysOnIncrementingPastThreshold_switchesToDaysOff() {
        let xDays = PillExpirationIntervalXDays("5-5-on-5")
        xDays.incrementDayPosition()
        XCTAssertFalse(xDays.isOn!)
        XCTAssertEqual(1, xDays.position)
    }

    func testIncrementDaysPosition_whenIsPenultimateOn_setsToLastOn() {
        let xDays = PillExpirationIntervalXDays("5-5-on-4")
        xDays.incrementDayPosition()
        XCTAssertTrue(xDays.isOn!)
        XCTAssertEqual(5, xDays.position)
    }

    func testIncrementDaysPosition_whenIsPenultimateOff_setsToLastOff() {
        let xDays = PillExpirationIntervalXDays("5-5-off-4")
        xDays.incrementDayPosition()
        XCTAssertFalse(xDays.isOn!)
        XCTAssertEqual(5, xDays.position)
    }

    func testIncrement_whenUsesNumberOfDaysParameter_incrementsNumberOfDays() {
        let xDays = PillExpirationIntervalXDays("5-5-off-4")
        xDays.incrementDayPosition(numberOfDays: 1)
        XCTAssertFalse(xDays.isOn!)
        XCTAssertEqual(5, xDays.position)
        xDays.incrementDayPosition(numberOfDays: 1)
        XCTAssertTrue(xDays.isOn!)
        XCTAssertEqual(1, xDays.position)
        xDays.incrementDayPosition(numberOfDays: 2)
        XCTAssertTrue(xDays.isOn!)
        XCTAssertEqual(3, xDays.position)
    }

    func testIncrement_whenIncrementingAcrossBoundaries_isExpected() {
        let xDays = PillExpirationIntervalXDays("5-8-on-4")
        xDays.incrementDayPosition(numberOfDays: 17)
        XCTAssertFalse(xDays.isOn!)
        XCTAssertEqual(3, xDays.position)
    }

    func testIncrement_whenGivenZero_isExpected() {
        let xDays = PillExpirationIntervalXDays("5-8-on-4")
        xDays.incrementDayPosition(numberOfDays: 0)
        XCTAssertTrue(xDays.isOn!)
        XCTAssertEqual(4, xDays.position)
    }

    func testDecrementDaysPosition_whenDoesNotHaveDayOne_doesNotDecrement() {
        let xDays = PillExpirationIntervalXDays("")
        xDays.decrementDayPosition()
        assertNilPosition(xDays)
    }

    func testDecrementDaysPosition_whenDoesNotHaveDayTwo_doesNotDecrement() {
        let xDays = PillExpirationIntervalXDays("5")
        xDays.decrementDayPosition()
        assertNilPosition(xDays)
    }

    func testDecrementDaysPosition_whenDoesNotHaveOnStatus_doesNotDecrement() {
        let xDays = PillExpirationIntervalXDays("5-5")
        xDays.decrementDayPosition()
        assertNilPosition(xDays)
    }

    func testDecrementDaysPosition_whenDoesNotHavePosition_doesNotDecrement() {
        let xDays = PillExpirationIntervalXDays("5-5-on")
        xDays.decrementDayPosition()
        assertNilPosition(xDays)
    }

    func testDecrementDaysPosition_decrements() {
        let xDays = PillExpirationIntervalXDays("5-5-on-2")
        xDays.decrementDayPosition()
        XCTAssertEqual(1, xDays.position)
    }

    func testDecrementDaysPosition_maintainsOnStatusAsExpected() {
        let xDays = PillExpirationIntervalXDays("5-5-on-5")
        xDays.decrementDayPosition()  // 4
        XCTAssert(xDays.isOn!)
        xDays.decrementDayPosition()  // 3
        XCTAssert(xDays.isOn!)
        xDays.decrementDayPosition()  // 2
        XCTAssert(xDays.isOn!)
    }

    func testDecrementDaysPosition_whenDaysOnDecrementingPastOnThreshold_switchesToDaysOffWithPositionOfTwo() {
        let xDays = PillExpirationIntervalXDays("3-5-on-1")  // .two is 5
        xDays.decrementDayPosition()
        XCTAssertFalse(xDays.isOn!)
        XCTAssertEqual(5, xDays.position)
    }

    func testDecrementDaysPosition_whenDaysOnDecrementingPastOffThreshold_switchesToDaysOnWithPositionOfOne() {
        let xDays = PillExpirationIntervalXDays("3-5-off-1")  // .one is 3
        xDays.decrementDayPosition()
        XCTAssertTrue(xDays.isOn!)
        XCTAssertEqual(3, xDays.position)
    }

    func testDecrementDaysPosition_whenIsLastOn_setsToPenultimateOn() {
        let xDays = PillExpirationIntervalXDays("5-5-on-5")
        xDays.decrementDayPosition()
        XCTAssertTrue(xDays.isOn!)
        XCTAssertEqual(4, xDays.position)
    }

    func testDecrementDaysPosition_whenIsLastOff_setsToPenultimateOff() {
        let xDays = PillExpirationIntervalXDays("5-5-off-5")
        xDays.decrementDayPosition()
        XCTAssertFalse(xDays.isOn!)
        XCTAssertEqual(4, xDays.position)
    }

    func testDecrement_whenUsesNumberOfDaysParameter_decrementsNumberOfDays() {
        let xDays = PillExpirationIntervalXDays("5-5-off-5")
        xDays.decrementDayPosition(numberOfDays: 4)
        XCTAssertFalse(xDays.isOn!)
        XCTAssertEqual(1, xDays.position)
    }

    func testDecrement_whenOffAndDecrementingAcrossBoundaries_isExpected() {
        var xDays = PillExpirationIntervalXDays("5-8-on-4")
        xDays.decrementDayPosition(numberOfDays: 13)
        XCTAssertTrue(xDays.isOn!)
        XCTAssertEqual(4, xDays.position)

        xDays = PillExpirationIntervalXDays("5-8-on-4")
        xDays.decrementDayPosition(numberOfDays: 10)
        XCTAssertFalse(xDays.isOn!)
        XCTAssertEqual(2, xDays.position)
    }

    private func assertAllNil(_ xDays: PillExpirationIntervalXDays) {
        assertOneIsNil(xDays)
        assertTwoIsNil(xDays)
    }

    private func assertOneIsNil(_ xDays: PillExpirationIntervalXDays) {
        XCTAssertNil(xDays.one)
        XCTAssertNil(xDays.daysOn)
    }

    private func assertTwoIsNil(_ xDays: PillExpirationIntervalXDays) {
        XCTAssertNil(xDays.daysOff)
        XCTAssertNil(xDays.two)
    }

    private func assertNilPosition(_ xDays: PillExpirationIntervalXDays) {
        XCTAssertNil(xDays.isOn)
        XCTAssertNil(xDays.position)
    }

    private func assertPosition(
        _ position: Int, _ isOn: Bool, _ xDays: PillExpirationIntervalXDays
    ) {
        XCTAssertEqual(position, xDays.position)
        XCTAssertEqual(isOn, xDays.isOn)
    }

    private func assertOneIsEqual(expected: Int, _ xDays: PillExpirationIntervalXDays) {
        XCTAssertEqual(expected, xDays.one)
        XCTAssertEqual("\(expected)", xDays.daysOn)
    }

    private func assertTwoIsEqual(expected: Int, _ xDays: PillExpirationIntervalXDays) {
        XCTAssertEqual(expected, xDays.two)
        XCTAssertEqual("\(expected)", xDays.daysOff)
    }
}
