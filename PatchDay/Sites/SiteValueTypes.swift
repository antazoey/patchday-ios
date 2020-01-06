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
    var site: Bodily?
    var totalSiteCount: Int = 0
    var nextSiteIndex: Int = 0
    var theme: AppTheme?
}

struct SiteSelectionState {
    var selectedSiteImageRow: Index?
    var selectedSiteName: SiteName?
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