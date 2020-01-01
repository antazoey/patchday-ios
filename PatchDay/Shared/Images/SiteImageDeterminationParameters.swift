//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import PDKit


class SiteImageDeterminationParameters {
    var siteName: SiteName?
    var deliveryMethod: DeliveryMethod
    var theme: PDTheme

    init(siteName: SiteName, deliveryMethod: DeliveryMethod, theme: PDTheme) {
        self.siteName = siteName
        self.deliveryMethod = deliveryMethod
        self.theme = theme
    }

    init(hormone: Hormonal, deliveryMethod: DeliveryMethod, theme: PDTheme) {
        self.siteName = hormone.siteName
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
