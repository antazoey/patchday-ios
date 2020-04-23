//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//


public class SiteImageDeterminationParameters {

    public var siteName: SiteName?
    public var deliveryMethod: DeliveryMethod

    public init(siteName: SiteName, deliveryMethod: DeliveryMethod) {
        self.siteName = siteName
        self.deliveryMethod = deliveryMethod
    }

    public init(hormone: Hormonal?, deliveryMethod: DeliveryMethod) {
        self.siteName = hormone?.siteName
        self.deliveryMethod = deliveryMethod
    }

    public init(deliveryMethod: DeliveryMethod) {
        self.deliveryMethod = deliveryMethod
    }
}
