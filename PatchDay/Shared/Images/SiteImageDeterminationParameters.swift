//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import PDKit


class SiteImageDeterminationParameters {
    var siteIndex: Index?
    var siteName: SiteName?
    var deliveryMethod: DeliveryMethod
    var theme: PDTheme

    init(siteIndex: Index, siteName: SiteName, deliveryMethod: DeliveryMethod, theme: PDTheme) {
        self.siteIndex = siteIndex
        self.siteName = siteName
        self.deliveryMethod = deliveryMethod
        self.theme = theme
    }

    init(hormone: Hormonal, deliveryMethod: DeliveryMethod, theme: PDTheme) {
        if let site = hormone.site {
            self.siteIndex = site.order
            self.siteName = site.name
        }
        self.deliveryMethod = deliveryMethod
        self.theme = theme
    }

    init(deliveryMethod: DeliveryMethod, theme: PDTheme) {
        self.deliveryMethod = deliveryMethod
        self.theme = theme
    }

    var imageType: SiteImageTypeAdapter.SiteImageType {
        SiteImageTypeAdapter.convertToSiteImageType(deliveryMethod: deliveryMethod, theme: theme)
    }
}
