//
// Created by Juliya Smith on 2/8/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class HormoneStringsTests: XCTestCase {

    private let expiredDate = Date(timeIntervalSinceNow: -86000)
    private let healthyDate = Date(timeIntervalSinceNow: 86400)

    private let formatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "h:mm a"; return f
    }()

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

    func testCreate_whenGivenExpiredPatch_returnsExpectedStrings() {
        let patch = createPatch(isExpired: true)
        let actual = HormoneStrings.create(patch)
        XCTAssertEqual("Expired: ", actual.expirationText)
    }

    func testCreate_whenGivenNonExpiredPatch_returnsExpectedStrings() {
        let patch = createPatch(isExpired: false)
        let actual = HormoneStrings.create(patch)
        XCTAssertEqual("Expires: ", actual.expirationText)
    }

    func testCreate_whenGivenPatchThatIsNotExpiredButIsPastNotificationTime_returnsExpectedString() {
        let patch = createHormone(isExpired: false)
        patch.isPastNotificationTime = true
        let actual = HormoneStrings.create(patch)
        XCTAssertEqual("Expires soon: ", actual.expirationText)
    }

    func testCreates_whenGivenExpiredInjection_returnsExpectedStrings() {
        let injection = createInjection(isExpired: true)
        let actual = HormoneStrings.create(injection)
        XCTAssertEqual("Next due: ", actual.expirationText)
    }

    func testCreate_whenGivenNonExpiredInjection_returnsExpectedStrings() {
        let injection = createInjection(isExpired: false)
        let actual = HormoneStrings.create(injection)
        XCTAssertEqual("Next due: ", actual.expirationText)
    }
}
