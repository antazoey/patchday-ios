//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import PDKit

// `SiteImageDeterminationParameters` is a class instead of a struct to make it easier to mutate during the
// determination process.

class SiteImageDeterminationParameters {
    var siteIndex: Index = 0
    var siteName: SiteName
    var deliveryMethod: DeliveryMethod
    var theme: PDTheme

    init(siteIndex: Index, siteName: SiteName, deliveryMethod: DeliveryMethod, theme: PDTheme) {
        self.siteIndex = siteIndex
        self.siteName = siteName
        self.deliveryMethod = deliveryMethod
        self.theme = theme
    }
}
