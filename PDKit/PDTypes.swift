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
public typealias Stamp = Date
public typealias Stamps = [Stamp?]?

public enum DeliveryMethod {
    case Patches
    case Injections
}

public enum Quantity: Int {
    case One = 1
    case Two = 2
    case Three = 3
    case Four = 4
}

public enum ExpirationInterval {
    case TwiceAWeek
    case OnceAWeek
    case EveryTwoWeeks
}

public enum PDTheme {
    case Light
    case Dark
}

public enum PDDefault: String {
    case DeliveryMethod = "delivMethod"
    case ExpirationInterval = "patchChangeInterval"
    case Quantity = "numberOfPatches"
    case Notifications = "notification"
    case NotificationsMinutesBefore = "remindMeUpon"
    case MentionedDisclaimer = "mentioned"
    case SiteIndex = "site_i"
    case Theme = "theme"
}
