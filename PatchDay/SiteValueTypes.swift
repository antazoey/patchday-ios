//
// Created by Juliya Smith on 12/2/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

struct ImageStruct {
    let image: UIImage
    let imageKey: SiteName
}

struct SiteCellProperties {
    var site: Bodily? = nil
    var rowIndex: Index = 0
    var totalSiteCount: Int = 0
    var nextSiteIndex: Int = 0
    var theme: AppTheme? = nil
}

struct SiteSelectionState {
    var siteScheduleIndex: Int = -1
    var hasChanged: Bool = false
}

struct BarItemInitializationProperties {
    var sitesViewController: UIViewController
    var cellActionState: SiteCellActionState
    var oppositeActionTitle: String
    var reset: Selector
    var insert: Selector
}

enum SiteCellActionState {
    case Editing
    case Reading
    case Unknown
}