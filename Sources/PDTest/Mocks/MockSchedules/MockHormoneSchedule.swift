//
// Created by Juliya Smith on 2/11/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockHormoneSchedule: HormoneScheduling {

    public var all: [Hormonal] = []

    public var isEmpty: Bool = false

    public var next: Hormonal?

    public var totalExpired: Int = -1

    public var count: Int {
        all.count
    }

    public var useStaticExpirationTime = false

    public init() { }

    public var insertNewReturnValue: Hormonal?
    public func insertNew() -> Hormonal? {
        insertNewReturnValue
    }

    public var reloadContextCallCount = 0
    public func reloadContext() {
        reloadContextCallCount += 1
    }

    public var resetCompletionCallArgs: [(() -> Void)?] = []
    public var resetCompletionReturnValue = -1
    public func reset(completion: (() -> Void)?) -> Int {
        resetCompletionCallArgs.append(completion)
        return resetCompletionReturnValue
    }

    public var saveAllCallCount = 0
    public func saveAll() {
        saveAllCallCount += 1
    }

    public var deleteCallArgs: [Index] = []
    public func delete(after i: Index) {
        deleteCallArgs.append(i)
    }

    public var deleteAllCallAcount = 0
    public func deleteAll() {
        deleteAllCallAcount += 1
    }

    public subscript(index: Index) -> Hormonal? {
        all.tryGet(at: index)
    }

    public subscript(id: UUID) -> Hormonal? {
        all.first(where: { $0.id == id })
    }

    public var setByIdCallArgs: [(UUID, Date, Bodily)] = []
    public func set(by id: UUID, date: Date, site: Bodily) {
        setByIdCallArgs.append((id, date, site))
    }

    public var setByIndexCallArgs: [(Index, Date, Bodily)] = []
    public func set(at index: Index, date: Date, site: Bodily) {
        setByIndexCallArgs.append((index, date, site))
    }

    public var setSiteByIdCallArgs: [(UUID, Bodily)] = []
    public func setSite(by id: UUID, with site: Bodily) {
        setSiteByIdCallArgs.append((id, site))
    }

    public var setSiteByIndexCallArgs: [(Index, Bodily)] = []
    public func setSite(at index: Index, with site: Bodily) {
        setSiteByIndexCallArgs.append((index, site))
    }

    public var setDateByIdCallArgs: [(UUID, Date)] = []
    public func setDate(by id: UUID, with date: Date) {
        setDateByIdCallArgs.append((id, date))
    }

    public var setDateByIndexCallArgs: [(Index, Date)] = []
    public func setDate(at index: Index, with date: Date) {
        setDateByIndexCallArgs.append((index, date))
    }

    public var setSiteNameCallArgs: [(UUID, SiteName)] = []
    public func setSiteName(by id: UUID, with siteName: SiteName) {
        setSiteNameCallArgs.append((id, siteName))
    }

    public var indexOfCallArgs: [Hormonal] = []
    public var indexOfReturnValue: Index?
    public func indexOf(_ hormone: Hormonal) -> Index? {
        indexOfCallArgs.append(hormone)
        return indexOfReturnValue
    }

    public var fillInCallArgs: [Int] = []
    public func fillIn(to stopCount: Int) {
        fillInCallArgs.append(stopCount)
    }

    public var shareDataCallCount = 0
    public func shareData() {
        shareDataCallCount += 1
    }

    public var sortCallCount = 0
    public func sort() {
        sortCallCount += 1
    }

    public var resetCallCount = 0
    public var resetReturnValue = -1
    public func reset() -> Int {
        resetCallCount += 1
        return resetReturnValue
    }
}
