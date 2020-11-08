//
//  MockSiteImageRecorder.swift
//  PDMock
//
//  Created by Juliya Smith on 11/4/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockSiteImageRecorder: SiteImageRecording {

    public init() {}

    public var current: UIImage? = nil

    public var pushCallArgs: [UIImage?] = []
    public func push(_ image: UIImage?) -> SiteImageRecording {
        pushCallArgs.append(image)
        return self
    }

    public var differentitateReturnValue: HormoneMutation = .Add
    public func differentiate() -> HormoneMutation {
        differentitateReturnValue
    }
}
