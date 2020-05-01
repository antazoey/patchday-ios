//
//  PDTO.swift
//  PDKit
//
//  Created by Juliya Smith on 4/26/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


public struct HormoneScheduleProperties {

    public var expirationInterval: ExpirationIntervalUD
    public var deliveryMethod: DeliveryMethod
    public var notificationsMinutesBefore: NotificationsMinutesBeforeUD

    public init(_ settings: UserDefaultsReading) {
        self.expirationInterval = settings.expirationInterval
        self.deliveryMethod = settings.deliveryMethod.value
        self.notificationsMinutesBefore = settings.notificationsMinutesBefore
    }

    public init(
        _ expirationInterval: ExpirationIntervalUD,
        _ deliveryMethod: DeliveryMethod,
        _ notificationsMinutesBefore: NotificationsMinutesBeforeUD) {

        self.expirationInterval = expirationInterval
        self.deliveryMethod = deliveryMethod
        self.notificationsMinutesBefore = notificationsMinutesBefore
    }
}


public struct PillDueDateFinderParams {
    public var timesTakenToday: Int
    public var timesaday: Int
    public var times: [Time]

    public init(_ timesTakenToday: Int, _ timesaday: Int, _ times: [Time]) {
        self.timesTakenToday = timesTakenToday
        self.timesaday = timesaday
        self.times = times
    }
}



public class SiteImageDeterminationParameters {

    public var siteName: SiteName?
    public var deliveryMethod: DeliveryMethod

    public init(siteName: SiteName, deliveryMethod: DeliveryMethod) {
        self.siteName = siteName
        self.deliveryMethod = deliveryMethod
    }

    public init(hormone: Hormonal?, deliveryMethod: DeliveryMethod) {
        self.siteName = hormone?.siteName
        self.deliveryMethod = deliveryMethod
    }

    public init(deliveryMethod: DeliveryMethod) {
        self.deliveryMethod = deliveryMethod
    }
}


public struct PillAttributes {

    private let defaultName = PillStrings.NewPill

    public var description: String { "Pill DTO" }

    public var name: String?
    public var expirationInterval: String?
    public var timesaday: Int?
    public var time1: Time?
    public var time2: Time?
    public var notify: Bool?
    public var timesTakenToday: Int?
    public var lastTaken: Date?
    public init(
        name: String?,
        expirationInterval: String?,
        timesaday: Int?,
        time1: Time?,
        time2: Time?,
        notify: Bool?,
        timesTakenToday: Int?,
        lastTaken: Date?
    ) {
        self.name = name
        self.expirationInterval = expirationInterval
        self.timesaday = timesaday
        self.time1 = time1
        self.time2 = time2
        self.notify = notify
        self.timesTakenToday = timesTakenToday
        self.lastTaken = lastTaken
    }

    public init() {
        self.notify = true
    }
}


public struct SiteStruct {

    public var id: UUID
    public var hormoneRelationshipIds: [UUID]?
    public var imageIdentifier: String?
    public var name: String?
    public var order: Int

    public init(_ id: UUID) {
        self.id = id
        self.hormoneRelationshipIds = nil
        self.imageIdentifier = nil
        self.name = nil
        self.order = -1
    }

    public init(
        _ id: UUID,
        _ hormoneRelationship: [UUID]?,
        _ imageIdentifier: String?,
        _ name: String?,
        _ order: Int
    ) {
        self.id = id
        self.hormoneRelationshipIds = hormoneRelationship
        self.imageIdentifier = imageIdentifier
        self.name = name
        self.order = order
    }
}


public struct HormoneStruct {
    public var siteRelationshipId: UUID?
    public var id: UUID
    public var siteName: SiteName?
    public var date: Date?
    public var siteNameBackUp: String?

    public init(_ id: UUID) {
        self.id = id
        self.siteRelationshipId = nil
        self.siteName = nil
        self.date = nil
        self.siteNameBackUp = nil
    }

    public init(
        _ id: UUID,
        _ siteRelationshipId: UUID?,
        _ siteName: SiteName?,
        _ date: Date?,
        _ siteNameBackUp: String?
    ) {
        self.id = id
        self.siteRelationshipId = siteRelationshipId
        self.siteName = siteName
        self.date = date
        self.siteNameBackUp = siteNameBackUp
    }
}


public struct PillStruct {
    public var id: UUID
    public var attributes: PillAttributes

    public init(_ id: UUID, _ attributes: PillAttributes) {
        self.id = id
        self.attributes = attributes
    }
}
