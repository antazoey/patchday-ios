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


public class AppTheme {
    
    private let colors: Dictionary<ThemedAsset, UIColor>
    private var _setting: PDTheme
    
    public var setting: PDTheme { _setting }
    
    public init(_ theme: PDTheme) {
        self._setting = theme
        switch theme {
        case .Light:
            colors = [
                .bg : UIColor.white,
                .border : PDColors.get(.LightGray),
                .button : UIColor.blue,
                .evenCell : PDColors.get(.LightBlue),
                .green : PDColors.get(.Green),
                .navBar : UIColor.white,
                .oddCell : UIColor.white,
                .purple : PDColors.get(.Purple),
                .selected : PDColors.get(.Pink),
                .text : UIColor.black,
                .unselected : UIColor.darkGray
            ]
        case .Dark:
            colors = [
                .bg : UIColor.black,
                .border : UIColor.white,
                .button : UIColor.white,
                .evenCell : UIColor.black,
                .green : UIColor.white,
                .navBar : UIColor.black,
                .oddCell : UIColor.black,
                .purple : PDColors.get(.Purple),
                .selected : PDColors.get(.Black),
                .text : UIColor.white,
                .unselected : UIColor.lightGray
            ]
        }
    }
    
    public subscript(index: ThemedAsset) -> UIColor {
        colors[index] ?? UIColor()
    }
}


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
    case TwiceWeekly
    case OnceWeekly
    case EveryTwoWeeks
}


public enum PDTheme {
    case Light
    case Dark
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
    case Theme = "theme"
}


public enum PDEntity: String, CaseIterable {
    case hormone = "Hormone"
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
