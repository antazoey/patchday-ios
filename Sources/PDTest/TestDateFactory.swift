//
//  TestUtil.swift
//  PDTest
//
//  Created by Juliya Smith on 8/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import XCTest
import PDKit

public class TestDateFactory {

    /// Attempts to create midnight. If it fails, calls `XCTFail()` and returns the default date.
    public static func createTestMidnight(date: Date?=nil, now: NowProtocol?=nil, file: StaticString=#filePath, line: UInt=#line) -> Date {
        let date = date ?? now?.now ?? Date()
        guard let midnight = DateFactory.createMidnight(of: date, now: now) else {
            XCTFail("Failed to create midnight")
            return DateFactory.createDefaultDate()
        }
        return midnight
    }

    /// Attempts to create the date with the specified parameters. If it fails, calls `XCTFail()` and returns the default date.
    public static func createTestDate(
        hour: Int=0,
        minute: Int=0,
        second: Int=0,
        date: Date?=nil,
        now: NowProtocol?=nil,
        file: StaticString=#filePath,
        line: UInt=#line
    ) -> Date {
        let date = date ?? now?.now ?? Date()
        guard let testDate = DateFactory.createDate(
                date, hour: hour, minute: minute, second: second
        ) else {
            XCTFail("Failed to create testDate")
            return DateFactory.createDefaultDate()
        }
        return testDate
    }

    /// Attempts to create a date exactly yesterday. If it fails, calls `XCTFail()` and returns the default date.
    public static func createYesterday(
        file: StaticString=#filePath, line: UInt=#line
    ) -> Date {
        guard let yesterday = DateFactory.createDate(daysFrom: -1) else {
            XCTFail("Failed to create yesterday")
            return DateFactory.createDefaultDate()
        }
        return yesterday
    }

    /// Attempts to create a date using the specified parameters. If it fails, calls `XCTFail()` and returns the default date.
    public static func createTestDate(
        daysFrom: Int=0,
        hoursFrom: Int=0,
        minutesFrom: Int=0,
        date: Date?=nil,
        now: NowProtocol?=nil,
        file: StaticString=#filePath,
        line: UInt=#line
    ) -> Date {
        let hours = 24 * daysFrom + hoursFrom
        let minutes = hours * 60 + minutesFrom
        guard let date = createDate(minutes: minutes, fromDate: date, now: now) else {
            XCTFail("Failed to create date \(minutes) minutes ago.")
            return DateFactory.createDefaultDate()
        }
        return date
    }

    /// Attempts to create a date using the specified parameters. If it fails, calls `XCTFail()` and returns the default date.
    public static func createTestDate(
        on: Date?=nil,
        at: Time?=nil,
        now: NowProtocol?=nil,
        file: StaticString=#filePath,
        line: UInt=#line
    ) -> Date {
        let on = on ?? now?.now ?? Date()
        let at = at ?? now?.now ?? Time()
        guard let testDate = DateFactory.createDate(on: on, at: at) else {
            XCTFail("Failed to create testDate on \(on) at \(at)")
            return DateFactory.createDefaultDate()
        }
        return testDate
    }

    private static func createDate(
        minutes: Int=0,
        fromDate: Date?=nil,
        now: NowProtocol?=nil
    ) -> Date? {
        DateFactory.createDate(minutesFrom: minutes, fromDate: fromDate, now: now)
    }
}
