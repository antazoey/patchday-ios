//
//  SiteVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SiteVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    private var siteScheduleIndex: Int = -1
    private var hasChanged: Bool = false
    private var pickerSet = Array(PDSiteHelper.siteNameSetUnionDefaultSites(ScheduleController.siteController.siteArray, usingPatches: UserDefaultsController.usingPatches()))
    
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
        nameText.autocapitalizationType = .words
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: PDStrings.ActionStrings.save, style: .plain, target: self, action: #selector(saveButtonTapped(_:)))
        navigationItem.rightBarButtonItem?.isEnabled = false
        nameText.borderStyle = .none
        nameText.delegate = self
        sitePicker.delegate = self
        sitePicker.isHidden = true
        typeNameButton.setTitleColor(UIColor.lightGray, for: .disabled)
        loadTitle()
        loadImage()
    }
    
    public func setSiteScheduleIndex(to: Int) {
        siteScheduleIndex = to
    }
    
    // MARK: - IBACTION
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        openPicker()
    }
    
    @IBAction func typeTapped(_ sender: Any) {
        nameText.restorationIdentifier = "type"
        nameText.becomeFirstResponder()
    }
    
    @objc func saveButtonTapped(_ sender: Any) {
        let sites = ScheduleController.siteController.siteArray
        if let name = nameText.text {
            
            // Updating existing MOSite
            if siteScheduleIndex >= 0 && siteScheduleIndex < sites.count {
                ScheduleController.siteController.setSiteName(index: siteScheduleIndex, to: name)
            }
                
            // Adding a new MOSite
            else if siteScheduleIndex == sites.count {
                let _ = SiteDataController.appendSite(name: name, order: siteScheduleIndex, sites: &ScheduleController.siteController.siteArray, into: ScheduleController.persistentContainer.viewContext)
            }
        }
        segueToSitesVC()
    }
    
    // MARK: - Text field
    
    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.restorationIdentifier == "type" {
            nameText.text = ""
            nameText.isEnabled = true
            typeNameButton.isEnabled = false
            textField.restorationIdentifier = "select"
        }
            
        // Select site from picker rather than type
        else {
            view.endEditing(true)
            nameText.isEnabled = false
            openPicker()
        }
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if nameText.text == "" {
            nameText.text = PDStrings.PlaceholderStrings.new_site
        }
        typeNameButton.isEnabled = true
        if let name = nameText.text {
            ScheduleController.siteController.setSiteName(index: siteScheduleIndex, to: name)
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
        loadImage()
        return true
    }
    
    // MARK: - Picker functions
    
    private func openPicker() {
        UIView.transition(with: sitePicker as UIView, duration: 0.4, options: .transitionFlipFromTop, animations: { self.bottomLine.isHidden = true; self.sitePicker.isHidden = false; self.siteImage.isHidden = true
        }) {
            (void) in
            self.typeNameButton.isEnabled = false
        }
        if let n = nameText.text, let i = pickerSet.index(of: n) {
            sitePicker.selectRow(i, inComponent: 0, animated: true)
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
        ScheduleController.siteController.setSiteName(index: siteScheduleIndex, to: name)
        UIView.transition(with: sitePicker as UIView, duration: 0.4, options: .transitionCrossDissolve, animations: { self.sitePicker.isHidden = true; self.bottomLine.isHidden = false; self.siteImage.isHidden = false
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
        if let sb = storyboard, let navCon = navigationController, let sitesVC = sb.instantiateViewController(withIdentifier: "SitesVC_id") as? SitesVC {
            sitesVC.siteNames = PDSiteHelper.getSiteNames(ScheduleController.siteController.siteArray)
            navCon.popViewController(animated: true)
        }
    }
    
    private func loadTitle() {
        let locs = ScheduleController.siteController.siteArray
        if siteScheduleIndex >= 0 && siteScheduleIndex < locs.count {
            let site = locs[siteScheduleIndex]
            title = PDStrings.TitleStrings.site + " " + String(siteScheduleIndex+1)
            nameText.text = site.getName()
        }
        else {
            title = PDStrings.TitleStrings.site + " " + String(locs.count+1)
        }
        if let title = typeNameButton.titleLabel, let text = title.text, text.count > 4 {
            typeNameButton.setTitle("⌨️", for: .normal)
        }
    }
    
    private func loadImage() {
        let usingPatches: Bool = UserDefaultsController.usingPatches()
        let sitesWithImages = UserDefaultsController.usingPatches() ? PDStrings.SiteNames.patchSiteNames : PDStrings.SiteNames.injectionSiteNames
        if let name = nameText.text {
            var image: UIImage
            siteImage.contentMode = (usingPatches) ? .top : .scaleAspectFit
            if name == "New Site" {
                image = (usingPatches) ? PDImages.addPatch : PDImages.addInjection
            }
            else if sitesWithImages.contains(name) {
                image = (usingPatches) ? PDImages.stringToPatchImage(imageString: name) : PDImages.stringToInjectionImage(imageString: name)
            }
            else {
                image = (usingPatches) ? PDImages.custom_p : PDImages.custom_i
            }
            UIView.transition(with: siteImage, duration:0.5, options: .transitionCrossDissolve, animations: { self.siteImage.image = image }, completion: nil)
        }
    }

}
