//
//  Site.swift
//  PatchData
//
//  Created by Juliya Smith on 9/3/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class Site: Bodily {

    private var siteData: SiteStruct
    private let expirationInterval: ExpirationIntervalUD
    private let deliveryMethod: DeliveryMethod
    
    public init(siteData: SiteStruct, expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) {
        self.siteData = siteData
        self.expirationInterval = expirationInterval
        self.deliveryMethod = deliveryMethod
    }

    public var hormoneIds: [UUID] {
        siteData.hormoneRelationshipIds ?? []
    }

    public var hormoneCount: Int {
        hormoneIds.count
    }

    public var id: UUID {
        if let id = siteData.id {
            return id
        }
        let id = UUID()
        siteData.id = id
        return id
    }
    
    public var imageId: String {
        get { siteData.imageIdentifier ?? "" }
        set { siteData.imageIdentifier = newValue }
    }
    
    public var name: SiteName {
        get { siteData.name ?? "" }
        set { siteData.name = newValue }
    }
    
    public var order: Int {
        get { siteData.order }
        set {
            if newValue >= 0 {
                siteData.order = newValue
            }
        }
    }
    
    public var isOccupied: Bool { isOccupied() }

    public func isOccupied(byAtLeast many: Int = 1) -> Bool {
        if let r = siteData.hormoneRelationshipIds {
            return r.count >= many
        }
        return false
    }
    
    public func reset() {
        siteData.order = -1
        siteData.name = nil
        siteData.imageIdentifier = nil
        siteData.hormoneRelationshipIds = nil
    }
    
    public func isEqualTo(_ otherSite: Bodily) -> Bool {
        name == otherSite.name && order == otherSite.order
    }
}
