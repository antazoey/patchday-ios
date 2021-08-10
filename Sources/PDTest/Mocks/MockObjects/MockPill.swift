//
//  MockPill.swift
//  PDTest
//
//  Created by Juliya Smith on 1/16/20.

import Foundation
import PDKit

public class MockPill: Swallowable {
    public var id = UUID()
    public var attributes = PillAttributes()
    public var name = ""
    public var times: [Time] = []
    public var notify = false
    public var expirationInterval = PillExpirationInterval(.EveryDay)
    public var timesaday = -1
    public var timesTakenToday = -1
    public var lastTaken: Date?
    public var due: Date? = Date()
    public var isDue = false
    public var isNew = false
    public var isDone = false
    public var hasName = false
    public var timesTakenTodayList = PillTimesTakenTodayList()
    public var lastWakeUp = Date()
    public var isCreated = true
    public var wokeUpToday = false

    public init() { }

    public var expirationIntervalSetting: PillExpirationIntervalSetting {
        expirationInterval.value!
    }

    public var setCallArgs: [PillAttributes] = []
    public func set(attributes: PillAttributes) {
        setCallArgs.append(attributes)
    }

    public var swallowCallCount = 0
    public func swallow() {
        swallowCallCount += 1
    }

    public var unswallowCallCount = 0
    public func unswallow() {
        unswallowCallCount += 1
    }

    public var awakenCallCount = 0
    public func awaken() {
        awakenCallCount += 1
    }

    public var appendTimeCallArgs: [Time] = []
    public func appendTime(_ time: Time) {
        appendTimeCallArgs.append(time)
    }
}
