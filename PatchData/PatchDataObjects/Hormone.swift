//
//  Hormone.swift
//  PatchData
//
//  Created by Juliya Smith on 8/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class Hormone: Hormonal {
    
    private var hormoneData: HormoneStruct
    
    public init(hormoneData: HormoneStruct, interval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) {
        self.hormoneData = hormoneData
        self.expirationInterval = interval
        self.deliveryMethod = deliveryMethod
    }

    public var deliveryMethod: DeliveryMethod

    public var expirationInterval: ExpirationIntervalUD

    public var id: UUID {
        get {
            hormoneData.id ?? {
                hormoneData.id = UUID()
                return hormoneData.id!
            }()
        } set {
            hormoneData.id = newValue
        }
    }
    
    public var siteId: UUID? {
        get { hormoneData.siteRelationshipId ?? nil }
        set {
            if let newSiteId = newValue {
                hormoneData.siteRelationshipId = newSiteId
                hormoneData.siteNameBackUp = nil
            }
        }
    }

    public var siteName: SiteName? {
        get { hormoneData.siteName }
        set { hormoneData.siteName = newValue }
    }

    public var date: Date {
        get { (hormoneData.date as Date?) ?? Date.createDefaultDate() }
        set { hormoneData.date = newValue }
    }

    public var expiration: Date? {
        if let date = date as Date?,
            let expires = DateHelper.calculateExpirationDate(from: date, expirationInterval.hours) {
            return expires
        }
        return nil
    }

    public var expirationString: String {
        if let date = date as Date?,
            let expires = DateHelper.calculateExpirationDate(from: date, expirationInterval.hours) {
            return DateHelper.format(date: expires, useWords: true)
        }
        return PDStrings.PlaceholderStrings.dotDotDot
    }

    public var isExpired: Bool {
        if let date = date as Date? {
            let timeInterval = DateHelper.calculateExpirationTimeInterval(expirationInterval.hours, date: date)
            return (timeInterval ?? 1) <= 0
        }
        return false
    }

    public func isEqualTo(_ otherHormone: Hormonal) -> Bool {
        HormoneComparator.equalTo(lhs: self, rhs: otherHormone)
    }

    public var isPastNotificationTime: Bool {
        if let expDate = expiration {
            let hours = 0 - expirationInterval.hours
            if let notifyDate = expDate.createNewDateFromAddingHours(hours) {
                return Date() > notifyDate
            }
        }
        return false
    }
    
    public var expiresOvernight: Bool {
        expiration?.isOvernight() ?? false
    }

    public var siteNameBackUp: String? {
        get {
            // Only give a back up name if needed
            siteId == nil ? hormoneData.siteNameBackUp : nil
        }
        set {
            hormoneData.siteNameBackUp = newValue
        }
    }

    public var isEmpty: Bool {
        date.isDefault() && hasNoSite
    }

    public var hasNoSite: Bool {
        siteId == nil && siteNameBackUp == nil
    }
    
    public func stamp() {
        hormoneData.date = Date()
    }

    public func reset() {
        hormoneData.id = nil
        hormoneData.date = nil
        hormoneData.siteRelationshipId = nil
        hormoneData.siteNameBackUp = nil
    }
}
