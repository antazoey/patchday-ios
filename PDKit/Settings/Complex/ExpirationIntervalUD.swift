//
//  ExpirationIntervalUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class ExpirationIntervalUD: PDUserDefault<ExpirationInterval, String>, KeyStorable {
    
    public static var TwiceWeeklyKey = { "One half-week" }()
    public static var OnceWeeklyKey = { "One week" } ()
    public static var EveryTwoWeeksKey = { "Two weeks" }()
    
    public typealias Value = ExpirationInterval
    public typealias RawValue = String
    public let setting: PDSetting = .ExpirationInterval

    public override var value: ExpirationInterval {
        switch rawValue {
        case ExpirationIntervalUD.OnceWeeklyKey: return .OnceWeekly
        case ExpirationIntervalUD.EveryTwoWeeksKey: return .EveryTwoWeeks
        default: return .TwiceWeekly
        }
    }
    
    public var hours: Int {
        switch value {
        case .TwiceWeekly: return HoursInHalfWeek
        case .OnceWeekly: return HoursInWeek
        case .EveryTwoWeeks: return HoursInTwoWeeks
        }
    }
    
    public override var displayableString: String {
        let options = PickerOptions.expirationIntervals
        var str = ""
        switch value {
        case .TwiceWeekly: str = options.tryGet(at: 0) ?? str
        case .OnceWeekly: str = options.tryGet(at: 1) ?? str
        case .EveryTwoWeeks: str = options.tryGet(at: 2) ?? str
        }
        return str
    }
    
    public static func makeExpirationInterval(from humanReadableStr: String) -> ExpirationInterval? {
        switch humanReadableStr {
        case PickerOptions.expirationIntervals[0]: return ExpirationInterval.TwiceWeekly
        case PickerOptions.expirationIntervals[1]: return ExpirationInterval.OnceWeekly
        case PickerOptions.expirationIntervals[2]: return ExpirationInterval.EveryTwoWeeks
        default: return nil
        }
    }
}
