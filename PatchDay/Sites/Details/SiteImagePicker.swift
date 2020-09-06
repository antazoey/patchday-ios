//
//  SiteImagePickerDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/12/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SiteImagePicker: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {

    var _props: SiteImagePickerDelegateProperties

    init(props: SiteImagePickerDelegateProperties) {
        self._props = props
        super.init()
    }

    /// Tracks if the selected image has changed
    var didSelectImage = false

    var picker: UIPickerView { _props.views?.getPicker() ?? UIPickerView() }

    var imageView: UIImageView { _props.views?.getImageView() ?? UIImageView() }

    var options: [UIImage?] { _props.imageChoices }

    var selectedRow: Index? { _props.selectedImageIndex ?? picker.getSelectedRow() }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        _props.imageChoices.count
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
        if let image = getImage(at: row) {
            let resizedImage = ImageResizer.resize(image, targetSize: size)
            return UIImageView(image: resizedImage)
        }
        return UIImageView()
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _props.selectedImageIndex = row
        if let imageView = _props.views?.getImageView() {
            imageView.image = getImage(at: row)
            didSelectImage = true
        }
    }

    public func openPicker(completion: @escaping () -> Void) {
        showPicker {
            completion()
        }
    }

    private func getImage(at row: Index) -> UIImage? {
        _props.imageChoices.tryGet(at: row)
    }

    private func showPicker(completion: @escaping () -> Void) {
        guard let picker = _props.views?.getPicker() else { return }
        let startRow = _props.selectedImageIndex ?? 0
        picker.selectRow(startRow)
        UIView.transition(
            with: picker as UIView,
            duration: 0.4,
            options: .transitionFlipFromTop,
            animations: {
                picker.isHidden = false
                if let saveButton = self._props.views?.getSaveButton() {
                    saveButton.isEnabled = true
                }
            },
            completion: { _ in completion() }
        )
    }
}
