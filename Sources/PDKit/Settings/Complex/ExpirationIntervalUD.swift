//
//  ExpirationIntervalUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.

import Foundation

public class ExpirationIntervalUD: ComplexSetting<ExpirationInterval, String>, KeyStorable {

    public static var OnceDailyKey = { "Once daily" }()
    public static var TwiceWeeklyKey = { "One half-week" }()
    public static var OnceWeeklyKey = { "One week" }()
    public static var EveryTwoWeeksKey = { "Two weeks" }()
    public static var EveryXDaysKey = { "Every x-days" }()

    public typealias Value = ExpirationInterval
    public typealias RawValue = String
    public let setting: PDSetting = .ExpirationInterval

    public var xDays = XDays()

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
            default: return DefaultSettings.ExpirationIntervalValue
        }
    }

    public var hours: Int {
        switch value {
            case .OnceDaily: return Hours.InDay
            case .TwiceWeekly: return Hours.InHalfWeek
            case .OnceWeekly: return Hours.InWeek
            case .EveryTwoWeeks: return Hours.InTwoWeeks
            case .EveryXDays: return xDays.value ?? DefaultSettings.ExpirationIntervalHours
        }
    }

    public override var displayableString: String {
        let options = SettingsOptions.expirationIntervals
        var str = ""
        switch value {
            case .OnceDaily: str = options.tryGet(at: 0) ?? str
            case .TwiceWeekly: str = options.tryGet(at: 1) ?? str
            case .OnceWeekly: str = options.tryGet(at: 2) ?? str
            case .EveryTwoWeeks: str = options.tryGet(at: 3) ?? str
            case .EveryXDays: str = options.tryGet(at: 4) ?? str
        }
        return str
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
