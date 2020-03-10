//
// Created by Juliya Smith on 2/8/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit
import PDMock

class ColonStringsTests: XCTestCase {

    private let expiredDate = Date(timeIntervalSinceNow: -86000)
    private let healthyDate = Date(timeIntervalSinceNow: 86400)

    private let formatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "h:mm a"; return f }()

    private func createPatch(isExpired: Bool) -> MockHormone {
        let patch = createHormone(isExpired: isExpired)
        patch.deliveryMethod = .Patches
        return patch
    }

    private func createInjection(isExpired: Bool) -> MockHormone {
        let injection = createHormone(isExpired: isExpired)
        injection.deliveryMethod = .Injections
        return injection
    }

    private func createHormone(isExpired: Bool) -> MockHormone {
        let hormone = MockHormone()
        hormone.expiration = isExpired ? expiredDate : healthyDate
        hormone.date = Date()
        hormone.isExpired = isExpired
        return hormone
    }

    func testGetDateTitle_whenGivenExpiredPatch_returnsStringFromExpiredDate() {
        let patch = createPatch(isExpired: true)
        let expectedDate = formatter.string(from: patch.expiration!)
        let expected = "Expired: Yesterday, \(expectedDate)"
        let actual = ColonStrings.getDateTitle(for: patch)
        XCTAssertEqual(expected, actual)
    }

    func testGetDateTitle_whenGivenNonExpiredPatch_returnsStringFromExpiredDate() {
        let patch = createPatch(isExpired: false)
        let expectedDate = formatter.string(from: patch.expiration!)
        let expected = "Expires: Tomorrow, \(expectedDate)"
        let actual = ColonStrings.getDateTitle(for: patch)
        XCTAssertEqual(expected, actual)
    }

    func testGetDateTitle_whenGivenExpiredInjection_returnsStringFromInjectionDate() {
        let injection = createInjection(isExpired: true)
        let expectedDate = formatter.string(from: injection.date)
        let expected = "Injected: Today, \(expectedDate)"
        let actual = ColonStrings.getDateTitle(for: injection)
        XCTAssertEqual(expected, actual)
    }

    func testGetDateTitle_whenGivenNonExpiredInjection_returnsStringFromInjectionDate() {
        let injection = createInjection(isExpired: false)
        let expectedDate = formatter.string(from: injection.date)
        let expected = "Injected: Today, \(expectedDate)"
        let actual = ColonStrings.getDateTitle(for: injection)
        XCTAssertEqual(expected, actual)
    }
}
