//
//  MockSiteImageRecorder.swift
//  PDMock
//
//  Created by Juliya Smith on 11/4/20.

import Foundation
import PDKit

public class MockSiteImageRecorder: SiteImageRecording, Equatable {

    public init() {}

    private let id = UUID()
    public static func == (lhs: MockSiteImageRecorder, rhs: MockSiteImageRecorder) -> Bool {
        lhs.id == rhs.id
    }

    public var current: UIImage?

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
