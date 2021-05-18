//
//  XDaysUD.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class XDaysUD: PDUserDefault<String, String>, StringKeyStorable {

    public var setting: PDSetting = .XDays

    public convenience init() {
        self.init(DefaultSettings.XDaysRawValue)
    }

    public convenience init(_ intValue: Int) {
        self.init("\(intValue)")
    }

    public required init(_ rawValue: String) {
        super.init(rawValue)
    }

    public var days: Double {
        Double(rawValue) ?? DefaultSettings.XDaysRawValueDouble
    }

    public var hours: Int {
        let daysDouble = Double(Hours.InDay)
        return Int(daysDouble * days)  // Should always be a whole number.
    }

    /// Converts an xDaysString such as `"4.5"` to a displayable version of `"Every 4 And A Half Days"`.
    public static func makeDisplayable(_ xDaysString: String) -> String {
        // TODO: Test
        guard let xDaysDecimal = Double(xDaysString) else { return "" }
        let floor = floor(xDaysDecimal)
        let isWholeNumber = floor - xDaysDecimal == 0
        let floorInt = Int(floor)
        let valueString = isWholeNumber ? "\(floorInt)" : "\(floorInt) And A Half"
        return NSLocalizedString("Every \(valueString) Days", comment: "A schedule")
    }

    /// Returns the string decimal version of an interval string, such as `"4.5"` from `"Every 4 And A Half Days"`.
    public static func extract(_ intervalString: String) -> String {
        let stringList = intervalString.split(separator: " ")
        guard isXDaysString(intervalString) else { return "" }
        guard let wholeNumber = Double(stringList[1]) else { return "" }

        // We know for sure it matches an expected pattern by this point.
        if stringList.count == 3 {
            return "\(wholeNumber)"
        } else {
            return "\(wholeNumber + 0.5)"
        }
    }

    private static func isXDaysString(_ string: String) -> Bool {
        let wholeDayRegex = "(^(Every) [0-9][0-9]? (Days)+$)"
        let halfDayRegex = "(^(Every) [0-9][0-9]? (And) (A) (Half) (Days)+$)"
        let isWholeDay = string.range(of: wholeDayRegex, options: .regularExpression) != nil
        let isHalfDay = string.range(of: halfDayRegex, options: .regularExpression) != nil
        return isWholeDay || isHalfDay
    }
}
