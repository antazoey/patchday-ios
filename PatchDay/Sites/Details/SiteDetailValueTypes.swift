//
// Created by Juliya Smith on 12/10/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


struct SiteImagePickerDelegateProperties {
	var selectedSite: Bodily
	var imageOptions: [UIImage]
	var views: SiteImagePickerDelegateRelatedViews
	var selectedImageIndex: Index = 0
}

struct SiteImagePickerDelegateRelatedViews {
	var getPicker: () -> UIPickerView
	var getImageView: () -> UIImageView
	var getSaveButton: () -> UIBarButtonItem
}

struct SiteDetailViewModelConstructorParams {
	var site: Bodily
	var imageSelectionParams: SiteImageDeterminationParameters
	var relatedViews: SiteImagePickerDelegateRelatedViews

	init(
		_ site: Bodily,
		_ imageParams: SiteImageDeterminationParameters,
		_ relateViews: SiteImagePickerDelegateRelatedViews
	) {
		self.site = site
		self.imageSelectionParams = imageParams
		self.relatedViews = relateViews
	}
}
