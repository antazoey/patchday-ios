//
//  PDTO.swift
//  PDKit
//
//  Created by Juliya Smith on 4/26/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

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

    public var imageId: SiteName?
    public var deliveryMethod: DeliveryMethod

	public init(imageId: SiteName, deliveryMethod: DeliveryMethod) {
        self.imageId = imageId
        self.deliveryMethod = deliveryMethod
    }

    public init(hormone: Hormonal?) {
		guard let hormone = hormone else {
			self.imageId = nil
			self.deliveryMethod = DefaultSettings.DeliveryMethodValue
			return
		}
		self.imageId = hormone.hasSite ? hormone.siteImageId : nil

		// If siteImageId is empty string somehow, use site name directly.
		if self.imageId == "" {
			self.imageId = hormone.siteName
		}

		// If still empty string (from site name), use default string for new sites.
		if self.imageId == "" {
			self.imageId = SiteStrings.NewSite
		}
		self.deliveryMethod = hormone.deliveryMethod
		return
    }

    public init(deliveryMethod: DeliveryMethod) {
        self.deliveryMethod = deliveryMethod
    }
}

public struct PillAttributes {
    private let defaultName = PillStrings.NewPill
    public var description: String { "Pill DTO" }

	// Pill Properties
    public var name: String?
    public var expirationInterval: String?
    public var timesaday: Int?
	public var times: String?
    public var notify: Bool?
    public var timesTakenToday: Int?
    public var lastTaken: Date?

    public init(
        name: String?,
        expirationInterval: String?,
        timesaday: Int?,
		times: String?,
        notify: Bool?,
        timesTakenToday: Int?,
        lastTaken: Date?
    ) {
        self.name = name
        self.expirationInterval = expirationInterval
        self.timesaday = timesaday
		self.times = times
        self.notify = notify
        self.timesTakenToday = timesTakenToday
        self.lastTaken = lastTaken
    }

    public init() {
    }

	public var anyAttributeExists: Bool {
		name != nil ||
		expirationInterval != nil ||
		timesaday != nil ||
		times != nil ||
		notify != nil ||
		timesTakenToday != nil ||
		lastTaken != nil
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
	public var siteImageId: SiteName?
    public var date: Date?
    public var siteNameBackUp: String?

    public init(_ id: UUID) {
        self.siteRelationshipId = nil
        self.id = id
        self.siteName = nil
		self.siteImageId = nil
        self.date = nil
        self.siteNameBackUp = nil
    }

    public init(
        _ id: UUID,
        _ siteRelationshipId: UUID?,
        _ siteName: SiteName?,
		_ siteImageId: SiteName?,
        _ date: Date?,
        _ siteNameBackUp: String?
    ) {
        self.id = id
        self.siteRelationshipId = siteRelationshipId
        self.siteName = siteName
		self.siteImageId = siteImageId
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
