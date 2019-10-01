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
    
    private var estrogen: MOHormone {
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
            return PDHormone(hormone: mone, interval: expiration, deliveryMethod: deliveryMethod)
        }
        return nil
    }
    
    public var id: UUID {
        get { return estrogen.id ?? { let newId = UUID(); estrogen.id = newId; return newId }() }
        set { estrogen.id = newValue }
    }
    
    public var date: Date {
        get {
            if let date = estrogen.date {
                return date as Date
            }
            return Date.createDefaultDate()
        }
        set { estrogen.date = newValue as NSDate }
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
        let site = estrogen.siteRelationship?.name ?? siteNameBackUp
        switch site {
        case nil : return PDStrings.PlaceholderStrings.new_site
        case let s : return s!
        }
    }
    
    public var siteNameBackUp: String? {
        get { return site == nil ? estrogen.siteNameBackUp : nil }
        set {
            estrogen.siteNameBackUp = newValue
            estrogen.siteRelationship = nil
        }
    }
    
    public var isEmpty: Bool {
        return !date.isDefault() && site == nil && siteNameBackUp == nil
    }
    
    public var site: Bodily?
    {
        get {
            if let s = estrogen.siteRelationship {
                return PDSite(site: s, globalExpirationInterval: exp, deliveryMethod: deliveryMethod)
            }
            return nil
        }
        set {
            if let s = newValue as? MOSite {
                estrogen.siteRelationship = s
                estrogen.siteNameBackUp = nil
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
        estrogen.date = NSDate()
    }

    /// Sets all attributes to nil.
    public func reset() {
        estrogen.id = nil
        estrogen.date = nil
        estrogen.siteRelationship = nil
        estrogen.siteNameBackUp = nil
    }
}
