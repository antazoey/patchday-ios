//
// Created by Juliya Smith on 12/19/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public struct SiteStruct {
    public var hormoneRelationshipIds: [UUID]?
    public var imageIdentifier: String?
    public var name: String?
    public var order: Int

    public init(_ hormoneRelationship: [UUID]?, _ imageIdentifier: String?, _ name: String?, _ order: Int) {
        self.hormoneRelationshipIds = hormoneRelationship
        self.imageIdentifier = imageIdentifier
        self.name = name
        self.order = order
    }
}
