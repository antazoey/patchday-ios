//
//  PDConstants.swift
//  PDKit
//
//  Created by Juliya Smith on 11/20/19.
//  
//

import Foundation

/// The maximum number of supported hormones in a schedule.
public let SupportedHormoneUpperQuantityLimit = 4

/// The maximum number of days in a pill expiration interval that supports days.
public let SupportedPillExpirationIntervalDaysLimit = 25

/// The maximum number of supported pill times for a single pill.
public let MaxPillTimesaday = 4

/// Constants that are hours.
public class Hours {
    /// The number of hours that are in a single day (on Earth).
    public static let InDay = 24

    /// The number of hours that are in 3.5 Earth days.
    public static let InHalfWeek = 84

    /// The number of hours that are in a single Earth week.
    public static var InWeek: Int {
        InHalfWeek * 2
    }

    /// The number of hours that are in two Earth weeks.
    public static var InTwoWeeks: Int {
        InWeek * 2
    }
}

/// Default hormone settings.
public class DefaultSettings {
    public static let ExpirationIntervalValue = ExpirationInterval.TwiceWeekly
    public static let ExpirationIntervalRawValue = ExpirationIntervalUD.TwiceWeeklyKey
    public static let ExpirationIntervalHours = 84
    public static let QuantityValue = Quantity.Three
    public static let QuantityRawValue = 3
    public static let DeliveryMethodValue = DeliveryMethod.Patches
    public static let DeliveryMethodRawValue = DeliveryMethodUD.PatchesKey
    public static let NotificationsRawValue = true
    public static let NotificationsMinutesBeforeRawValue = 0
    public static let MentionedDisclaimerRawValue = false
    public static let SiteIndexRawValue = 0
    public static let MaxSupportedNotificationsMinutesBefore = 120
    public static let PillsEnabledRawValue = true
}

/// Default properties to assign to pills when they are not given any.
public class DefaultPillAttributes {
    public static let time = "8:00:00"
    public static let timesaday = 1
    public static let timesTakenToday = 0
    public static let notify = true
    public static let expirationInterval = PillExpirationIntervalSetting.EveryDay
    public static let xDaysInt = 12
    public static let xDaysString = "\(xDaysInt)"
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

/// A localized placeholder string.
public var DotDotDot: String {
    NSLocalizedString("...", comment: "Instruction for empty patch")
}

/// The number of components for most (currently all) pickers.
public let DefaultNumberOfPickerComponents = 1

/// The name of the group for saving shared User Defaults.
public let PDSharedDataGroupName: String = "group.com.patchday.todaydata"

/// Constants for sanitizing user input.
public class SanitationConstants {
    public static let MaxSiteNameCharacters = 30
}
