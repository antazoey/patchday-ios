//
//  SettingsOptions.swift
//  PDKitTests
//
//  Created by Juliya Smith on 6/14/20.

import Foundation

import XCTest
@testable
import PDKit

// swiftlint:disable function_body_length
class SettingsOptionsTests: XCTestCase {

    func testXDaysValues_isExpectedRange() {
        let expected = [
            "1.0",
            "1.5",
            "2.0",
            "2.5",
            "3.0",
            "3.5",
            "4.0",
            "4.5",
            "5.0",
            "5.5",
            "6.0",
            "6.5",
            "7.0",
            "7.5",
            "8.0",
            "8.5",
            "9.0",
            "9.5",
            "10.0",
            "10.5",
            "11.0",
            "11.5",
            "12.0",
            "12.5",
            "13.0",
            "13.5",
            "14.0",
            "14.5",
            "15.0",
            "15.5",
            "16.0",
            "16.5",
            "17.0",
            "17.5",
            "18.0",
            "18.5",
            "19.0",
            "19.5",
            "20.0",
            "20.5",
            "21.0",
            "21.5",
            "22.0",
            "22.5",
            "23.0",
            "23.5",
            "24.0",
            "24.5",
            "25.0",
            "25.5"
        ]
        let actual = SettingsOptions.xDaysValues
        XCTAssertEqual(expected, actual)
    }

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

    func testGetExpirationInterval_whenGivenEveryXDays_returnsExpectedInterval() {
        let actual = SettingsOptions.getExpirationInterval(for: SettingsOptions.EveryXDays)
        XCTAssertEqual(.EveryXDays, actual)
    }

    func testGetExpirationInterval_whenGivenOnceDaily_returnsExpectedString() {
        let expected = SettingsOptions.OnceDaily
        XCTAssertEqual(expected, SettingsOptions.getExpirationInterval(for: .OnceDaily))
    }

    func testGetExpirationInterval_whenGivenTwiceWeekly_returnsExpectedString() {
        let expected = SettingsOptions.TwiceWeekly
        XCTAssertEqual(expected, SettingsOptions.getExpirationInterval(for: .TwiceWeekly))
    }

    func testGetExpirationInterval_whenGivenOnceWeekly_returnsExpectedString() {
        let expected = SettingsOptions.OnceWeekly
        XCTAssertEqual(expected, SettingsOptions.getExpirationInterval(for: .OnceWeekly))
    }

    func testGetExpirationInterval_whenGivenEveryTwoWeeks_returnsExpectedString() {
        let expected = SettingsOptions.OnceEveryTwoWeeks
        let actual = SettingsOptions.getExpirationInterval(for: .EveryTwoWeeks)
        XCTAssertEqual(expected, actual)
    }

    func testGetExpirationInterval_whenGivenEveryXDays_returnsExpectedString() {
        let expected = SettingsOptions.EveryXDays
        XCTAssertEqual(expected, SettingsOptions.getExpirationInterval(for: .EveryXDays))
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

    func testSubscript_whenGivenXDays_returnsXDaysValues() {
        let expected = SettingsOptions.xDaysValues
        let actual = SettingsOptions[.XDays]
        XCTAssertEqual(expected, actual)
    }
}
