//
//  PDConstants.swift
//  PDKit
//
//  Created by Juliya Smith on 11/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public let SupportedHormoneUpperQuantityLimit = 4
public let SupportedPillExpirationIntervalDaysLimit = 25
public let MaxPillTimesaday = 4

public let HoursInADay = 24
public let HoursInHalfWeek = 84
public let HoursInWeek = HoursInHalfWeek * 2
public let HoursInTwoWeeks = HoursInWeek * 2

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
}

public class DefaultPillAttributes {
    public static let time = "8:00:00"
    public static let timesaday = 1
    public static let timesTakenToday = 0
    public static let notify = true
    public static let expirationInterval = PillExpirationIntervalSetting.EveryDay
    public static let xDaysString = "12"
    public static let xDaysInt = 12
}

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

public var DotDotDot: String {
    NSLocalizedString("...", comment: "Instruction for empty patch")
}

public let DefaultNumberOfPickerComponents = 1

public let PDSharedDataGroupName: String = "group.com.patchday.todaydata"
