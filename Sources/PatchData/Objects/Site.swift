//
//  Site.swift
//  PatchData
//
//  Created by Juliya Smith on 9/3/19.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class Site: Bodily {

    private var siteData: SiteStruct

    public init(siteData: SiteStruct) {
        self.siteData = siteData
    }

    public var hormoneIds: [UUID] {
        siteData.hormoneRelationshipIds ?? []
    }

    public var hormoneCount: Int {
        hormoneIds.count
    }

    public var id: UUID {
        siteData.id
    }

    public var imageId: String {
        get {
            guard let id = siteData.imageIdentifier else {
                return name
            }
            if id == "" || id == SiteStrings.NewSite {
                return name
            }
            return id
        }
        set { siteData.imageIdentifier = newValue }
    }

    public var name: SiteName {
        get {
            guard let storedName = siteData.name else {
                return SiteStrings.NewSite
            }
            return storedName != "" ? storedName : SiteStrings.NewSite

        }
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

    public func reset() {
        siteData.order = -1
        siteData.name = nil
        siteData.imageIdentifier = nil
        siteData.hormoneRelationshipIds = nil
    }
}
