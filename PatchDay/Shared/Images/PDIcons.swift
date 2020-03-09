//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


public typealias UIIcon = UIImage


class PDIcons {

    static let siteIndexIcon = { UIIcon(named: "Site Index Icon")! }()

    // Delivery Method icons
    private static let patchIcon = { UIIcon(named: "Patch Icon")! }()
    private static let injectionIcon = { UIIcon(named: "Injection Icon")! }()

    static let settingsIcon = { UIIcon(named: "Settings Icon")! }()

    static func getDeliveryIcon(_ method: DeliveryMethod) -> UIIcon {
        switch method {
        case .Patches: return patchIcon
        case .Injections: return injectionIcon
        }
    }
}
