//
//  SettingsOptions.swift
//  PDKitTests
//
//  Created by Juliya Smith on 6/14/20.

import Foundation
import XCTest
import PDTest
@testable
import PDKit

class SettingsOptionsTests: PDTestCase {

    func testGetExpirationInterval_whenGivenOnceDaily_returnsExpectedInterval() {
        let actual = SettingsOptions.getExpirationInterval(for: SettingsOptions.OnceDaily)
        XCTAssertEqual(.OnceDaily, actual)
    }

    func testGetExpirationInterval_whenGivenTwiceWeekly_returnsExpectedInterval() {
        let actual = SettingsOptions.getExpirationInterval(for: SettingsOptions.TwiceWeekly)
        XCTAssertEqual(.TwiceWeekly, actual)
    }

    func testGetExpirationInterval_whenGivenOnceWeekly_returnsExpectedInterval() {
        let actual = SettingsOptions.getExpirationInterval(for: SettingsOptions.OnceWeekly)
        XCTAssertEqual(.OnceWeekly, actual)
    }

    func testGetExpirationInterval_whenGivenEveryTwoWeeks_returnsExpectedInterval() {
        let actual = SettingsOptions.getExpirationInterval(for: SettingsOptions.OnceEveryTwoWeeks)
        XCTAssertEqual(.EveryTwoWeeks, actual)
    }

    func testGetExpirationInterval_whenGivenOnceDaily_returnsExpectedString() {
        let expected = SettingsOptions.OnceDaily
        let interval = ExpirationIntervalUD(.OnceDaily)
        XCTAssertEqual(expected, SettingsOptions.getExpirationInterval(for: interval))
    }

    func testGetExpirationInterval_whenGivenTwiceWeekly_returnsExpectedString() {
        let expected = SettingsOptions.TwiceWeekly
        let interval = ExpirationIntervalUD(.TwiceWeekly)
        XCTAssertEqual(expected, SettingsOptions.getExpirationInterval(for: interval))
    }

    func testGetExpirationInterval_whenGivenOnceWeekly_returnsExpectedString() {
        let expected = SettingsOptions.OnceWeekly
        let interval = ExpirationIntervalUD(.OnceWeekly)
        XCTAssertEqual(expected, SettingsOptions.getExpirationInterval(for: interval))
    }

    func testGetExpirationInterval_whenGivenEveryTwoWeeks_returnsExpectedString() {
        let expected = SettingsOptions.OnceEveryTwoWeeks
        let interval = ExpirationIntervalUD(.EveryTwoWeeks)
        let actual = SettingsOptions.getExpirationInterval(for: interval)
        XCTAssertEqual(expected, actual)
    }

    func testGetExpirationInterval_whenGivenCustom_returnsExpectedString() {
        let testInterval = ExpirationIntervalUD(.EveryXDays)
        testInterval.xDays.rawValue = "1.5"
        XCTAssertEqual("Every 1½ Days", SettingsOptions.getExpirationInterval(for: testInterval))
        testInterval.xDays.rawValue = "2.5"
        XCTAssertEqual("Every 2½ Days", SettingsOptions.getExpirationInterval(for: testInterval))
        testInterval.xDays.rawValue = "20.0"
        XCTAssertEqual("Every 20 Days", SettingsOptions.getExpirationInterval(for: testInterval))
    }

    func testSubscript_whenGivenDeliveryMethod_returnsDeliveryMethodOptions() {
        let expected = SettingsOptions.deliveryMethods
        let actual = SettingsOptions[.DeliveryMethod]
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_whenGivenExpirationInterval_returnsExpirationIntervals() {
        let expected = SettingsOptions.expirationIntervals
        let actual = SettingsOptions[.ExpirationInterval]
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_whenGivenQuantity_returnsQuantities() {
        let expected = SettingsOptions.quantities
        let actual = SettingsOptions[.Quantity]
        XCTAssertEqual(expected, actual)
    }
}
