//
// Created by Juliya Smith on 2/11/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockSiteSchedule: SiteScheduling {

	public var all: [Bodily] = []
	public var count: Int = -1
	public var suggested: Bodily? = nil
	public var nextIndex: Index = -1
	public var names: [SiteName] = []
	public var isDefault: Bool = false

	public var resetCallCount = 0

	public init() { }

	public func insertNew(name: String, save: Bool, onSuccess: (() -> ())?) -> Bodily? {
		nil
	}

	public subscript(id: UUID) -> Bodily? {
		nil
	}


	public subscript(index: Index) -> Bodily? {
		nil
	}

	public func rename(at index: Index, to name: SiteName) {

	}

	public func reorder(at index: Index, to newOrder: Int) {

	}

	public func setImageId(at index: Index, to newId: String) {

	}

	public func indexOf(_ site: Bodily) -> Index? {
        -1
	}

	public func sort() {

	}

	public func delete(at index: Index) {

	}

	public func reset() -> Int {
		resetCallCount += 1
		return 0
	}
}
