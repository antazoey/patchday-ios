//
// Created by Juliya Smith on 12/19/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public struct PillStruct {
    public var id: UUID
    public var attributes: PillAttributes

    public init(_ id: UUID, _ attributes: PillAttributes = PillAttributes()) {
        self.id = id
        self.attributes = attributes
    }
}
