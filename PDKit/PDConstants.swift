//
//  File.swift
//  PDKit
//
//  Created by Juliya Smith on 11/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public let OnlySupportedInjectionsQuantity = 1
public let SupportedHormoneUpperQuantityLimit = 4

public let HoursInHalfWeek = 84
public let HoursInWeek = HoursInHalfWeek * 2
public let HoursInTwoWeeks = HoursInWeek * 2


public class DefaultSettings {
    public static let ExpirationIntervalValue = ExpirationInterval.TwiceWeekly
    public static let ExpirationIntervalRawValue = ExpirationIntervalUD.TwiceWeeklyKey
    public static let ExpirationIntervalHours = 84
    public static let QuantityValue = Quantity.Four
    public static let QuantityRawValue = 4
    public static let DeliveryMethodValue = DeliveryMethod.Patches
    public static let DeliveryMethodRawValue = DeliveryMethodUD.PatchesKey
    public static let NotificationsRawValue = true
    public static let NotificationsMinutesBeforeRawValue = 0
    public static let MentionedDisclaimerRawValue = false
    public static let SiteIndexRawValue = 0
    public static let ThemeValue = PDTheme.Light
    public static let ThemeRawValue = PDThemeUD.LightThemeKey
}


public class DefaultPillAttributes {
    
    public static let time = { Calendar.current.date(bySetting: .hour, value: 9, of: Date()) }()
    public static let timesaday = 1
    public static let timesTakenToday = 0
    public static let notify = true
}

public class KeyStorableHelper {

    public static func defaultQuantity(for deliveryMethod: DeliveryMethod) -> Int {
        switch deliveryMethod {
        case .Injections: return 1
        case .Patches: return 3
        }
    }
    
    public static func defaultSiteCount(for deliveryMethod: DeliveryMethod) -> Int {
        switch deliveryMethod {
        case .Injections: return 1
        case .Patches: return 4
        }
    }
}
