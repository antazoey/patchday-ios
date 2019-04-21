//
//  PDDefaultProtocol.swift
//  PatchData
//
//  Created by Juliya Smith on 4/21/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

open class PDDefaultsBaseClass: NSObject {
    
    override open var description: String {
        return """
        The PDDefaults makes calls to User Defaults
        that are unique to the user and their schedule.
        The data stored here is simple enough that PatchDay
        stores it as key-value pairs.
        """
    }
    
    private let std_defaults = UserDefaults.standard
    private var shared: PDSharedData? = nil
    
    public enum PDDefault: String {
        case DeliveryMethod = "delivMethod"
        case TimeInterval = "patchChangeInterval"
        case Quantity = "numberOfPatches"
        case Notifications = "notification"
        case NotificationMinutesBefore = "remindMeUpon"
        case MentionedDisclaimer = "mentioned"
        case SiteIndex = "site_i"
        case Theme = "theme"
    }
    
    open func set<T>(_ v: inout T, to new: T, for key: PDDefault, push: Bool = true) {
        v = new
        if push {
            shared?.defaults?.set(new, forKey: key.rawValue)
        }
    }
    
    open func find<T>(_ val: inout T, key: String) -> Bool {
        let def1 = shared?.defaults?.object(forKey: key) as? T
        let def2 = std_defaults.object(forKey: key) as? T
        val = def1 ?? def2 ?? val
        return def1 != nil || def2 != nil
    }
    
    open func load<T>(_ v: inout T,
                      for pdDefault: PDDefault,
                      helper: ((T) -> T)? = nil) {
        let k = pdDefault.rawValue
        let found = find(&v, key: k)
        if let h = helper {
            v = h(v)
        }
        if !found {
            self.set(&v, to: v, for: pdDefault)
        }
    }
}
