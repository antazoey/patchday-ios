//
//  PillDataSharer.swift
//  PatchData
//
//  Created by Juliya Smith on 1/16/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillDataSharer: PillDataSharing {

	private let baseSharer: UserDefaultsProtocol

	init(baseSharer: UserDefaultsProtocol) {
		self.baseSharer = baseSharer
	}

	public func share(nextPill: Swallowable) {
		baseSharer.set(nextPill.name, for: TodayKey.nextPillToTake.rawValue)
		baseSharer.set(nextPill.due, for: TodayKey.nextPillTakeTime.rawValue)
	}
}
