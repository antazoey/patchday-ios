//
//  Observatory.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/17/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class Observatory: PDObserving {
	func add(source: AnyObject, selector: Selector) {
		NotificationCenter.default.addObserver(
			source,
			selector: selector,
			name: UIApplication.willEnterForegroundNotification,
			object: nil
		)
	}
}
