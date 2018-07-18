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
    
    public var images = UserDefaultsController.usingPatches() ? PDImages.patchImages : PDImages.injectionImages
    public var picker: UIPickerView
    public var doneButton: UIButton
    public var imageView: UIImageView
    public var imageButton: UIButton
    public var nameButton: UIButton
    public var nameTextField: UITextField
    public var saveButton: UIBarButtonItem
    public var selectedSiteIndex: Int
    
    public var selectedImage: UIImage?
    
    init(with picker: UIPickerView, and imageView: UIImageView, imageButton: UIButton, nameButton: UIButton, nameTextField: UITextField, saveButton: UIBarButtonItem, selectedSiteIndex: Int, doneButton: UIButton) {
        self.picker = picker
        self.imageView = imageView
        self.imageButton = imageButton
        self.nameButton = nameButton
        self.nameTextField = nameTextField
        self.saveButton = saveButton
        self.selectedSiteIndex = selectedSiteIndex
        self.doneButton = doneButton
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
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let size = CGSize(width: 171.5, height: 240.0)
        let img = PDImages.resizeImage(image: images[row], targetSize: size)
        let imgView = (row < images.count) ? UIImageView(image: img) : UIView()
        return imgView
    }

    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < images.count && row >= 0 {
            selectedImage = images[row]
        }
    }
 
    public func openPicker() {
        UIView.transition(with: picker as UIView, duration: 0.4, options: .transitionFlipFromTop, animations: { self.picker.isHidden = false; self.imageView.isHidden = true
        })
        nameButton.isEnabled = false
        imageButton.isEnabled = false
        nameTextField.isEnabled = false
        doneButton.isHidden = false
        doneButton.isEnabled = true
        
        if selectedImage == nil {
            selectedImage = imageView.image
        }
        if let i = images.index(of: selectedImage!) {
            picker.selectRow(i, inComponent: 0, animated: false)
        }
    }
    
}
