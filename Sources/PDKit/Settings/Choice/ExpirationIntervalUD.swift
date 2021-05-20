//
//  ExpirationIntervalUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.

import Foundation

public class ExpirationIntervalUD: ChoiceSetting<ExpirationInterval, String>, KeyStorable {

    public static let OnceDailyKey = "Once daily"
    public static let TwiceWeeklyKey = "One half-week"
    public static let OnceWeeklyKey = "One week"
    public static let EveryTwoWeeksKey = "Two weeks"
    public static let EveryXDaysKey = "Every x-days"
    public typealias Value = ExpirationInterval
    public typealias RawValue = String
    public let setting: PDSetting = .ExpirationInterval
    public let xDays = XDaysUD()

    public convenience init() {
        self.init(DefaultSettings.ExpirationIntervalValue)
    }

    public convenience init(_ value: ExpirationInterval) {
        let rv = ExpirationIntervalUD.getRawValue(for: value)
        self.init(rv)
    }

    public required init(_ rawValue: String) {
        super.init(rawValue)
        self.choices = SettingsOptions.expirationIntervals
    }

    public override var value: ExpirationInterval {
        switch rawValue {
            case ExpirationIntervalUD.OnceDailyKey: return .OnceDaily
            case ExpirationIntervalUD.TwiceWeeklyKey: return .TwiceWeekly
            case ExpirationIntervalUD.OnceWeeklyKey: return .OnceWeekly
            case ExpirationIntervalUD.EveryTwoWeeksKey: return .EveryTwoWeeks
            case ExpirationIntervalUD.EveryXDaysKey: return .EveryXDays
            default: return DefaultSettings.ExpirationIntervalValue
        }
    }

    public var hours: Int {
        switch value {
            case .OnceDaily: return Hours.InDay
            case .TwiceWeekly: return Hours.InHalfWeek
            case .OnceWeekly: return Hours.InWeek
            case .EveryTwoWeeks: return Hours.InTwoWeeks
            case .EveryXDays: return xDays.hours
        }
    }

    public var days: Double {
        switch value {
            case .OnceDaily: return 1
            case .TwiceWeekly: return Days.InHalfWeek
            case .OnceWeekly: return Days.InWeek
            case .EveryTwoWeeks: return Days.InTwoWeeks
            case .EveryXDays: return xDays.days
        }
    }

    public override var displayableString: String {
        SettingsOptions.getExpirationInterval(for: self)
    }

    public static func getRawValue(for value: ExpirationInterval) -> String {
        switch value {
            case .OnceDaily: return OnceDailyKey
            case .TwiceWeekly: return TwiceWeeklyKey
            case .OnceWeekly: return OnceWeeklyKey
            case .EveryTwoWeeks: return EveryTwoWeeksKey
            case .EveryXDays: return EveryXDaysKey
        }
    }
}
