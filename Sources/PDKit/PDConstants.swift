//
//  PDConstants.swift
//  PDKit
//
//  Created by Juliya Smith on 11/20/19.
//  
//

import Foundation

/// The 1/2 symbol.
public let HALF: Character = "½"

/// The maximum number of supported hormones in a schedule.
public let SUPPORTED_HORMONE_UPPER_QUANTITY_LIMIT = 4

/// The maximum number of days in an expiration interval that supports days, including pill expiration intervals.
public let EXPIRATION_INTERVAL_DAYS_LAST_INTEGER = 25

/// The maximum number of supported pill times for a single pill.
public let MAX_PILL_TIMES_PER_DAY = 4

/// Constants that are hours.
public class Hours {
    /// The number of hours that are in a single day (on Earth).
    public static let IN_DAY = 24

    /// The number of hours that are in 3.5 Earth days.
    public static let IN_HALF_WEEK = 84

    /// The number of hours that are in a single Earth week.
    public static var IN_WEEK: Int {
        IN_HALF_WEEK * 2
    }

    /// The number of hours that are in two Earth weeks.
    public static var IN_TWO_WEEKS: Int {
        IN_WEEK * 2
    }
}

/// Constants that are days.
public class Days {
    /// The number of days in 1/2 of a week.
    public static let IN_HALF_WEEK = 3.5

    /// The number of days that are in a week.
    public static let IN_WEEK = 7.0

    /// The number of days that are in two weeks.
    public static let IN_TWO_WEEKS = 14.0
}

/// Default hormone settings.
public class DefaultSettings {
    public static let DELIVERY_METHOD_VALUE = DeliveryMethod.Patches
    public static let DELIVERY_METHOD_RAW_VALUE = DeliveryMethodUD.PatchesKey
    public static let EXPIRATION_INTERVAL_VALUE = ExpirationInterval.TwiceWeekly
    public static let EXPIRATION_INTERVAL_RAW_VALUE = ExpirationIntervalUD.TwiceWeeklyKey
    public static let EXPIRATION_INTERVAL_HOURS = Hours.IN_HALF_WEEK
    public static let MAX_SUPPORTED_NOTIFICATIONS_MINUTES_BEFORE = 120
    public static let MENTIONED_DISCLAIMER_RAW_VALUE = false
    public static let NOTIFICATIONS_RAW_VALUE = true
    public static let NOTIFICATIONS_MINUTES_BEFORE_RAW_VALUE = 0
    public static let PILLS_ENABLED_RAW_VALUE = true
    public static let QUANTITY_VALUE = Quantity.Three
    public static let QUANTITY_RAW_VALUE = 3
    public static let SITE_INDEX_RAW_VALUE = 0
    public static let XDAYS_RAW_VALUE = "3.5"
    public static let XDAYS_DOUBLE = 3.0
    public static let XDAYS_INT = 3
}

/// Default properties to assign to pills when they are not given any.
public class DefaultPillAttributes {
    public static let TIME = "8:00:00"
    public static let TIMESADAY = 1
    public static let TIMES_TAKEN_TODAY = 0
    public static let NOTIFY = true
    public static let EXPIRATION_INTERVAL = PillExpirationIntervalSetting.EveryDay
    public static let XDAYS_INT = 12
    public static let XDAYS_STRING = "\(XDAYS_INT)"
}

/// The default hormone quantities per delivery method.
public class DefaultQuantities {

    public class Hormone {
        public static subscript(method: DeliveryMethod) -> Int {
            switch method {
                case .Injections: return 1
                case .Patches: return 3
                case .Gel: return 1
            }
        }
    }

    public class Site {
        public static subscript(method: DeliveryMethod) -> Int {
            switch method {
                case .Injections: return 6
                case .Patches: return 4
                case .Gel: return 1
            }
        }
    }
}

/// The number of components for most (currently all) pickers.
public let DefaultNumberOfPickerComponents = 1

/// The name of the group for saving shared User Defaults.
public let PDSharedDataGroupName: String = "group.com.patchday.todaydata"

/// Constants for sanitizing user input.
public class SanitationConstants {
    public static let MaxResourceNameCharacters = 30
}
