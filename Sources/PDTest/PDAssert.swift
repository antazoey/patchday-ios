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
public func PDAssertEquiv(
    _ expected: Date, _ actual: Date, file: StaticString = #filePath, line: UInt = #line
) {
    let failMessage = equivFailMessage(expected, actual)
    XCTAssertTrue(equiv(expected, actual), failMessage, file: file, line: line)
}

/// Assert two dates are not equivalent (.nanosecond granularity).
public func PDAssertNotEquiv(
    _ expected: Date, _ actual: Date, file: StaticString = #filePath, line: UInt = #line
) {
    let failMessage = notEquivFailMessage(expected, actual)
    XCTAssertFalse(equiv(expected, actual), failMessage, file: file, line: line)
}

/// Assert two doubles are equivalent (0.01 granularity).
public func PDAssertEquiv(
    _ expected: Double, _ actual: Double, file: StaticString = #filePath, line: UInt = #line
) {
    let failMessage = equivFailMessage(expected, actual)
    XCTAssertTrue(equiv(expected, actual), failMessage, file: file, line: line)
}

/// Assert two doubles are not equivalent (0.01 granularity).
public func PDAssertNotEquiv(
    _ expected: Double, _ actual: Double, file: StaticString = #filePath, line: UInt = #line
) {
    let failMessage = notEquivFailMessage(expected, actual)
    XCTAssertFalse(equiv(expected, actual), failMessage, file: file, line: line)
}

/// Assert that the given date is equivalent to now (.nanosecond granularity).
public func PDAssertNow(_ actual: Date, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(equiv(Date(), actual), equivFailMessage("$NOW", actual))
}

/// Assert that the given date is not equivalent to now (.nanosecond granularity).
public func PDAssertNotNow(_ actual: Date, file: StaticString = #filePath, line: UInt = #line) {
    let failMessage = notEquivFailMessage("$NOW", actual)
    XCTAssertFalse(equiv(Date(), actual), failMessage, file: file, line: line)
}

/// Assert that two dates have the same hours, minutes, and seconds.
public func PDAssertSameTime(
    _ expected: Time, _ actual: Time, file: StaticString = #filePath, line: UInt = #line
) {
    let failMessage = "\(expected) does not have same time as \(actual)"
    XCTAssertTrue(sameTime(expected, actual), failMessage, file: file, line: line)
}

/// Assert that two dates do not have the same hours, minutes, and seconds.
public func PDAssertDifferentTime(
    _ expected: Time, _ actual: Time, file: StaticString = #filePath, line: UInt = #line
) {
    let failMessage = "\(expected) has the same time as \(actual)"
    XCTAssertFalse(sameTime(expected, actual), failMessage, file: file, line: line)
}

/// Assert that an array has a single item.
public func PDAssertSingle<T>(
    _ collection: [T], file: StaticString = #filePath, line: UInt = #line
) {
    let failMessage = "The array does not have only 1 item in it"
    XCTAssertEqual(1, collection.count, failMessage, file: file, line: line)
}

/// Assert that an array has a single, specific item.
public func PDAssertSingle<T: Equatable>(
    _ expected: T, _ collection: [T], file: StaticString = #filePath, line: UInt = #line
) {
    let countFailMessage = "The array does not have only 1 item in it"
    XCTAssertEqual(1, collection.count, countFailMessage, file: file, line: line)

    if collection.count < 1 {
        XCTFail(countFailMessage, file: file, line: line)
        return
    }

    XCTAssertEqual(expected, collection[0], file: file, line: line)
}

/// Assert that an array is empty.
public func PDAssertEmpty<T>(
    _ collection: [T], file: StaticString = #filePath, line: UInt = #line
) {
    let failMessage = "The array is not empty"
    XCTAssertEqual(0, collection.count, failMessage, file: file, line: line)
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
