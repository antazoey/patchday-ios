//
// Created by Juliya Smith on 11/26/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


struct HormoneSelectionState {
    var selectedSite: Bodily?
    var selectedDate: Date?
    var selectedSiteIndex: Index {
        selectedSite?.order ?? -1
    }
}

struct HormoneExpirationState {
    var wasExpiredBeforeSave = false
    var wasPastAlertTimeAfterSave = false
    var isExpiredAfterSave = false
}

enum HormoneCellState {
    case Occupied
    case Waiting
    case Empty
}