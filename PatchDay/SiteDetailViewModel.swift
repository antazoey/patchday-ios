//
// Created by Juliya Smith on 12/3/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SiteDetailViewModel: CodeBehindDependencies {

    private var site: Bodily
    private let siteIndex: Index
    private var imagePickerDelegate: SiteImagePickerDelegate
    private var selections = SiteSelectionState()

    convenience init(_ site: Bodily, siteIndex: Index, siteImagePickerRelatedViews: SiteImagePickerDelegateRelatedViews) {
        let images = PDImages.siteImages(
            theme: sdk?.defaults.theme.value,
            deliveryMethod: sdk?.defaults.deliveryMethod.value
        )
        self.init(site, siteIndex: siteIndex, imageSelections: images, siteImagePickerRelatedViews: siteImagePickerRelatedViews)
    }

    convenience init(_ site: Bodily, siteIndex: Index, imageSelections: [UIImage], siteImagePickerRelatedViews: SiteImagePickerDelegateRelatedViews) {
        let pickerDelegateProps = SiteImagePickerDelegateProperties(
            selectedSite: site, imageOptions: imageSelections, views: siteImagePickerRelatedViews
        )
        self.init(site, siteIndex: siteIndex, imagePickerProps: pickerDelegateProps)
    }

    convenience init(_ site: Bodily, siteIndex: Index, imagePickerProps: SiteImagePickerDelegateProperties) {
        let imagePickerDelegate = SiteImagePickerDelegate(props: imagePickerProps, sdk: sdk)
        self.init(site, siteIndex: siteIndex, imagePickerDelegate: imagePickerDelegate)
    }

    init(_ site: Bodily, siteIndex: Index, imagePickerDelegate: SiteImagePickerDelegate) {
        self.site = site
        self.siteIndex = siteIndex
        self.imagePickerDelegate = imagePickerDelegate
        super.init()
    }

    @discardableResult func saveSiteImageChanges() -> UIImage {
        let image = createImageStruct(selectedRow: selections.siteScheduleIndex)
        sdk?.sites.setImageId(at: selections.siteScheduleIndex, to: image.name)
        return image.image
    }

    private func createImageStruct(selectedRow: Index) -> SiteImageStruct {
        let theme = sdk?.defaults.theme.value
        let method = sdk?.defaults.deliveryMethod.value
        let images = PDImages.siteImages(theme: theme, deliveryMethod: method)
        let image = images[selectedRow]
        let imageKey = PDImages.imageToSiteName(image)
        return SiteImageStruct(image: image, name: imageKey)
    }
}
