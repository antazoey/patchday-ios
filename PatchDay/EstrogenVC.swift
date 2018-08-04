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
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    
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
    @IBOutlet private weak var expLabel: UILabel!
    @IBOutlet private weak var expirationDateLabel: UILabel!
    @IBOutlet private weak var lineUnderExpires: UIView!
    @IBOutlet private weak var bigGap2: UIView!
    @IBOutlet private weak var horizontalLineAboveSite: UIView!
    @IBOutlet private weak var siteStackView: UIStackView!
    @IBOutlet private weak var siteLabel: UILabel!
    @IBOutlet private weak var verticalLineInSiteStack: UIView!
    @IBOutlet private var typeSiteButton: UIButton!
    @IBOutlet public weak var sitePicker: UIPickerView!
    @IBOutlet private var horizontalLineBelowSite: UIView!
    @IBOutlet private weak var autofillButton: UIButton!
    
    // Non-interface
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    internal var estrogenScheduleIndex = -1
    internal var estrogen: MOEstrogen!
    internal var site: String = ""
    internal var datePlaced: Date = Date()
    internal var dateSelected: Date?
    private var siteTextHasChanged = false
    private var dateTextHasChanged = false
    private var shouldSaveSelectedSiteIndex = false
    private var shouldSaveIncrementedSiteIndex = false
    private var siteIndexSelected = -1
    
    @objc func test() {
        print("Test")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        estrogen = ScheduleController.estrogenController.getEstrogen(at: estrogenScheduleIndex)
        loadTitle()
        chooseSiteButton.autocapitalizationType = .words
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: PDStrings.ActionStrings.save, style: .plain, target: self, action: #selector(saveButtonTapped(_:)))
        saveButton = navigationItem.rightBarButtonItem
        saveButton.isEnabled = false
        autofillButton.setTitleColor(UIColor.darkGray, for: UIControlState.disabled)
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.phone) {
            topConstraint.constant = 100
            autofillButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        }
        
        // Load data
        setUpLabelsInUI()
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
    
    /** Save Button
       1.) Side effects related to schedule animation
       2.) Save data
       3.) Notification badge number config
       4.) Segue back to the EstrogensVC
       5.) Set site index */
    @objc private func saveButtonTapped(_ sender: Any) {
    
        let intervalStr = UserDefaultsController.getTimeIntervalString()
        if let estro = estrogen {
            let wasExpiredBeforeSave: Bool = estro.isExpired(intervalStr)
            saveAttributes()    // Save
            let isExpiredAfterSave = estro.isExpired(intervalStr)
            configureBadgeIcon(wasExpiredBeforeSave, isExpiredAfterSave)
            requestNotification()
        }
        
        // Schedule animation side-effects
        ScheduleController.animateScheduleFromChangeDelivery = true
        if let indexUndated = PDEstrogenHelper.getLowestUndatedIndex(in: ScheduleController.estrogenController.estrogenArray, estrogenCount: UserDefaultsController.getQuantityInt()),
            indexUndated <  estrogenScheduleIndex {
            ScheduleController.indexOfChangedDelivery = indexUndated
        }
        else {
            ScheduleController.indexOfChangedDelivery = estrogenScheduleIndex
        }
        
        let estrosDue = ScheduleController.totalEstrogenDue(intervalStr: intervalStr)
        self.navigationController?.tabBarItem.badgeValue = (estrosDue <= 0) ? nil : String(estrosDue)
        
        // Transition
        if let navCon = navigationController {
            navCon.popViewController(animated: true)
        }
    }
    
    @IBAction private func autofillTapped(_ sender: Any) {
        autoPickSite()
        autoPickDate()
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
        saveButton.isEnabled = true
        siteIndexSelected = ScheduleController.siteCount()
        if let n = textField.text {
            PDAlertController.alertForAddSite(with: n, at: siteIndexSelected, estroVC: self)
        }
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
        return ScheduleController.siteCount()
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PDSiteHelper.getSiteNames(ScheduleController.siteController.siteArray)[row]
    }
    
    // Done
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let newSiteName = ScheduleController.siteController.getSiteNames()[row]
        chooseSiteButton.text = newSiteName
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
        
        // Unhide date picker
        UIView.transition(with: datePickerInputView as UIView, duration: 0.4, options: .transitionCrossDissolve, animations: { self.datePickerInputView.isHidden = false
        }, completion: nil)
        if let date = dateSelected {
            datePicker.date = date
        }
        else if let date = estrogen?.getDate() {
            datePicker.date = date as Date
        }
        let doneButton = makeDoneButton()
        datePickerInputView.addSubview(doneButton)
        autofillButton.isHidden = true
        chooseDateButton.isEnabled = false
        typeSiteButton.isEnabled = false
        chooseSiteButton.isEnabled = false
        
    }
    
    @objc internal func datePickerDone(_ sender: Any) {
        let doneButton = sender as! UIButton
        doneButton.removeFromSuperview()
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
        if let site = estrogen.getSite(), let siteName = site.getName() {
            chooseSiteButton.text = siteName
        }
        else if let name = estrogen.getSiteNameBackUp() {
            chooseSiteButton.text = name
        }
        else {
            chooseSiteButton.text = PDStrings.ActionStrings.select
        }
        if let date = estrogen.getDate() {
            datePlaced = date as Date
            chooseDateButton.setTitle(PDDateHelper.format(date: date as Date, useWords: true) , for: .normal)
            expirationDateLabel.text = estrogen.expirationDateAsString(UserDefaultsController.getTimeIntervalString(), useWords: true)
        }
        else {
            chooseDateButton.setTitle(PDStrings.ActionStrings.select, for: .normal)
        }
    }
    
    internal func setEstrogenScheduleIndex(to: Int) {
        estrogenScheduleIndex = to
    }
    
    /// Returns if there have been changes.
    private func needsToSave() -> Bool {
        return siteTextHasChanged || dateTextHasChanged
    }
    
    /// Saves any changed attributes.
    private func saveAttributes() {
        // Save site
        if siteTextHasChanged {
            if let site = ScheduleController.siteController.getSite(at: siteIndexSelected) {
                ScheduleController.estrogenController.setEstrogenSite(of: estrogenScheduleIndex, with: site)
                ScheduleController.siteChanged = true
            }
            else if let name = chooseSiteButton.text {
                ScheduleController.estrogenController.setEstrogenBackUpSiteName(of: estrogenScheduleIndex, with: name)
            }
        }
        
        // Save date
        if dateTextHasChanged {
            ScheduleController.estrogenController.setEstrogenDate(of: estrogenScheduleIndex, with: datePicker.date)
        }
        
        // For EstrogensVC animation.
        if !dateTextHasChanged {
            ScheduleController.onlySiteChanged = true
        }
    }
    
    private func autoPickSite() {
        if let suggestedSite = ScheduleController.getSuggestedSite() {
            shouldSaveIncrementedSiteIndex = true
            shouldSaveSelectedSiteIndex = false
            if let suggestedSiteName = suggestedSite.getName() {
                chooseSiteButton.text = suggestedSiteName
                siteTextHasChanged = true
                siteIndexSelected = Int(suggestedSite.getOrder())
            }
        }
    }
    
    private func autoPickDate() {
        let now = Date()
        let intervalStr = UserDefaultsController.getTimeIntervalString()
        chooseDateButton.setTitle(PDDateHelper.format(date: now, useWords: true), for: .normal)
        if let expDate = PDDateHelper.expirationDate(from: now, intervalStr) {
            expirationDateLabel.text = PDDateHelper.format(date: expDate, useWords: true)
            dateTextHasChanged = true
            dateSelected = now
        }
    }
    
    private func requestNotification() {
        if let estro = estrogen {
            appDelegate.notificationsController.requestEstrogenExpiredNotification(for: estro)
            // Overnight
            if let expDate = estro.expirationDate(intervalStr: UserDefaultsController.getTimeIntervalString()), PDDateHelper.isOvernight(expDate) {
                appDelegate.notificationsController.requestOvernightNotification(estro, expDate: expDate)
            }
        }
    }
    
    private func cancelNotification() {
        appDelegate.notificationsController.cancelEstrogenNotification(at: estrogenScheduleIndex)
    }
    
    // MARK: - Private view creators / MOEstrogendifiers
    
    private func findSiteStartRow(_ site: String) -> Int {
        if siteIndexSelected != -1 {
            return siteIndexSelected
        }
        else if let site = estrogen.getSite() {
            let order = site.getOrder()
            if order >= 1 && order <= ScheduleController.siteCount() {
                let i = Int(order)
                siteIndexSelected = i
                return i
            }
        }
        return 0
    }
    
    /// Sets titles related to the estrogen's expiration date.
    private func setUpLabelsInUI() {
        let intervalStr = UserDefaultsController.getTimeIntervalString()
        var exp = ""
        let estro = ScheduleController.estrogenController.getEstrogen(at: estrogenScheduleIndex)
        if estro.getDate() != nil {
            if UserDefaultsController.usingPatches() {
                expLabel.text = (estro.isExpired(intervalStr)) ? PDStrings.ColonedStrings.expired : PDStrings.ColonedStrings.expires
                dateAndTimePlaced.text = PDStrings.ColonedStrings.date_and_time_applied
                siteLabel.text = PDStrings.ColonedStrings.site
            }
            else {
                expLabel.text = PDStrings.ColonedStrings.next_due
                dateAndTimePlaced.text = PDStrings.ColonedStrings.date_and_time_injected
                siteLabel.text = PDStrings.ColonedStrings.last_site_injected
            }
            exp = estro.expirationDateAsString(intervalStr, useWords: true)
        }
        else {
            exp = PDStrings.PlaceholderStrings.dotdotdot
        }
        expirationDateLabel.text = exp
    }
    
    /// Returns UIDatePicker start-x value based on on whether iphone or ipad.
    private func configureDatePickerStartX() -> CGFloat {
        let dim = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ? 0 : view.frame.width/2.8
        return dim
    }
    
    /// Makes done button for editing state.
    private func makeDoneButton() -> UIButton {
        let donePoint = CGPoint(x: configureDoneButtonStartX(), y: 0)
        let doneSize = CGSize(width: 100, height: 50)
        let doneRect = CGRect(origin: donePoint, size: doneSize)
        let doneButton = UIButton(frame: doneRect)
        doneButton.setTitle(PDStrings.ActionStrings.done, for: UIControlState.normal)
        doneButton.setTitle(PDStrings.ActionStrings.done, for: UIControlState.highlighted)
        doneButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
        doneButton.removeTarget(nil, action: nil, for: .allEvents)
        doneButton.addTarget(self, action: #selector(datePickerDone), for: .touchUpInside)
        return doneButton
    }
    
    /// Configured title of view controller
    private func loadTitle() {
        if PDStrings.PickerData.deliveryMethods.count >= 2 {
            let patch = PDStrings.DeliveryMethods.patch
            let injection = PDStrings.DeliveryMethods.injection
            title = (UserDefaultsController.usingPatches()) ? patch : injection
        }
    }
    
    /// Gives start x for date picker Done button depending on iPad vs iPhone.
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
