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
    var picker: UIPickerView
    var imageView: UIImageView
    var saveButton: UIBarButtonItem
}
