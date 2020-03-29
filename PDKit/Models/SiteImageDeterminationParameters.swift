//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//


public class SiteImageDeterminationParameters {

    public var siteName: SiteName?
    public var deliveryMethod: DeliveryMethod
    public var theme: PDTheme

    public init(siteName: SiteName, deliveryMethod: DeliveryMethod, theme: PDTheme) {
        self.siteName = siteName
        self.deliveryMethod = deliveryMethod
        self.theme = theme
    }

    public init(hormone: Hormonal?, deliveryMethod: DeliveryMethod, theme: PDTheme) {
        self.siteName = hormone?.siteName
        self.deliveryMethod = deliveryMethod
        self.theme = theme
    }

    public init(deliveryMethod: DeliveryMethod, theme: PDTheme) {
        self.deliveryMethod = deliveryMethod
        self.theme = theme
    }

    public var imageType: SiteImageTypeAdapter.SiteImageType {
        SiteImageTypeAdapter.convertToSiteImageType(deliveryMethod: deliveryMethod, theme: theme)
    }
}
