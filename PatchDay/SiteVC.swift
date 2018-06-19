//
//  SiteVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit

class SiteVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    private var siteScheduleIndex: Int = -1
    private var hasChanged: Bool = false
    private var pickerSet = ScheduleController.siteSchedule().siteSetUnionGeneralSites()
    
    @IBOutlet weak var siteStack: UIStackView!
    @IBOutlet weak var gapAboveImage: UIView!
    @IBOutlet weak var siteImage: UIImageView!
    @IBOutlet weak var typeNameButton: UIButton!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var sitePicker: UIPickerView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameText.autocapitalizationType = .words
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: PDStrings.actionStrings.save, style: .plain, target: self, action: #selector(saveButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.nameText.borderStyle = .none
        self.nameText.delegate = self
        self.sitePicker.delegate = self
        self.sitePicker.isHidden = true
        self.typeNameButton.setTitleColor(UIColor.lightGray, for: .disabled)
        self.loadNameLabel()
        self.loadImage()
    }
    
    public func setSiteScheduleIndex(to: Int) {
        self.siteScheduleIndex = to
    }
    
    // MARK: - IBACTION
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        self.openPicker()
    }
    
    @IBAction func typeTapped(_ sender: Any) {
        self.nameText.restorationIdentifier = "type"
        self.nameText.becomeFirstResponder()
    }
    
    @objc func saveButtonTapped(_ sender: Any) {
        let sites = ScheduleController.siteSchedule().siteArray
        if let name = self.nameText.text {
            
            // Updating existing MOSite
            if self.siteScheduleIndex >= 0 && self.siteScheduleIndex < sites.count {
                ScheduleController.coreDataController.setSiteName(index: self.siteScheduleIndex, to: name)
            }
                
            // Adding a new MOSite
            else if self.siteScheduleIndex == sites.count {
                CoreDataController.appendSite(name: name, order: self.siteScheduleIndex, sites: &ScheduleController.coreDataController.loc_array)
            }
        }
        segueToSitesVC()
    }
    
    // MARK: - Text field
    
    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.restorationIdentifier == "type" {
            self.nameText.text = ""
            self.nameText.isEnabled = true
            self.typeNameButton.isEnabled = false
            textField.restorationIdentifier = "select"
        }
        else {
            view.endEditing(true)
            self.nameText.isEnabled = false
            self.openPicker()
        }
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if self.nameText.text == "" {
            self.nameText.text = PDStrings.placeholderStrings.new_site
        }
        self.typeNameButton.isEnabled = true
        if let name = self.nameText.text {
            ScheduleController.coreDataController.setSiteName(index: self.siteScheduleIndex, to: name)
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.loadImage()
        return true
    }
    
    // MARK: - Picker functions
    
    private func openPicker() {
        UIView.transition(with: self.sitePicker as UIView, duration: 0.4, options: .transitionFlipFromTop, animations: { self.bottomLine.isHidden = true; self.sitePicker.isHidden = false; self.siteImage.isHidden = true
        }) {
            (void) in
            self.typeNameButton.isEnabled = false
        }
        if let n = self.nameText.text, let i = self.pickerSet.index(of: n) {
            self.sitePicker.selectRow(i, inComponent: 0, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerSet.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerSet[row]
    }
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let name = pickerSet[row]
        ScheduleController.coreDataController.setSiteName(index: self.siteScheduleIndex, to: name)
        UIView.transition(with: self.sitePicker as UIView, duration: 0.4, options: .transitionCrossDissolve, animations: { self.sitePicker.isHidden = true; self.bottomLine.isHidden = false; self.siteImage.isHidden = false
        }) {
            (void) in
            self.nameText.text = name
            self.typeNameButton.isEnabled = true
            self.nameText.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.loadImage()
        }
    }
    
    // MARK: - Private
    
    private func segueToSitesVC() {
        if let sb = storyboard, let navCon = self.navigationController, let sitesVC = sb.instantiateViewController(withIdentifier: "SitesVC_id") as? SitesVC {
            sitesVC.siteNames = ScheduleController.siteSchedule().siteNamesArray
            navCon.popViewController(animated: true)
        }
    }
    
    private func loadNameLabel() {
        let locs = ScheduleController.coreDataController.loc_array
        if self.siteScheduleIndex >= 0 && self.siteScheduleIndex < locs.count {
            let site = locs[self.siteScheduleIndex]
            self.title = PDStrings.titleStrings.site + " " + String(self.siteScheduleIndex+1)
            self.nameText.text = site.getName()
        }
        else {
            self.title = PDStrings.titleStrings.site + " " + String(locs.count+1)
        }
        if let title = self.typeNameButton.titleLabel, let text = title.text, text.count > 4 {
            self.typeNameButton.setTitle("⌨️", for: .normal)
        }
    }
    
    private func loadImage() {
        let usingPatches: Bool = UserDefaultsController.usingPatches()
        let sitesWithImages = UserDefaultsController.usingPatches() ? PDStrings.siteNames.patchSiteNames : PDStrings.siteNames.injectionSiteNames
        if let name = self.nameText.text {
            var image: UIImage
            self.siteImage.contentMode = (usingPatches) ? .top : .scaleAspectFit
            if name == "New Site" {
                image = (usingPatches) ? PDImages.addPatch : PDImages.addInjection
            }
            else if sitesWithImages.contains(name) {
                image = (usingPatches) ? PDImages.stringToPatchImage(imageString: name) : PDImages.stringToInjectionImage(imageString: name)
            }
            else {
                image = (usingPatches) ? PDImages.custom_p : PDImages.custom_i
            }
            UIView.transition(with: self.siteImage, duration:0.5, options: .transitionCrossDissolve, animations: { self.siteImage.image = image }, completion: nil)
        }
    }

}
