//
//  SiteDetailVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SiteDetailVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    private let sdk: PatchDataDelegate? = app?.sdk
    
    private var siteScheduleIndex: Int = -1
    private var hasChanged: Bool = false
    
    @IBOutlet weak var siteStack: UIStackView!
    @IBOutlet weak var nameStackVertical: UIStackView!

    @IBOutlet weak var nameStackHorizontal: UIStackView!
    @IBOutlet weak var verticalLineByNameTextField: UIView!
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
        if AppDelegate.isPad {
            topConstraint.constant = 100
        }
        nameText.autocapitalizationType = .words
        loadSave()
        disableSave()
        nameText.borderStyle = .none
        nameText.delegate = self
        namePicker.delegate = self
        namePicker.isHidden = true
        loadImagePickeR()
        typeNameButton.setTitleColor(UIColor.lightGray, for: .disabled)
        loadTitle()
        loadImage()
        typeNameButton.setTitle(ActionStrings.type, for: .normal)
        verticalLineByNameTextField.backgroundColor = bottomLine.backgroundColor
        nameText.restorationIdentifier = "select"
        applyTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        applyTheme()
    }
    
    public func setSiteScheduleIndex(to index: Int) {
        siteScheduleIndex = index
    }
    
    // MARK: - Actions
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if let sdk = sdk {
            let t = sdk.defaults.theme.value
            let method = sdk.defaults.deliveryMethod.value
            let images = PDImages.siteImages(theme: t, deliveryMethod: method)
            let imageStruct = setImage(images: images)
            imagePicker.isHidden = true
            siteImage.image = imageStruct.image
            siteImage.isHidden = false
            imageButton.isEnabled = true
            typeNameButton.isEnabled = true
            nameText.isEnabled = true
            imagePickerDoneButton.isEnabled = false
            imagePickerDoneButton.isHidden = true
            enableSave()
            sdk.sites.setImageId(at: siteScheduleIndex, to: imageStruct.imageKey, deliveryMethod: method)
        }
    }
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        siteImage.isHidden = true
        imageButton.isEnabled = false
        imagePickerDelegate?.openPicker() {
            self.typeNameButton.isEnabled = false
            self.imageButton.isEnabled = false
            self.nameText.isEnabled = false
            self.imagePickerDoneButton.isHidden = false
            self.imagePickerDoneButton.isEnabled = true
        }
    }
    
    @IBAction func typeTapped(_ sender: Any) {
        nameText.restorationIdentifier = "type"
        nameText.becomeFirstResponder()
    }
    
    @objc func saveButtonTapped(_ sender: Any) {
        if let name = nameText.text, let sdk = sdk {
            // Updating existing site
            let i = siteScheduleIndex
            let count = sdk.sites.count
            switch i {
            case 0..<count :
                sdk.sites.rename(at: i, to: name)
            case count :
                sdk.insertNewSite(name: name)
            default : break
            }
        }
        segueToSitesVC()
    }
    
    // MARK: - Text field
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        enableSave()
        typeNameButton.setTitle(ActionStrings.done)
        
        var newAction: Selector?
        switch textField.restorationIdentifier {
        case "type" :
            nameText.isEnabled = true
            textField.restorationIdentifier = "select"
            newAction = #selector(closeTextField)
        case "select" :
            view.endEditing(true)
            nameText.isEnabled = false
            openPicker(namePicker)
            newAction = #selector(closePicker)
        default : break
        }
        if let new = newAction {
            typeNameButton.replaceTarget(self, newAction: new)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeTextField()
        return true
    }
    
    @objc func closeTextField() {
        view.endEditing(true)
        nameText.restorationIdentifier = "select"
        switch nameText.text {
        case "" :
            nameText.text = SiteStrings.newSite
        case let name :
            if let n = name {
                sdk?.sites.rename(at: siteScheduleIndex, to: n)
            }
        }
        loadImage()
        typeNameButton.setTitle(ActionStrings.type, for: .normal)
        nameText.removeTarget(self, action: #selector(closeTextField), for: .touchUpInside)
        typeNameButton.addTarget(self, action: #selector(typeTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Picker functions
    
    @objc private func openPicker(_ picker: UIPickerView) {
        UIView.transition(
            with: picker as UIView,
            duration: 0.4,
            options: .transitionFlipFromTop, animations: {
                picker.isHidden = false;
                self.bottomLine.isHidden = true;
                self.siteImage.isHidden = true
            })
        if let n = nameText.text, let i = sdk?.sites.names.firstIndex(of: n) {
            namePicker.selectRow(i, inComponent: 0, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        return sdk?.sites.names.count ?? 0
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        attributedTitleForRow row: Int,
        forComponent component: Int
    ) -> NSAttributedString? {

        if let sdk = sdk,
            let name = sdk.sites.names.tryGet(at: row),
            let textColor = app?.styles.theme[.text] {
    
            let attrs = [NSAttributedString.Key.foregroundColor : textColor as Any]
            let attributedString = NSAttributedString(string: name, attributes: attrs)
            return attributedString
        }
        return nil
    }
 
    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        if let sdk = sdk, let name = sdk.sites.names.tryGet(at: row) {
            self.nameText.text = name
            closePicker()
        }
    }
    
    @objc func closePicker() {
        self.namePicker.isHidden = true;
        self.bottomLine.isHidden = false;
        self.siteImage.isHidden = false;
        nameText.restorationIdentifier = "select"
        typeNameButton.setTitle(ActionStrings.type, for: .normal)
        nameText.removeTarget(self, action: #selector(closePicker), for: .touchUpInside)
        self.typeNameButton.addTarget(self, action: #selector(self.typeTapped(_:)), for: .touchUpInside)
        self.nameText.isEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    // MARK: - Private
    
    private func setImage(images: [UIImage]) -> ImageStruct {
        let image = images[imagePicker.getSelectedRow()]
        let imageKey = PDImages.imageToSiteName(image)
        return ImageStruct(image: image, imageKey: imageKey)
    }
    
    private func segueToSitesVC() {
        navigationController?.popViewController(animated: true)
    }
    
    private func loadTitle() {
        if siteScheduleIndex >= 0, let site = sdk?.sites.at(siteScheduleIndex) {
            title = "\(VCTitleStrings.siteTitle) \(siteScheduleIndex + 1)"
            nameText.text = site.name
        } else {
            let indexSuffix = (sdk?.sites.count ?? 0) + 1
            title = "\(VCTitleStrings.siteTitle) \(indexSuffix)"
        }
    }
    
    private func loadImage() {
        if let name = nameText.text, let sdk = sdk {
            var image: UIImage
            let method = sdk.defaults.deliveryMethod.value
            let theme = sdk.defaults.theme.value
            let sitesWithImages = SiteStrings.getSiteNames(for: method)
            if name == SiteStrings.newSite {
                image = PDImages.getCerebralHormoneImage(theme: theme, deliveryMethod: method)
            } else if let site = sdk.sites.at(siteScheduleIndex),
                let i = sitesWithImages.firstIndex(of: site.imageId) {

                image = PDImages.siteNameToImage(
                    sitesWithImages[i],
                    theme: theme,
                    deliveryMethod: method
                )
            } else {
                image = PDImages.getCustomHormoneImage(theme: theme, deliveryMethod: method)
            }
            UIView.transition(
                with: siteImage,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: { self.siteImage.image = image },
                completion: nil
            )
        }
    }
    
    private func loadImagePickeR() {
        if let sdk = sdk {
            let method = sdk.defaults.deliveryMethod.value
            if let site = sdk.sites.at(siteScheduleIndex),
                let saveButton = navigationItem.rightBarButtonItem {
        
                imagePickerDelegate = SiteImagePickerDelegate(
                    with: imagePicker,
                    and: siteImage,
                    saveButton: saveButton,
                    selectedSite: site,
                    deliveryMethod: method)
            }
            imagePicker.delegate = imagePickerDelegate
            imagePicker.dataSource = imagePickerDelegate
        }
    }
    
    private func loadSave() {
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                title: ActionStrings.save,
                style: .plain,
                target: self,
                action: #selector(saveButtonTapped(_:))
            )
    }
    
    private func enableSave() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func disableSave() {
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func applyTheme() {
        if let theme = app?.styles.theme {
            view.backgroundColor = theme[.bg]
            nameStackVertical.backgroundColor = theme[.bg]
            nameStackHorizontal.backgroundColor = theme[.bg]
            typeNameButton.setTitleColor(theme[.text], for: .normal)
            nameText.textColor = theme[.text]
            nameText.backgroundColor = theme[.bg]
            siteImage.backgroundColor = theme[.bg]
            gapAboveImage.backgroundColor = theme[.bg]
        }
    }
}
