//
// Created by Juliya Smith on 12/10/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

struct SiteImagePickerDelegateProperties {
    var selectedSiteIndex: Index?
    var imageChoices: [UIImage] = []
    var views: SiteImagePickerDelegateRelatedViews?
    var selectedImageIndex: Index?
}

struct SiteImagePickerDelegateRelatedViews {
    var getPicker: () -> UIPickerView
    var getImageView: () -> UIImageView
    var getSaveButton: () -> UIBarButtonItem
}

struct SiteDetailViewModelConstructorParams {
    var siteIndex: Index
    var imageSelectionParams: SiteImageDeterminationParameters
    var relatedViews: SiteImagePickerDelegateRelatedViews
    var deliveryMethod: DeliveryMethod

    init(
        _ siteIndex: Index,
        _ imageParams: SiteImageDeterminationParameters,
        _ relateViews: SiteImagePickerDelegateRelatedViews
    ) {
        self.siteIndex = siteIndex
        self.imageSelectionParams = imageParams
        self.relatedViews = relateViews
        self.deliveryMethod = imageParams.deliveryMethod
    }
}
