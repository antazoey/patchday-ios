//
// Created by Juliya Smith on 12/19/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public struct HormoneStruct {
    public var siteRelationshipOrder: Int?
    public var id: UUID?
    public var date: Date?
    public var siteNameBackUp: String?

    public init(_ siteRelationshipOrder: Int?, _ id: UUID?, _ date: Date?, _ siteNameBackUp: String?) {
        self.siteRelationshipOrder = siteRelationshipOrder
        self.id = id
        self.date = date
        self.siteNameBackUp = siteNameBackUp
    }
}
