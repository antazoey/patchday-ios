//
// Created by Juliya Smith on 1/6/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockEntity {

    public var type: PDEntity = .hormone

    public init() { }

    public init(type: PDEntity) {
        self.type = type
    }
}
