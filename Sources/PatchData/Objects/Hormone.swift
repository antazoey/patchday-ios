//
//  Hormone.swift
//  PatchData
//
//  Created by Juliya Smith on 8/20/19.

import Foundation
import PDKit

public class Hormone: Hormonal {

    private var hormoneData: HormoneStruct

    public var deliveryMethod: DeliveryMethod
    public var expirationInterval: ExpirationIntervalUD
    public var notificationsMinutesBefore: NotificationsMinutesBeforeUD
    public var useStaticExpirationTime: UseStaticExpirationTimeUD
    private var now: NowProtocol

    public init(hormoneData: HormoneStruct, settings: UserDefaultsReading, now: NowProtocol?=nil) {
        self.hormoneData = hormoneData
        self.deliveryMethod = settings.deliveryMethod.value
        self.expirationInterval = settings.expirationInterval
        self.notificationsMinutesBefore = settings.notificationsMinutesBefore
        self.useStaticExpirationTime = settings.useStaticExpirationTime
        self.now = now ?? PDNow()
    }

    public func from(_ settings: UserDefaultsReading) -> Hormonal {
        self.deliveryMethod = settings.deliveryMethod.value
        self.expirationInterval = settings.expirationInterval
        self.notificationsMinutesBefore = settings.notificationsMinutesBefore
        return self
    }

    public var id: UUID {
        get { hormoneData.id }
        set { hormoneData.id = newValue }
    }

    public var xDays: XDaysUD {
        expirationInterval.xDays
    }

    public var siteId: UUID? {
        get { hormoneData.siteRelationshipId ?? nil }
        set {
            hormoneData.siteRelationshipId = newValue
            hormoneData.siteImageId = nil
            // Only clear back up if not explicitly setting to nil
            if newValue != nil {
                hormoneData.siteNameBackUp = nil
            }
        }
    }

    public var siteName: SiteName {
        get {
            guard let name = hormoneData.siteName, !name.isEmpty, name != SiteStrings.NewSite else {
                return backupSiteName
            }
            hormoneData.siteImageId = nil
            return name
        }
        set { hormoneData.siteName = newValue }
    }

    public var siteImageId: SiteName {
        get {
            guard let id = hormoneData.siteImageId else { return siteName }
            return id.isEmpty || id == SiteStrings.NewSite ? siteName : id
        }
        set { hormoneData.siteImageId = newValue }
    }

    public var date: Date {
        get { (hormoneData.date as Date?) ?? DateFactory.createDefaultDate() }
        set { hormoneData.date = newValue }
    }

    public var expiration: Date? {
        guard let date = date as Date?, !date.isDefault() else { return nil }
        return createExpirationDate(from: date)
    }

    public var isExpired: Bool {
        guard let expirationDate = expiration else { return false }
        return expirationDate < now.now
    }

    public var isPastNotificationTime: Bool {
        if let expirationDate = expiration,
            let notificationTime = DateFactory.createDate(
                byAddingMinutes: -notificationsMinutesBefore.value, to: expirationDate
            ) {

            return notificationTime < now.now
        }
        return false
    }

    public var expiresOvernight: Bool {
        guard let expirationDate = expiration, !isExpired else { return false }
        return expirationDate.isOvernight()
    }

    public var siteNameBackUp: String? {
        // Ignore backup name if there _is_ a site relationship.
        get { siteId == nil ? hormoneData.siteNameBackUp : nil }
        set { hormoneData.siteNameBackUp = newValue }
    }

    public var isEmpty: Bool {
        !hasDate && !hasSite
    }

    public var hasSite: Bool {
        siteId != nil || siteNameBackUp != nil
    }

    public var hasDate: Bool {
        !date.isDefault()
    }

    public func stamp() {
        hormoneData.date = now.now
    }

    public func reset() {
        hormoneData.date = nil
        hormoneData.siteRelationshipId = nil
        hormoneData.siteNameBackUp = nil
    }

    public func createExpirationDate(from startDate: Date) -> Date? {
        DateFactory.createExpirationDate(expirationInterval: expirationInterval, to: date)
    }

    private var backupSiteName: String {
        var backupSite = hormoneData.siteNameBackUp ?? SiteStrings.NewSite
        if backupSite.isEmpty {
            backupSite = SiteStrings.NewSite
        }
        return backupSite
    }
}
