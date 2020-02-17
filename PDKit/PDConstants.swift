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

public class DefaultSettings {
    public static let DefaultExpirationInterval = ExpirationInterval.TwiceAWeek
    public static let DefaultExpirationIntervalHours = 84

    public static let DefaultQuantity = Quantity.Four
    public static let DefaultDeliveryMethod = DeliveryMethod.Patches
    public static let DefaultNotificationsMinutesBefore = 0
    public static let DefaultTheme = PDTheme.Light
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

