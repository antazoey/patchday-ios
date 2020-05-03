//
//  SiteImageHistory.swift
//  PatchDay
//
//  Created by Juliya Smith on 3/28/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SiteImageHistory {

	private var history: [UIImage?] = [nil, nil]
	var row: Index

	init(_ row: Index, _ image: UIImage? = nil) {
		self.row = row
		self.push(image)
	}

	var current: UIImage? { history[1] }

	@discardableResult
	func push(_ image: UIImage?) -> SiteImageHistory {
		history[0] = history[1]
		history[1] = image
		return self
	}

	func differentiate() -> HormoneMutation {
		var result = HormoneMutation.None
		switch (history[0], history[1]) {
			case (nil, nil): return .Empty
			case (nil, let h) where h != nil: result = .Add
			case (let h, nil) where h != nil: result = .Remove
			case (let h0, let h1) where h0 != h1: result = .Edit
			default: break
		}
		return result
	}

	private func logState() {
		let log = PDLog<SiteImageHistory>()
		let last = history[0]?.accessibilityIdentifier ?? "nil"
		let latest = history[1]?.accessibilityIdentifier ?? "nil"
		log.info("HormoneCell site image history last: \(last), Latest: \(latest)")
	}
}
