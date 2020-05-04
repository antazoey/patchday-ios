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

	private let baseSharer: DataSharing

	init(baseSharer: DataSharing) {
		self.baseSharer = baseSharer
	}

	public func share(nextPill: Swallowable) {
		baseSharer.share(nextPill.name, forKey: TodayKey.nextPillToTake.rawValue)
		baseSharer.share(nextPill.due, forKey: TodayKey.nextPillTakeTime.rawValue)
	}
}
