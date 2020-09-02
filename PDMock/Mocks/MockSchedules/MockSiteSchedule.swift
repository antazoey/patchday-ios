//
// Created by Juliya Smith on 2/11/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockSiteSchedule: SiteScheduling {

	public var all: [Bodily] = []
	public var count: Int = -1
	public var suggested: Bodily?
	public var nextIndex: Index = -1
	public var names: [SiteName] = []
	public var isDefault: Bool = false

	public init() { }

	public var reloadContextCallCount = 0
	public func reloadContext() {
		reloadContextCallCount += 1
	}

	public var insertNewCallArgs: [(String, (() -> Void)?)] = []
	public var insertNewReturnValue: Bodily?
	public func insertNew(name: String, onSuccess: (() -> Void)?) -> Bodily? {
		insertNewCallArgs.append((name, onSuccess))
		return insertNewReturnValue
	}

	public var subscriptIdCallArgs: [UUID] = []
	public var subscriptIdReturnValue: Bodily?
	public subscript(id: UUID) -> Bodily? {
		subscriptIdCallArgs.append(id)
		return subscriptIdReturnValue
	}

	public var subscriptIndexCallArgs: [Index] = []
	public var subscriptIndexReturnValue: Bodily?
	public subscript(index: Index) -> Bodily? {
		subscriptIndexCallArgs.append(index)
		return subscriptIndexReturnValue
	}

	public var renameCallArgs: [(Index, SiteName)] = []
	public func rename(at index: Index, to name: SiteName) {
		renameCallArgs.append((index, name))
	}

	public var reorderCallArgs: [(Index, Int)] = []
	public func reorder(at index: Index, to newOrder: Int) {
		reorderCallArgs.append((index, newOrder))
	}

	public var setImageIdCallArgs: [(Index, String)] = []
	public func setImageId(at index: Index, to newId: String) {
		setImageIdCallArgs.append((index, newId))
	}

	public var indexOfCallArgs: [Bodily] = []
	public var indexOfReturnValue: Index?
	public func indexOf(_ site: Bodily) -> Index? {
		indexOfCallArgs.append(site)
		return indexOfReturnValue
	}

	public var sortCallCount = 0
	public func sort() {
		sortCallCount += 1
	}

	public var deleteCallArgs: [Index] = []
	public func delete(at index: Index) {
		deleteCallArgs.append(index)
	}

	public var resetCallCount = 0
	public var resetReturnValue = -1
	public func reset() -> Int {
		resetCallCount += 1
		return resetReturnValue
	}
}
