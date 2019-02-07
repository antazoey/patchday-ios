//
//  SiteVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class SiteVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    private var siteScheduleIndex: Int = -1
    private var hasChanged: Bool = false
    private var namePickerSet =
        Array(SiteScheduleRef.unionDefault(usingPatches: Defaults.usingPatches()))
    
    @IBOutlet weak var siteStack: UIStackView!
    @IBOutlet weak var typeNameButton: UIButton!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var namePicker: UIPickerView!
    @IBOutlet weak var gapAboveImage: UIView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imagePickerDoneButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var siteImage: UIImageView!
    @IBOutlet weak var imagePicker: UIPickerView!
    
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    private var imagePickerDelegate: SiteImagePickerDelegate?
    
    struct ImageStruct {
        let image: UIImage
        let imageKey: SiteName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.phone) {
            topConstraint.constant = 100
        }
        nameText.autocapitalizationType = .words
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: PDStrings.ActionStrings.save,
                            style: .plain,
                            target: self,
                            action: #selector(saveButtonTapped(_:)))
        disableSave()
        nameText.borderStyle = .none
        nameText.delegate = self
        namePicker.delegate = self
        namePicker.isHidden = true
        if let site = SiteScheduleRef.getSite(at: siteScheduleIndex) {
            imagePickerDelegate = SiteImagePickerDelegate(with: imagePicker,
                                                          and: siteImage,
                                                          imageButton: imageButton,
                                                          nameButton: typeNameButton,
                                                          nameTextField: nameText,
                                                          saveButton: navigationItem.rightBarButtonItem!,
                                                          selectedSite: site,
                                                          doneButton: imagePickerDoneButton,
                                                          usingPatches: Defaults.usingPatches())
            }
        imagePicker.delegate = imagePickerDelegate
        imagePicker.dataSource = imagePickerDelegate
        typeNameButton.setTitleColor(UIColor.lightGray, for: .disabled)
        loadTitle()
        loadImage()
    }
    
    public func setSiteScheduleIndex(to index: Int) {
        siteScheduleIndex = index
    }
    
    // MARK: - Actions
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        let usingPatches = Defaults.usingPatches()
        let imageStruct = usingPatches ?
            setImage(images: PDImages.patchImages,
                     imageNameFunction: PDImages.patchImageToSiteName(_:)) :
            setImage(images: PDImages.injectionImages,
                     imageNameFunction: PDImages.injectionImageToSiteName(_:))
        imagePicker.isHidden = true
        siteImage.image = imageStruct.image
        siteImage.isHidden = false
        imageButton.isEnabled = true
        typeNameButton.isEnabled = true
        nameText.isEnabled = true
        imagePickerDoneButton.isEnabled = false
        imagePickerDoneButton.isHidden = true
        enableSave()
        SiteScheduleRef.setImageId(at: siteScheduleIndex,
                                to: imageStruct.imageKey,
                                usingPatches: usingPatches)
    }
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        siteImage.isHidden = true
        imageButton.isEnabled = false
        imagePickerDelegate?.openPicker()
    }
    
    @IBAction func typeTapped(_ sender: Any) {
        nameText.restorationIdentifier = "type"
        nameText.becomeFirstResponder()
    }
    
    @objc func saveButtonTapped(_ sender: Any) {
        if let name = nameText.text {
            // Updating existing site
            let i = siteScheduleIndex
            let count = SiteScheduleRef.count()
            if i >= 0 && i < count {
                SiteScheduleRef.setName(at: i, to: name)
            } else if i == count,
                let _ = SiteScheduleRef.insert() {
                SiteScheduleRef.setName(at: i, to: name)
            }
        }
        segueToSitesVC()
    }
    
    // MARK: - Text field
    
    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        enableSave()
        if textField.restorationIdentifier == "type" {
            nameText.isEnabled = true
            typeNameButton.isEnabled = false
            textField.restorationIdentifier = "select"
        } else {
            // Select site from picker rather than type
            view.endEditing(true)
            nameText.isEnabled = false
            openPicker(namePicker)
        }
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if nameText.text == "" {
            nameText.text = PDStrings.PlaceholderStrings.new_site
        }
        typeNameButton.isEnabled = true
        if let name = nameText.text {
            SiteScheduleRef.setName(at: siteScheduleIndex, to: name)
        }
        loadImage()
        return true
    }
    
    // MARK: - Picker functions
    
    private func openPicker(_ picker: UIPickerView) {
        UIView.transition(with: picker as UIView,
                          duration: 0.4,
                          options: .transitionFlipFromTop,
                          animations: { picker.isHidden = false })
            self.typeNameButton.isEnabled = false
        if let n = nameText.text, let i = namePickerSet.index(of: n) {
            namePicker.selectRow(i, inComponent: 0, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return namePickerSet.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView,
                             titleForRow row: Int,
                             forComponent component: Int) -> String? {
        return namePickerSet[row]
    }
 
    internal func pickerView(_ pickerView: UIPickerView,
                             didSelectRow row: Int,
                             inComponent component: Int) {
        
        // Close picker
        UIView.transition(with: namePicker as UIView,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.namePicker.isHidden = true;
                            self.bottomLine.isHidden = false;
                            self.siteImage.isHidden = false
        }) {
            void in
            self.nameText.text = self.namePickerSet[row]
            self.typeNameButton.isEnabled = true
            self.nameText.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    // MARK: - Private
    
    private func setImage(images: [UIImage],
                          imageNameFunction: ((UIImage) -> SiteName)) -> ImageStruct {
        let image = images[imagePicker.selectedRow(inComponent: 0)]
        let imageKey = imageNameFunction(image)
        return ImageStruct(image: image, imageKey: imageKey)
    }
    
    private func segueToSitesVC() {
        if let sb = storyboard, let navCon = navigationController, let sitesVC = sb.instantiateViewController(withIdentifier: "SitesVC_id") as? SitesVC {
            sitesVC.siteNames = SiteScheduleRef.getNames()
            navCon.popViewController(animated: true)
        }
    }
    
    private func loadTitle() {
        let sites = SiteScheduleRef.sites
        if siteScheduleIndex >= 0 && siteScheduleIndex < sites.count {
            let site = sites[siteScheduleIndex]
            title = "\(PDStrings.TitleStrings.site) \(siteScheduleIndex + 1)"
            nameText.text = site.getName()
        } else {
            title = "\(PDStrings.TitleStrings.site) \(sites.count + 1)"
        }
    }
    
    private func loadImage() {
        let usingPatches: Bool = Defaults.usingPatches()
        let sitesWithImages = usingPatches ? PDStrings.SiteNames.patchSiteNames : PDStrings.SiteNames.injectionSiteNames
        if let name = nameText.text {
            var image: UIImage
            // New image
            if name == PDStrings.PlaceholderStrings.new_site {
                image = (usingPatches) ? PDImages.addPatch : PDImages.addInjection
            } else if let site = SiteScheduleRef.getSite(at: siteScheduleIndex),
                let imgId = site.getImageIdentifer(),
                let i = sitesWithImages.index(of: imgId) {
                // Set as default image
                image = (usingPatches) ?
                    PDImages.siteNameToPatchImage(sitesWithImages[i]) :
                    PDImages.siteNameToInjectionImage(sitesWithImages[i])
            } else {
                // Set as custom patch image
                image = (usingPatches) ?
                    PDImages.custom_p :
                    PDImages.custom_i
            }
            UIView.transition(with: siteImage, duration:0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.siteImage.image = image },
                              completion: nil)
        }
    }
    
    private func enableSave() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func disableSave() {
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}
