//
// Created by Juliya Smith on 11/27/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit

let isResetMode = false  // Change this to true to nuke the database
let app: AppDelegate? = UIApplication.shared.delegate as? AppDelegate

let DefaultNumberOfPickerComponents = 1


class ViewControllerIds {
    static let Hormone = "HormoneDetailVC_id"
    static let Pill = "PillDetailVC_id"
    static let Site = "SiteDetailVC_id"
    static let Settings = "SettingsVC_id"
}


class CellReuseIds {
    static let Hormone = "HormoneCellReuseId"
    static let Pill = "pillCellReuseId"
    static let Site = "siteCellReuseId"
}