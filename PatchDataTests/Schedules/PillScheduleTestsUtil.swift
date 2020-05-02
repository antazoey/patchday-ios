//
//  PillScheduleTestsUtil.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/22/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit
import PDMock

@testable
import PatchData

class PillScheduleTestsUtil {

	private var mockStore: MockPillStore
	private var mockDataSharer: MockPillDataSharer

	init(_ mockStore: MockPillStore, _ mockDataSharer: MockPillDataSharer) {
		self.mockStore = mockStore
		self.mockDataSharer = mockDataSharer
	}

	func createThreePills() -> [MockPill] {
		[MockPill(), MockPill(), MockPill()]
	}

	func didSave(with pills: [MockPill]) -> Bool {
		if let lastCall = getMostRecentCallToPush() {
			for pill in pills {
				if !lastCall.0.contains(where: { (_ p: Swallowable) -> Bool in p.id == pill.id }) {
					return false
				}
			}
			return lastCall.1
		}
		return false
	}

	func getMostRecentCallToPush() -> ([Swallowable], Bool)? {
		let args = mockStore.pushLocalChangesCallArgs
		if args.count == 0 {
			return nil
		}
		return args[args.count - 1]
	}

	func nextPillDueWasShared(_ pills: PillSchedule) -> Bool {
		pills.nextDue?.id == mockDataSharer.shareCallArgs[0].id
	}
}
