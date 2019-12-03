//
// Created by Juliya Smith on 12/2/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

struct SiteCellProperties {
    var site: Bodily? = nil
    var rowIndex: Index = 0
    var totalSiteCount: Int = 0
    var nextSiteIndex: Int = 0
    var isEditing: Bool = false
    var theme: AppTheme? = nil
}