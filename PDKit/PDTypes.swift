//
//  PDTypes.swift
//  PDKit
//
//  Created by Juliya Smith on 5/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public typealias Index = Int
public typealias SiteName = String
public typealias Time = Date
public typealias Stamp = Date
public typealias Stamps = [Stamp?]?

public enum DeliveryMethod {
    case Patches
    case Injections
    case Gel
}

public enum Quantity: Int {
    case One = 1
    case Two = 2
    case Three = 3
    case Four = 4
}

public enum ExpirationInterval {
    case OnceDaily
    case TwiceWeekly
    case OnceWeekly
    case EveryTwoWeeks
}

public enum PillExpirationInterval: String {
    case EveryDay = "everyDay"
    case EveryOtherDay = "everyOtherDay"
    case FirstTenDays = "firstTenDays"
    case LastTenDays = "lastTenDays"
    case FirstTwentyDays = "firstTwentyDays"
    case LastTwentyDays = "lastTwentyDays"
}

// These strings cannot change - they are for retrieving from Core Data
public enum PDSetting: String {
    case DeliveryMethod = "delivMethod"
    case ExpirationInterval = "patchChangeInterval"
    case Quantity = "numberOfPatches"
    case Notifications = "notification"
    case NotificationsMinutesBefore = "remindMeUpon"
    case MentionedDisclaimer = "mentioned"
    case SiteIndex = "site_i"
}

public enum PDEntity: String, CaseIterable {
    case hormone = "Estrogen"
    case pill = "Pill"
    case site = "Site"
}

public enum ThemedAsset {
    case bg
    case border
    case button
    case evenCell
    case green
    case navBar
    case oddCell
    case purple
    case selected
    case text
    case unselected
}
