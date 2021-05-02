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
        XCTAssertEqual(.OnceDaily, SettingsOptions.getExpirationInterval(for: "Once Daily"))
    }

    func testGetExpirationInterval_whenGivenTwiceWeekly_returnsExpectedInterval() {
        XCTAssertEqual(.TwiceWeekly, SettingsOptions.getExpirationInterval(for: "Twice Weekly"))
    }

    func testGetExpirationInterval_whenGivenOnceWeekly_returnsExpectedInterval() {
        XCTAssertEqual(.OnceWeekly, SettingsOptions.getExpirationInterval(for: "Once Weekly"))
    }

    func testGetExpirationInterval_whenGivenEveryTwoWeeks_returnsExpectedInterval() {
        let actual = SettingsOptions.getExpirationInterval(for: "Once Every Two Weeks")
        XCTAssertEqual(.EveryTwoWeeks, actual)
    }
}
