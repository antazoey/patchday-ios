//
// Created by Juliya Smith on 12/19/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public struct HormoneStruct {
    public var siteRelationshipId: UUID?
    public var id: UUID?
    public var siteName: SiteName?
    public var date: Date?
    public var siteNameBackUp: String?

    public init(
        _ siteRelationshipId: UUID?,
        _ id: UUID?,
        _ siteName: SiteName?,
        _ date: Date?,
        _ siteNameBackUp: String?
    ) {
        self.siteRelationshipId = siteRelationshipId
        self.siteName = siteName
        self.id = id
        self.date = date
        self.siteNameBackUp = siteNameBackUp
    }
}
