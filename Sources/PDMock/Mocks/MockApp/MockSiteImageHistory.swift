//
//  MockSiteImageHistory.swift
//  PDMock
//
//  Created by Juliya Smith on 11/4/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockSiteImageHistory: SiteImageHistorical {

    public init() {}

    public var subscriptCallArgs: [Index] = []
    public var subscriptMockImplementation: (Index) -> SiteImageRecording = {
        _ in MockSiteImageRecorder()
    }
    public subscript(index: Index) -> SiteImageRecording {
        subscriptCallArgs.append(index)
        return subscriptMockImplementation(index)
    }
}
