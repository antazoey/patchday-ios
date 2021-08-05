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
    let evaluation = equiv(expected, actual)
    let formattedExpected = PDDateFormatter.formatDate(expected)
    let formattedActual = PDDateFormatter.formatDate(actual)
    let failMessage = equivFailMessage(formattedExpected, formattedActual)
    XCTAssertTrue(evaluation, failMessage, file: file, line: line)
}

/// Assert two dates are not equivalent (.nanosecond granularity).
public func PDAssertNotEquiv(
    _ expected: Date, _ actual: Date, file: StaticString = #filePath, line: UInt = #line
) {
    let evaluation = equiv(expected, actual)
    let formattedExpected = PDDateFormatter.formatDate(expected)
    let formattedActual = PDDateFormatter.formatDate(actual)
    let failMessage = notEquivFailMessage(formattedExpected, formattedActual)
    XCTAssertFalse(evaluation, failMessage, file: file, line: line)
}

/// Assert two doubles are equivalent (0.01 granularity).
public func PDAssertEquiv(
    _ expected: Double, _ actual: Double, file: StaticString = #filePath, line: UInt = #line
) {
    let evaluation = equiv(expected, actual)
    let failMessage = equivFailMessage(expected, actual)
    XCTAssertTrue(evaluation, failMessage, file: file, line: line)
}

/// Assert two doubles are not equivalent (0.01 granularity).
public func PDAssertNotEquiv(
    _ expected: Double, _ actual: Double, file: StaticString = #filePath, line: UInt = #line
) {
    let evaluation = equiv(expected, actual)
    let failMessage = notEquivFailMessage(expected, actual)
    XCTAssertFalse(evaluation, failMessage, file: file, line: line)
}

/// Assert that the given date is equivalent to now (.nanosecond granularity).
public func PDAssertNow(_ actual: Date, file: StaticString = #filePath, line: UInt = #line) {
    let evaluation = equiv(Date(), actual)
    let formattedActual = PDDateFormatter.formatDate(actual)
    let failMessage = equivFailMessage("$NOW", formattedActual)
    XCTAssertTrue(evaluation, failMessage)
}

/// Assert that the given date is equivalent to the default date (.nanosecond granularity).
public func PDAssertDefault(_ actual: Date, file: StaticString = #filePath, line: UInt = #line) {
    let evaluation = equiv(DateFactory.createDefaultDate(), actual)
    let formattedActual = PDDateFormatter.formatDate(actual)
    let failMessage = equivFailMessage("<default-date>", formattedActual)
    XCTAssertTrue(evaluation, failMessage)
}

/// Assert that the given date is not equivalent to now (.nanosecond granularity).
public func PDAssertNotNow(_ actual: Date, file: StaticString = #filePath, line: UInt = #line) {
    let evaluation = equiv(Date(), actual)
    let formattedActual = PDDateFormatter.formatDate(actual)
    let failMessage = notEquivFailMessage("$NOW", formattedActual)
    XCTAssertFalse(evaluation, failMessage, file: file, line: line)
}

/// Assert that two dates have the same hours, minutes, and seconds.
public func PDAssertSameTime(
    _ expected: Time, _ actual: Time, file: StaticString = #filePath, line: UInt = #line
) {
    let evaluation = sameTime(expected, actual)
    let formattedExpected = PDDateFormatter.formatTime(expected)
    let formattedActual = PDDateFormatter.formatTime(actual)
    let failMessage = "\(formattedExpected) != \(formattedActual)"
    XCTAssertTrue(evaluation, failMessage, file: file, line: line)
}

/// Assert that two dates do not have the same hours, minutes, and seconds.
public func PDAssertDifferentTime(
    _ expected: Time, _ actual: Time, file: StaticString = #filePath, line: UInt = #line
) {
    let evaluation = sameTime(expected, actual)
    let formattedExpected = PDDateFormatter.formatTime(expected)
    let formattedActual = PDDateFormatter.formatTime(actual)
    let failMessage = "\(formattedExpected) == \(formattedActual)"
    XCTAssertFalse(evaluation, failMessage, file: file, line: line)
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

// MARK: Internal / Private Helpers

/// Returns true if the dates are within a nanosecond of each other.
public func equiv(_ lhs: Date, _ rhs: Date) -> Bool {
    Calendar.current.isDate(lhs, equalTo: rhs, toGranularity: .second)
}

/// Returns true if two doubles are equivalent.
public func equiv(_ lhs: Double, _ rhs: Double, _ granularity: Double = 0.01) -> Bool {
    abs(lhs - rhs) < granularity
}

/// Returns true if two dates have the same hour, minute, and second.
public func sameTime(_ lhs: Date, _ rhs: Date) -> Bool {
    let lhsComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: lhs)
    let rhsComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: rhs)
    return lhsComponents.hour == rhsComponents.hour
        && lhsComponents.minute == rhsComponents.minute
        && lhsComponents.second == rhsComponents.second
}

private func equivFailMessage(_ expected: Any, _ actual: Any) -> String {
    "\(expected) !~= \(actual)"
}

private func notEquivFailMessage(_ expected: Any, _ actual: Any) -> String {
    "\(expected) ~= \(actual)."
}
