//
//  MockPill.swift
//  PDMock
//
//  Created by Juliya Smith on 1/16/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockPill: Swallowable {

    // Mock-related properties
    public var setCallArgs: [PillAttributes] = []
    public var swallowCallCount = 0
    public var awakenCallCount = 0

    // Swallowable properties
    public var id: UUID = UUID()
    public var attributes: PillAttributes = PillAttributes()
    public var name: String = ""
    public var expirationInterval: String = ""
    public var times: [Time] = []
    public var notify: Bool = false
    public var timesaday: Int = -1
    public var timesTakenToday: Int = -1
    public var lastTaken: Date?
    public var due: Date? = Date()
    public var isDue: Bool = false
    public var isNew: Bool = false
    public var isDone: Bool = false

    public init() { }

    public func set(attributes: PillAttributes) {
        setCallArgs.append(attributes)
    }

    public func swallow() {
        swallowCallCount += 1
    }

    public func awaken() {
        awakenCallCount += 1
    }
}
