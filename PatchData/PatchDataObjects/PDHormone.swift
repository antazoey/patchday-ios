//
//  PDPatch.swift
//  PatchData
//
//  Created by Juliya Smith on 8/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PDHormone: PDObject, Hormonal, Comparable {
    
    private let exp: ExpirationIntervalUD
    private let deliveryMethod: DeliveryMethod
    
    private var hormone: MOHormone {
        return self.mo as! MOHormone
    }
    
    public init(hormone: MOHormone, interval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) {
        self.exp = interval
        self.deliveryMethod = deliveryMethod
        super.init(mo: hormone)
    }
    
    public static func new(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormonal? {
        let type = PDEntity.estrogen.rawValue
        if let mone = PatchData.insert(type) as? MOHormone {
            return PDHormone(hormone: mone,
                             interval: expiration,
                             deliveryMethod: deliveryMethod)
        }
        return nil
    }
    
    public var id: UUID {
        get {
            return hormone.id ?? {
                let newId = UUID()
                hormone.id = newId
                return newId
            }()
        } set {
            hormone.id = newValue
        }
    }
    
    public var date: Date {
        get {
            if let date = hormone.date {
                return date as Date
            }
            return Date.createDefaultDate()
        }
        set { hormone.date = newValue as NSDate }
    }
    
    public var expiration: Date? {
        if let date = date as Date?,
            let expires = PDDateHelper.expirationDate(from: date, exp.hours) {
            return expires
        }
        return nil
    }
    
    public var expirationString: String {
        if let date = date as Date?,
            let expires = PDDateHelper.expirationDate(from: date, exp.hours) {
            return PDDateHelper.format(date: expires, useWords: true)
        }
        return PDStrings.PlaceholderStrings.dotdotdot
    }
    
    public var isExpired: Bool {
        if let date = date as Date? {
            return (PDDateHelper.expirationInterval(exp.hours, date: date) ?? 1) <= 0
        }
        return false
    }
    
    public var siteName: String {
        if let name = hormone.siteRelationship?.name ?? siteNameBackUp {
            return name
        }
        return PDStrings.PlaceholderStrings.new_site
    }
    
    public var siteNameBackUp: String? {
        get { return site == nil ? hormone.siteNameBackUp : nil }
        set {
            hormone.siteNameBackUp = newValue
            hormone.siteRelationship = nil
        }
    }
    
    public var isEmpty: Bool {
        return date.isDefault() && site == nil && siteNameBackUp == nil
    }
    
    public var isCerebral: Bool {
        return siteName == PDStrings.PlaceholderStrings.new_site
    }
    
    public var site: Bodily?
    {
        get {
            if let s = hormone.siteRelationship {
                return PDSite(site: s, globalExpirationInterval: exp, deliveryMethod: deliveryMethod)
            }
            return nil
        } set {
            if let s = newValue as? MOSite {
                hormone.siteRelationship = s
                hormone.siteNameBackUp = nil
            }
        }
    }
    
    // Note: nil is greater than all for MOEstrogens
    
    public static func < (lhs: PDHormone, rhs: PDHormone) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return (lhs.date as Date?)! < (rhs.date as Date?)!
        }
    }
    
    public static func > (lhs: PDHormone, rhs: PDHormone) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return false
        default : return (lhs.date as Date?)! > (rhs.date as Date?)!
        }
    }
    
    public static func == (lhs: PDHormone, rhs: PDHormone) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return true
        case (nil, _) : return false
        case (_, nil) : return false
        default : return (lhs.date as Date?)! == (rhs.date as Date?)!
        }
    }
    
    public static func != (lhs: PDHormone, rhs: PDHormone) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return true
        default : return (lhs.date as Date?)! != (rhs.date as Date?)!
        }
    }
    
    public func stamp() {
        hormone.date = NSDate()
    }

    /// Sets all attributes to nil.
    public func reset() {
        hormone.id = nil
        hormone.date = nil
        hormone.siteRelationship = nil
        hormone.siteNameBackUp = nil
    }
}
