//
//  PDAssert.swift
//  PDTest
//
//  Created by Juliya Smith on 5/16/20.

import Foundation
import PDKit
import XCTest

// MARK: - Public Assert Methods

/// Assert two dates are equivalent (.nanosecond granularity).
public func PDAssertEquiv(_ expected: Date, _ actual: Date) {
    XCTAssertTrue(equiv(expected, actual), equivFailMessage(expected, actual))
}

/// Assert two dates are not equivalent (.nanosecond granularity).
public func PDAssertNotEquiv(_ expected: Date, _ actual: Date) {
    XCTAssertFalse(equiv(expected, actual), notEquivFailMessage("$NOW", actual))
}

/// Assert two doubles are equivalent (0.01 granularity).
public func PDAssertEquiv(_ expected: Double, _ actual: Double) {
    XCTAssertTrue(equiv(expected, actual), equivFailMessage(expected, actual))
}

/// Assert two doubles are not equivalent (0.01 granularity).
public func PDAssertNotEquiv(_ expected: Double, _ actual: Double) {
    XCTAssertFalse(equiv(expected, actual), notEquivFailMessage(expected, actual))
}

/// Assert that the given date is equivalent to now (.nanosecond granularity).
public func PDAssertNow(_ actual: Date) {
    XCTAssertTrue(equiv(Date(), actual), equivFailMessage("$NOW", actual))
}

/// Assert that the given date is not equivalent to now (.nanosecond granularity).
public func PDAssertNotNow(_ actual: Date) {
    XCTAssertFalse(equiv(Date(), actual), notEquivFailMessage("$NOW", actual))
}

/// Asserts that two dates have the same hours, minutes, and seconds.
public func PDAssertSameTime(_ expected: Time, _ actual: Time) {
    let failMessage = "\(expected) does not have same time as \(actual)"
    XCTAssertTrue(sameTime(expected, actual), failMessage)
}

/// Asserts that two dates do nit have the same hours, minutes, and seconds.
public func PDAssertDifferentTime(_ expected: Time, _ actual: Time) {
    let failMessage = "\(expected) has the same time as \(actual)"
    XCTAssertFalse(sameTime(expected, actual), failMessage)
}

// MARK: Private Helpers

private func equivFailMessage(_ expected: Any, _ actual: Any) -> String {
    "\(expected) !~= \(actual)"
}

private func notEquivFailMessage(_ expected: Any, _ actual: Any) -> String {
    "\(expected) ~= \(actual)."
}

/// Returns true if the dates are within a nanosecond of each other.
func equiv(_ d1: Date, _ d2: Date) -> Bool {
    Calendar.current.isDate(d1, equalTo: d2, toGranularity: .nanosecond)
}

/// Returns true if two doubles are equivalent.
func equiv(_ d1: Double, _ d2: Double, _ granularity: Double = 0.01) -> Bool {
    abs(d1 - d2) < granularity
}

/// Returns true if two dates have the same hour, minute, and second.
func sameTime(_ t1: Date, _ t2: Date) -> Bool {
    let c1 = Calendar.current.dateComponents([.hour, .minute, .second], from: t1)
    let c2 = Calendar.current.dateComponents([.hour, .minute, .second], from: t2)
    let h1 = c1.hour
    let h2 = c2.hour
    let m1 = c1.minute
    let m2 = c2.minute
    let s1 = c1.second
    let s2 = c2.second
    return h1 == h2 && m1 == m2 && s1 == s2
}
