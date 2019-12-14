//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import PDKit


class SiteImageTypeAdapter {

    enum SiteImageType {
        case LightPatch
        case DarkPatch
        case LightInjection
        case DarkInjection
    }

    static func convertToSiteImageType(deliveryMethod: DeliveryMethod, theme: PDTheme) -> SiteImageType {
        switch (deliveryMethod, theme) {
        case (.Patches, .Light): return .LightPatch
        case (.Patches, .Dark): return .DarkPatch
        case (.Injections, .Light): return .LightInjection
        case (.Injections, .Dark): return .DarkInjection
        }
    }
}
