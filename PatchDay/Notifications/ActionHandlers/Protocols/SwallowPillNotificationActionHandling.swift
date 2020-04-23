//
//  SwallowPillNotificationActionHandling.swift
//  PDKit
//
//  Created by Juliya Smith on 10/7/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public protocol SwallowPillNotificationActionHandling {

	var requestPillNotification: ((_ pill: Swallowable) -> ())? { get set }

	/// A handler for a due-pill notification action for swallowing a pill.
	func swallow(pillUid: String)
}
