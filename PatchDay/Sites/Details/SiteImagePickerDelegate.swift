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

    private var props: SiteImagePickerDelegateProperties
    
    init(props: SiteImagePickerDelegateProperties) {
        self.props = props
        super.init()
        props.views.picker.delegate = self
        props.views.picker.dataSource = self
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        props.imageOptions.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        DefaultNumberOfPickerComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        SiteDetailConstants.SiteImageRowHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        SiteDetailConstants.SiteImageRowWidth
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusing view: UIView?
    ) -> UIView {
        let size = SiteDetailConstants.SiteImageResizedSize

        if let image = props.imageOptions.tryGet(at: row) {
            let resizedImage = ImageResizer.resize(image, targetSize: size)
            return UIImageView(image: resizedImage)
        }
        return UIImageView()
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        props.selectedImageIndex = row
    }
 
    public func openPicker(closure: @escaping () -> ()) {
        showPicker()
        if let image = props.views.imageView.image, let index = props.imageOptions.firstIndex(of: image) {
            props.views.picker.selectRow(index, inComponent: index, animated: false)
        }
        closure()
    }

    private func showPicker() {
        UIView.transition(
            with: props.views.picker as UIView,
            duration: 0.4,
            options: .transitionFlipFromTop,
            animations: { self.props.views.picker.isHidden = false; self.props.views.saveButton.isEnabled = true }
        )
    }
}
