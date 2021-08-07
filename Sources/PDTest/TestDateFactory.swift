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

    public static var defaultDate: Date {
        DateFactory.createDefaultDate()
    }

    /// Attempts to create midnight. If it fails, calls `XCTFail()` and returns the default date.
    public static func createTestMidnight(
        date: Date?=nil, now: NowProtocol?=nil, file: StaticString=#filePath, line: UInt=#line
    ) -> Date {
        let date = date ?? now?.now ?? Date()
        guard let midnight = DateFactory.createMidnight(of: date, now: now) else {
            return failed(toCreate: "midnight", file: file, line: line)
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
        let date = consolidate(date, now)
        guard let testDate = DateFactory.createDate(
            date, hour: hour, minute: minute, second: second
        ) else {
            return failed(file: file, line: line)
        }
        return testDate
    }

    /// Attempts to create a date exactly yesterday. If it fails, calls `XCTFail()` and returns the default date.
    public static func createYesterday(
        file: StaticString=#filePath, line: UInt=#line
    ) -> Date {
        guard let yesterday = DateFactory.createDate(daysFrom: -1) else {
            return failed(toCreate: "yesterday", file: file, line: line)
        }
        return yesterday
    }

    /// Attempts to create a date using the specified parameters. If it fails, calls `XCTFail()` and returns the default date.
    public static func createTestDate(
        daysFrom days: Int=0,
        hoursFrom hours: Int=0,
        minutesFrom minutes: Int=0,
        date: Date?=nil,
        now: NowProtocol?=nil,
        file: StaticString=#filePath,
        line: UInt=#line
    ) -> Date {
        let hoursInDays = 24 * days
        let totalHours = hoursInDays + hours
        let minutesInHours = 60 * totalHours
        let totaMinutes = minutesInHours + minutes
        guard let date = createDate(minutes: totaMinutes, fromDate: date, now: now) else {
            return failed(when: "\(totaMinutes) minutes ago.", file: file, line: line)
        }
        return date
    }

    /// Attempts to create a date using the specified parameters. If it fails, calls `XCTFail()` and returns the default date.
    public static func createTestDate(
        on onDate: Date?=nil,
        at atDate: Time?=nil,
        now: NowProtocol?=nil,
        file: StaticString=#filePath,
        line: UInt=#line
    ) -> Date {
        let onDate = consolidate(onDate, now)
        let atDate = consolidate(atDate, now)
        guard let testDate = DateFactory.createDate(on: onDate, at: atDate) else {
            return failed(when: "on \(onDate) at \(atDate)", file: file, line: line)
        }
        return testDate
    }

    /// Attempts to create a date using the specified parameters. If it fails, calls `XCTFail()` and returns the default date.
    public static func createTestDate(
        byAddingMonths months: Int,
        to date: Date?=nil,
        now: NowProtocol?=nil,
        file: StaticString=#filePath,
        line: UInt=#line
    ) -> Date {
        let date = consolidate(date, now)
        guard let testDate = DateFactory.createDate(byAddingMonths: months, to: date) else {
            return failed(when: "when adding \(months) to \(date).", file: file, line: line)
        }
        return testDate
    }

    /// Attempts to create a date using the specified parameters. If it fails, calls `XCTFail()` and returns the default date.
    public static func createTestDate(
        byAddingHours hours: Int,
        to date: Date?=nil,
        now: NowProtocol?=nil,
        file: StaticString=#filePath,
        line: UInt=#line
    ) -> Date {
        let date = consolidate(date, now)
        guard let testDate = DateFactory.createDate(byAddingHours: hours, to: date) else {
            return failed(when: "when adding \(hours) to \(date).", file: file, line: line)
        }
        return testDate
    }

    /// Attempts to create a date using the specified parameters. If it fails, calls `XCTFail()` and returns the default date.
    public static func createTestDate(
        byAddingMinutes minutes: Int,
        to date: Date?=nil,
        now: NowProtocol?=nil,
        file: StaticString=#filePath,
        line: UInt=#line
    ) -> Date {
        let date = consolidate(date, now)
        guard let testDate = DateFactory.createDate(byAddingMinutes: minutes, to: date) else {
            return failed(when: "when adding \(minutes) to \(date).", file: file, line: line)
        }
        return testDate
    }

    /// Attempts to create a date using the specified parameters. If it fails, calls `XCTFail()` and returns the default date.
    public static func createTestDate(
        byAddingSeconds seconds: Int,
        to date: Date?=nil,
        now: NowProtocol?=nil,
        file: StaticString=#filePath,
        line: UInt=#line
    ) -> Date {
        let date = consolidate(date, now)
        guard let testDate = DateFactory.createDate(byAddingSeconds: seconds, to: date) else {
            return failed(when: "when adding \(seconds) to \(date).", file: file, line: line)
        }
        return testDate
    }

    private static func consolidate(_ date: Date?, _ now: NowProtocol?) -> Date {
        date ?? now?.now ?? Date()
    }

    private static func createDate(
        minutes: Int=0,
        fromDate: Date?=nil,
        now: NowProtocol?=nil
    ) -> Date? {
        DateFactory.createDate(minutesFrom: minutes, fromDate: fromDate, now: now)
    }

    private static func failed(
        toCreate dateVariable: String="testDate",
        when situation: String?=nil,
        file: StaticString=#filePath,
        line: UInt=#line
    ) -> Date {
        var duringSituation = ""
        if let situation = situation {
            duringSituation = " \(situation)"
        }
        XCTFail("Failed to create \(dateVariable)\(duringSituation)", file: file, line: line)
        return defaultDate
    }
}
