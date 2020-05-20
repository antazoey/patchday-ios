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

	private let sdk: PatchDataSDK?
	
	init(sdk: PatchDataSDK?) {
		self.sdk = sdk
	}
	
	func reflect() {
		UIApplication.shared.applicationIconBadgeNumber = sdk?.totalAlerts ?? 0
		PDLog<PDBadge>().info("Badge number set to \(UIApplication.shared.applicationIconBadgeNumber)")
	}
}
