//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PDIcons {

    private static var patchIcon: UIIcon { UIIcon(named: "Patch Icon") ?? UIIcon() }
    private static var injectionIcon: UIIcon { UIIcon(named: "Injection Icon") ?? UIIcon()}
    private static var gelIcon: UIIcon { UIIcon(named: "Gel Icon") ?? UIIcon() }
    private static var pillIcon: UIIcon { UIIcon(named: "Pill Icon") ?? UIIcon() }
    static var siteIndexIcon: UIIcon { UIIcon(named: "Site Index Icon") ?? UIIcon() }
    static var settingsIcon: UIIcon { UIIcon(named: "Settings Icon") ?? UIIcon() }
    static var moonIcon: UIIcon { UIIcon(named: "Moon") ?? UIImage() }

    static subscript(method: DeliveryMethod) -> UIIcon {
        switch method {
            case .Patches: return patchIcon
            case .Injections: return injectionIcon
            case .Gel: return gelIcon
        }
    }
}
