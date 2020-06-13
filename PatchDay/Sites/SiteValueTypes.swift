//
// Created by Juliya Smith on 12/2/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

struct SiteImageStruct {
	let image: UIImage
	let name: SiteName
}

struct SiteCellProperties {
	var row: Index
	var site: Bodily?
	var totalSiteCount: Int = 0
	var nextSiteIndex: Int = 0
}

struct SiteSelectionState {
	var selectedSiteName: SiteName?

	var hasSelections: Bool {
		selectedSiteName != nil
	}
}

struct BarItemInitializationProperties {
	var sitesViewController: UIViewController
	var tableActionState: SiteTableActionState
	var oppositeActionTitle: String
	var reset: Selector
	var insert: Selector
}

enum SiteTableActionState {
	case Editing
	case Reading
	case Unknown
}
