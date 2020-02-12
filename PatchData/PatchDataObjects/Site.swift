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
        // `siteData.imageIdentifier` should never be nil, but it wouldn't be catastrophic if it was..
        // Therefore, treat it like it's not (without force-unwrapping).
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

    public func reset() {
        siteData.order = -1
        siteData.name = nil
        siteData.imageIdentifier = nil
        siteData.hormoneRelationshipIds = nil
    }
}
