//
//  SiteImagePickerDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/12/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SiteImagePickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {

    private var sdk: PatchDataDelegate

    public var images: [UIImage]
    public var picker: UIPickerView
    public var imageView: UIImageView
    public var saveButton: UIBarButtonItem
    public var selectedSite: Bodily
    public var selectedImage: UIImage?
    
    convenience init(with picker: UIPickerView,
                     and imageView: UIImageView,
                     saveButton: UIBarButtonItem,
                     selectedSite: Bodily,
                     deliveryMethod: DeliveryMethod) {
        self.init(with: picker,
                  and: imageView,
                  saveButton: saveButton,
                  selectedSite: selectedSite,
                  deliveryMethod: deliveryMethod,
                  sdk: app.sdk)
    }
    
    init(with picker: UIPickerView,
         and imageView: UIImageView,
         saveButton: UIBarButtonItem,
         selectedSite: Bodily,
         deliveryMethod: DeliveryMethod,
         sdk: PatchDataDelegate) {
        self.imageView = imageView
        self.images = PDImages.siteImages(theme: sdk.defaults.theme.value,
                                          deliveryMethod: deliveryMethod)
        self.picker = picker
        self.saveButton = saveButton
        self.selectedSite = selectedSite
        self.sdk = sdk
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return images.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 180
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let size = CGSize(width: 330.1375, height: 462.0)
        let img = ModiiImageResizer.resizeImage(images[row], targetSize: size)
        let imgView = (row < images.count) ? UIImageView(image: img) : UIView()
        return imgView
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < images.count && row >= 0 {
            selectedImage = images[row]
        }
    }
 
    public func openPicker(closure: @escaping () -> ()) {
        UIView.transition(with: picker as UIView,
                          duration: 0.4,
                          options: .transitionFlipFromTop,
                          animations: {
                            self.picker.isHidden = false;
                            self.imageView.isHidden = true
                          }
                        )
        closure()
        if selectedImage == nil {
            selectedImage = imageView.image
        }
        if let i = images.firstIndex(of: selectedImage!) {
            picker.selectRow(i, inComponent: 0, animated: false)
            sdk.state.markSiteForImageMutation(site: selectedSite)
        }
    }
}
