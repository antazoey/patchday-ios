//
//  MockSiteImageHistory.swift
//  PDMock
//
//  Created by Juliya Smith on 11/4/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockSiteImageHistory: SiteImageHistorical {

    public init() {}

    public var subscriptCallArgs: [Index] = []
    public var subscriptReturnValue = MockSiteImageRecorder()
    public subscript(index: Index) -> SiteImageRecording {
        subscriptCallArgs.append(index)
        return subscriptReturnValue
    }
}
