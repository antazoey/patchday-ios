//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


public typealias UIIcon = UIImage


class PDIcons {

    // Site Index Icons
    private static let calendarIcon = { UIIcon(named: "Calendar Icon")! }()
    private static let siteIndexIcon = { UIIcon(named: "Site Index Icon")! }()
    private static let siteIndexIconOne = { UIIcon(named: "Site Index Icon 1")! }()
    private static let siteIndexIconTwo = { UIIcon(named: "Site Index Icon 2")! }()
    private static let siteIndexIconThree = { UIIcon(named: "Site Index Icon 3")! }()
    private static let siteIndexIconFour = { UIIcon(named: "Site Index Icon 4")! }()

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

    /// Returns a site icon representing the site index
    static func getSiteIndexIcon(for site: Bodily) -> UIIcon {
        switch site.hormones.count {
        case 1: return siteIndexIconOne
        case 2: return siteIndexIconTwo
        case 3: return siteIndexIconThree
        case 4: return siteIndexIconFour
        default: return siteIndexIcon
        }
    }
}
