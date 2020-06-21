//
//  AlertCreating.swift
//  PDKit
//
//  Created by Juliya Smith on 6/14/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public protocol AlertProducing {
	func createHormoneActions(
		_ currentSite: SiteName,
		_ suggestSiteName: SiteName?,
		_ change: @escaping () -> Void,
		_ nav: @escaping () -> Void
	) -> PDAlerting
}
