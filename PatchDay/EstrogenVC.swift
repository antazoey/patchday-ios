//
//  EstrogenVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class EstrogenVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //MARK: - Main
    
    // Interface
    private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var dateAndTimePlaced: UILabel!
    @IBOutlet private weak var chooseSiteButton: UITextField!
    @IBOutlet private weak var chooseDateButton: UIButton!
    @IBOutlet private weak var datePickerInputView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet private weak var lineUnderScheduleDate: UIView!
    @IBOutlet private weak var lineUnderDate: UIView!
    @IBOutlet private weak var lineUnderDateAndTimePlaced: UIView!
    @IBOutlet private weak var bigGap: UIView!
    @IBOutlet private weak var expiresOrExpiredLabel: UILabel!
    @IBOutlet private weak var expirationDateLabel: UILabel!
    @IBOutlet private weak var lineUnderExpires: UIView!
    @IBOutlet private weak var bigGap2: UIView!
    @IBOutlet private weak var horizontalLineAboveSite: UIView!
    @IBOutlet private weak var siteStackView: UIStackView!
    @IBOutlet private weak var siteLabel: UILabel!
    @IBOutlet private weak var verticalLineInSiteStack: UIView!
    @IBOutlet private var typeSiteButton: UIButton!
    @IBOutlet private weak var sitePicker: UIPickerView!
    @IBOutlet private var horizontalLineBelowSite: UIView!
    @IBOutlet private weak var autofillButton: UIButton!
    
    // Non-interface
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let estrogenController = ScheduleController.estrogenController
    internal var estrogenScheduleIndex = -1
    internal var estrogen: MOEstrogen?
    internal var sites = ScheduleController.siteController.getSiteNames()
    internal var site: String = ""
    internal var datePlaced: Date = Date()
    internal var dateSelected: Date?
    private var siteTextHasChanged = false
    private var dateTextHasChanged = false
    private var shouldSaveSelectedSiteIndex = false
    private var shouldSaveIncrementedSiteIndex = false
    private var siteIndexSelected = -1
    
    override func viewDidAppear(_ animated: Bool) {
        sites = ScheduleController.siteController.getSiteNames()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        estrogen = estrogenController.getEstrogenMO(at: estrogenScheduleIndex)
        loadTitle()
        chooseSiteButton.autocapitalizationType = .words
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: PDStrings.ActionStrings.save, style: .plain, target: self, action: #selector(saveButtonTapped(_:)))
        saveButton = navigationItem.rightBarButtonItem
        saveButton.isEnabled = false
        reflectEstrogenExpirationDateInUI()
        autofillButton.setTitleColor(UIColor.darkGray, for: UIControlState.disabled)
        
        // Load data
        displayAttributeTexts()
        
        // Delegation
        chooseSiteButton.delegate = self
        sitePicker.delegate = self
        sitePicker.dataSource = self
        
        // Site Type setup
        verticalLineInSiteStack.backgroundColor = lineUnderDate.backgroundColor
        typeSiteButton.setTitle(PDStrings.ActionStrings.type, for: .normal)
        if let lab = typeSiteButton.titleLabel, let t = lab.text, t.count > 4 {
            typeSiteButton.setTitle("⌨️", for: .normal)
        }
    }
    
    // Save Button
    // 1.) Side effects related to schedule animation
    // 2.) Save data
    // 3.) Notification badge number config
    // 4.) Segue back to the EstrogensVC
    // 5.) Set site index
    @objc private func saveButtonTapped(_ sender: Any) {
        
        // Save + badge icon
        let intervalStr = UserDefaultsController.getTimeIntervalString()
        if let estro = estrogen {
            let wasExpiredBeforeSave: Bool = estro.isExpired(intervalStr)
            saveAttributes()
            let isExpiredAfterSave = estro.isExpired(intervalStr)
            configureBadgeIcon(wasExpiredBeforeSave, isExpiredAfterSave)
        }
        
        let estroCount = ScheduleController.estrogenController.estrogenArray.count
        
        // Schedule animation side-effects
        ScheduleController.indexOfChangedDelivery = (estroCount != UserDefaultsController.getQuantityInt() && dateTextHasChanged) ? estroCount : (estrogenScheduleIndex)
        ScheduleController.animateScheduleFromChangeDelivery = true

        // Only increments if the site changed
        if shouldSaveIncrementedSiteIndex {
            UserDefaultsController.incrementSiteIndex()
        }
        else if shouldSaveSelectedSiteIndex {
            UserDefaultsController.setSiteIndex(to: siteIndexSelected)
        }
        
        let estrosDue = ScheduleController.totalEstrogenDue()
        self.navigationController?.tabBarItem.badgeValue = (estrosDue <= 0) ? nil : String(estrosDue)
        
        // Transition
        if let navCon = navigationController {
            navCon.popViewController(animated: true)
        }
    }
    
    @IBAction private func autofillTapped(_ sender: Any) {
        autoPickSite()
        autoPickDate()
        // Date is now.
        // ** Bools for saving **
        dateTextHasChanged = true
        siteTextHasChanged = true
        saveButton.isEnabled = true
    }
    
    // MARK: - Text Edit Functions
    
    @IBAction private func keyboardTapped(_ sender: Any) {
        chooseSiteButton.restorationIdentifier = "type"
        chooseSiteButton.becomeFirstResponder()
    }
    
    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        chooseSiteButton.isUserInteractionEnabled = true
        
        // Use site picker
        if textField.restorationIdentifier == "pick" {
            openSitePicker(textField)
        }
        
        // Use keyboard
        else if textField.restorationIdentifier == "type" {
            chooseSiteButton.text = ""
        }
        chooseDateButton.isEnabled = false
        typeSiteButton.isEnabled = false
        autofillButton.isHidden = true
        textField.restorationIdentifier = "pick"
 
    }
 
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chooseSiteButton.endEditing(true)
        chooseSiteButton.isEnabled = true
        chooseDateButton.isEnabled = true
        autofillButton.isHidden = false
        siteTextHasChanged = true
        chooseSiteButton.isHidden = false
        typeSiteButton.isEnabled = true
        if let newSiteName = chooseSiteButton.text {
              PDAlertController.alertForAddingNewSite(newSiteName: newSiteName)
        }
        saveButton.isEnabled = true
        return true
        
    }
    
    // MARK: - Picker Functions
    
    @IBAction internal func openSitePicker(_ sender: Any) {
        UIView.transition(with: sitePicker as UIView, duration: 0.4, options: .transitionCrossDissolve, animations: { self.sitePicker.isHidden = false
        }, completion: nil)
        sitePicker.selectRow(findSiteStartRow(site), inComponent: 0, animated: false)
        // other View changes
        autofillButton.isHidden = true
        autofillButton.isEnabled = false
        typeSiteButton.isEnabled = false
        chooseSiteButton.isEnabled = false
        chooseDateButton.isEnabled = false

    }

    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sites.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sites[row]
    }
    
    // Done
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let newLoc = sites[row]
        chooseSiteButton.text = newLoc
        site = newLoc
        // other view changes
        sitePicker.isHidden = true
        autofillButton.isEnabled = true
        chooseDateButton.isEnabled = true
        typeSiteButton.isEnabled = true
        chooseSiteButton.isEnabled = true
        chooseSiteButton.isHidden = false
        autofillButton.isHidden = false
        siteTextHasChanged = true
        saveButton.isEnabled = true
        shouldSaveSelectedSiteIndex = true
        shouldSaveIncrementedSiteIndex = false
        siteIndexSelected = row
    }

    // MARK: - Date Picker funcs
    
    @IBAction internal func chooseDateTextTapped(_ sender: Any) {
        
        UIView.transition(with: datePickerInputView as UIView, duration: 0.4, options: .transitionCrossDissolve, animations: { self.datePickerInputView.isHidden = false
        }, completion: nil)
        createDatePickerSubview()
        // disable \ hide stuff
        autofillButton.isHidden = true
        chooseDateButton.isEnabled = false
        typeSiteButton.isEnabled = false
        chooseSiteButton.isEnabled = false
        
    }
    
    @objc internal func datePickerDone(sender: UIButton) {
        datePickerInputView.isHidden = true
        dateSelected = datePicker.date
        let intervalStr = UserDefaultsController.getTimeIntervalString()
        let dateStr = PDDateHelper.format(date: datePicker.date, useWords: true)
        chooseDateButton.setTitle(dateStr, for: UIControlState.normal)
        if let expDate = PDDateHelper.expirationDate(from: datePicker.date, intervalStr) {            // disp exp date
            expirationDateLabel.text = PDDateHelper.format(date: expDate, useWords: true)
        }
        // outer view changes
        saveButton.isEnabled = true
        chooseDateButton.isEnabled = true
        typeSiteButton.isEnabled = true
        autofillButton.isHidden = false
        siteStackView.isHidden = false
        siteLabel.isHidden = false
        dateTextHasChanged = true
        chooseSiteButton.isEnabled = true

    }
    
    // MARK: - private funcs
    
    private func displayAttributeTexts() {
        if let estro = estrogenController.getEstrogenMO(at: estrogenScheduleIndex) {
            if let site = estro.getSite(), let siteName = site.getName() {
                chooseSiteButton.text = siteName
            }
            else {
                chooseSiteButton.text = PDStrings.ActionStrings.select
            }
            if let date = estro.getDate() {
                datePlaced = date as Date
                chooseDateButton.setTitle(PDDateHelper.format(date: date as Date, useWords: true) , for: .normal)
                expirationDateLabel.text = estro.expirationDateAsString(UserDefaultsController.getTimeIntervalString(), useWords: true)
            }
            else {
                chooseDateButton.setTitle(PDStrings.ActionStrings.select, for: .normal)
            }
        }
        // nil patch
        else {
            chooseSiteButton.text = PDStrings.ActionStrings.select
            chooseDateButton.setTitle(PDStrings.ActionStrings.select, for: .normal)
        }
    }
    
    internal func setEstrogenScheduleIndex(to: Int) {
        estrogenScheduleIndex = to
    }
    
    // Saves any changed attributes.
    private func saveAttributes() {

        // Save site
        if siteTextHasChanged, let newSiteName = chooseSiteButton.text, newSiteName != "", let newSite = ScheduleController.siteController.getSite(for: newSiteName) {
            
            
                estrogenController.setEstrogenSite(of: estrogenScheduleIndex, with: newSite)
        }
        
        // Save date
        if dateTextHasChanged {
            estrogenController.setEstrogenDate(of: estrogenScheduleIndex, with: datePicker.date)
        }
        
        // For EstrogensVC animation.
        if !dateTextHasChanged {
            ScheduleController.onlySiteChanged = true
        }
    }
    
    private func autoPickSite() {
        if let currentSiteName = chooseSiteButton.text {
            let scheduleSites: [String] = ScheduleController.siteController.getSiteNames()
            let currentSites: [String] = ScheduleController.getCurrentSiteNamesInEstrogenSchedule()
            let estrogenCount: Int = UserDefaultsController.getQuantityInt()
            if let suggestedSiteIndex = SiteSuggester.suggest(currentEstrogenSiteSuggestingFrom: currentSiteName, currentSites: currentSites, estrogenQuantity: estrogenCount, scheduleSites: scheduleSites), suggestedSiteIndex >= 0 && suggestedSiteIndex < scheduleSites.count {
                shouldSaveIncrementedSiteIndex = true
                shouldSaveSelectedSiteIndex = false
                chooseSiteButton.text = scheduleSites[suggestedSiteIndex]
            }
        }
    }
    
    private func autoPickDate() {
        let now = Date()
        let intervalStr = UserDefaultsController.getTimeIntervalString()
        chooseDateButton.setTitle(PDDateHelper.format(date: now, useWords: true), for: .normal)
        if let expDate = PDDateHelper.expirationDate(from: now, intervalStr) {
            expirationDateLabel.text = PDDateHelper.format(date: expDate, useWords: true)
        }
    }
    
    private func requestNotification() {
        if let estro = estrogen {
            appDelegate.notificationsController.requestEstrogenExpiredNotification(for: estro)
        }
    }
    
    private func cancelNotification() {
        appDelegate.notificationsController.cancelEstrogenNotification(at: estrogenScheduleIndex)
    }
    
    // MARK: - Private view creators / MOEstrogendifiers
    
    private func findSiteStartRow(_ site: String) -> Int {
        if let i = sites.index(of: site) {
            return i
        }
        return 0
    }
    
    // Sets titles related to the estrogen's expiration date.
    private func reflectEstrogenExpirationDateInUI() {
        let intervalStr = UserDefaultsController.getTimeIntervalString()
        var exp = ""
        if let estro = estrogenController.getEstrogenMO(at: estrogenScheduleIndex) {
            if estro.getDate() != nil {
                expiresOrExpiredLabel.text = (estro.isExpired(intervalStr)) ? PDStrings.ColonedStrings.expired : PDStrings.ColonedStrings.expires
                exp = estro.expirationDateAsString(intervalStr, useWords: true)
            }
            else {
                exp = PDStrings.PlaceholderStrings.dotdotdot
            }
            expirationDateLabel.text = exp
        }
        else {
            exp = PDStrings.PlaceholderStrings.dotdotdot
        }
    }
    
    // Returns UIDatePicker start-x value based on on whether iphone or ipad.
    private func configureDatePickerStartX() -> CGFloat {
        let dim = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ? 0 : view.frame.width/2.8
        return dim
    }
    
    // Makes done button for editing state.
    private func makeDoneButton() -> UIButton {
        let donePoint = CGPoint(x: configureDoneButtonStartX(), y: 0)
        let doneSize = CGSize(width: 100, height: 50)
        let doneRect = CGRect(origin: donePoint, size: doneSize)
        let doneButton = UIButton(frame: doneRect)
        doneButton.setTitle(PDStrings.ActionStrings.done, for: UIControlState.normal)
        doneButton.setTitle(PDStrings.ActionStrings.done, for: UIControlState.highlighted)
        doneButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
        return doneButton
        
    }
    
    // Configured title of view controller
    private func loadTitle() {
        if PDStrings.PickerData.deliveryMethods.count >= 2 {
            let patch = PDStrings.DeliveryMethods.patch
            let injection = PDStrings.DeliveryMethods.injection
            title = (UserDefaultsController.usingPatches()) ? patch : injection
        }
    }
    
    // Gives start x for date picker Done button depending on iPad vs iPhone.
    private func configureDoneButtonStartX() -> CGFloat {
        let x = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ? (view.frame.size.width/2) - 50 : 0
        return x
    }
    
    private func configureBadgeIcon(_ wasExpiredBeforeSave: Bool,_ isExpiredAfterSave: Bool) {
            
        // New estro is fresh
        if !isExpiredAfterSave && UIApplication.shared.applicationIconBadgeNumber > 0 {
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
            
        // New estro is not fresh
        else if !wasExpiredBeforeSave && isExpiredAfterSave {
            UIApplication.shared.applicationIconBadgeNumber += 1
        }
        
        if !wasExpiredBeforeSave {
            cancelNotification()
        }
        requestNotification()
    }
    
    private func createDatePickerSubview() {
        let doneButton = makeDoneButton()
        datePickerInputView.addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(datePickerDone), for: .touchUpInside)
        
    }

    private func hideLines() {
        lineUnderScheduleDate.isHidden = true
        lineUnderDateAndTimePlaced.isHidden = true
        lineUnderExpires.isHidden = true
        horizontalLineAboveSite.isHidden = true
        horizontalLineBelowSite.isHidden = true
        lineUnderDate.isHidden = true
        verticalLineInSiteStack.isHidden = true
    }
    
    private func unhideLines() {
        lineUnderScheduleDate.isHidden = false
        lineUnderDateAndTimePlaced.isHidden = false
        lineUnderExpires.isHidden = false
        horizontalLineAboveSite.isHidden = false
        horizontalLineBelowSite.isHidden = false
        lineUnderDate.isHidden = false
        verticalLineInSiteStack.isHidden = false
    }

}
