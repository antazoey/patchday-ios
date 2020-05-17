//
//  PDBadge.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PDBadge: PDBadgeDelegate {

	private var badgeNumber = UIApplication.shared.applicationIconBadgeNumber
	private let sdk: PatchDataSDK?
	
	init(sdk: PatchDataSDK?) {
		self.sdk = sdk
	}
	
	func reflect() {
		badgeNumber = sdk?.totalAlerts ?? 0
	}
}
