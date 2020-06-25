//
// Created by Juliya Smith on 11/26/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

struct HormoneSelectionState {
	var site: Bodily?
	var siteName: SiteName?
	var date: Date?
	var siteIndex: Index { site?.order ?? -1 }

	var hasSelections: Bool {
		let dateSelected = date != nil && date != DateFactory.createDefaultDate()
		let siteSelected = site != nil && siteIndex != -1
		return dateSelected || siteSelected
	}
}

enum HormoneMutation {
	case Add
	case Edit
	case Remove
	case None
	case Empty
}
