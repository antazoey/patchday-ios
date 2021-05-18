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
        guard let xDaysDecimal = Double(xDaysString) else { return "" }
        let floor = floor(xDaysDecimal)
        let isWholeNumber = floor - xDaysDecimal == 0
        let floorInt = Int(floor)
        let numDays = isWholeNumber ? "\(floorInt)" : "\(floorInt)½"
        return NSLocalizedString("Every \(numDays) Days", comment: "Pharmacy definition of Q.D.")
    }

    /// Returns the string decimal version of an interval string, such as `"4.5"` from `"Every 4 And A Half Days"`.
    public static func extract(_ intervalString: String) -> String {
        let stringList = intervalString.split(separator: " ")
        guard isXDaysString(intervalString) else { return "" }
        let daysString = String(stringList[1])
        guard let days = getDays(from: daysString) else { return "" }
        return "\(days)"
    }

    private static func isXDaysString(_ string: String) -> Bool {
        string.range(of: "((Every) \\d\\d?(½)? (Days))", options: .regularExpression) != nil
    }

    private static func getDays(from daysString: String) -> Double? {
        var daysString = daysString
        guard let last = daysString.last else { return nil }
        var addHalf = false
        if last == "½" {
            daysString.removeLast()
            addHalf = true
        }

        guard var days = Double(daysString) else { return nil }
        if addHalf {
            days += 0.5
        }
        return days
    }
}
