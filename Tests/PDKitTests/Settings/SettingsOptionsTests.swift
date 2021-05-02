//
//  SettingsOptions.swift
//  PDKitTests
//
//  Created by Juliya Smith on 6/14/20.

import Foundation

import XCTest
@testable
import PDKit

class SettingsOptionsTests: XCTestCase {
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
}
