//
//  AlertFactory.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/14/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class AlertFactory: AlertProducing {

	func createHormoneActions(
		_ currentSite: SiteName,
		_ suggestSiteName: SiteName?,
		_ change: @escaping () -> Void,
		_ nav: @escaping () -> Void
	) -> PDAlerting {
		HormoneCellActionAlert(
			currentSite: currentSite, nextSite: suggestSiteName, changeHormone: change, nav: nav
		)
	}
}
