//
// Created by Juliya Smith on 2/8/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class HormoneStringsTests: PDTestCase {

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

    func testCreate_whenGivenExpiredPatchs() {
        let patch = createPatch(isExpired: true)
        let actual = HormoneStrings.create(patch)
        XCTAssertEqual("Expiration:", actual.expirationText)
    }

    func testCreate_whenGivenNonExpiredPatchs() {
        let patch = createPatch(isExpired: false)
        let actual = HormoneStrings.create(patch)
        XCTAssertEqual("Expiration:", actual.expirationText)
    }

    func testCreate_whenGivenPatchThatIsNotExpiredButIsPastNotificationTime() {
        let patch = createHormone(isExpired: false)
        patch.isPastNotificationTime = true
        let actual = HormoneStrings.create(patch)
        XCTAssertEqual("Expiration:", actual.expirationText)
    }

    func testCreates_whenGivenExpiredInjections() {
        let injection = createInjection(isExpired: true)
        let actual = HormoneStrings.create(injection)
        XCTAssertEqual("Next:", actual.expirationText)
    }

    func testCreate_whenGivenNonExpiredInjections() {
        let injection = createInjection(isExpired: false)
        let actual = HormoneStrings.create(injection)
        XCTAssertEqual("Next:", actual.expirationText)
    }

    func testGetExpirationDateText_whenDateWithinSevenDays_returnsFormattedDay() {
        let date = Date()
        let expected = PDDateFormatter.formatDay(date)
        let actual = HormoneStrings.getExpirationDateText(expiration: date)
        XCTAssertEqual(expected, actual)
    }

    func testGetExpirationDateText_whenDateMoreThanSevenDaysAgo_returnsFormattedDate() {
        let date = DateFactory.createDate(byAddingMonths: -1, to: Date())!
        let expected = PDDateFormatter.formatDate(date)
        let actual = HormoneStrings.getExpirationDateText(expiration: date)
        XCTAssertEqual(expected, actual)
    }

    func testGetExpirationDateText_whenDateThanSevenDaysAway_returnsFormattedDate() {
        let date = DateFactory.createDate(byAddingHours: Hours.IN_TWO_WEEKS, to: Date())!
        let expected = PDDateFormatter.formatDate(date)
        let actual = HormoneStrings.getExpirationDateText(expiration: date)
        XCTAssertEqual(expected, actual)
    }
}
