//
//  EstrogenVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class HormoneDetailVC: UIViewController,
                  UIPickerViewDelegate,
                  UIPickerViewDataSource,
                  UITextFieldDelegate {
    
    private var tabs: PDTabReflective = app.tabs!
    private var alerts: PDAlertDispatching = app.alerts
    private var selectedSite: Bodily?
    
    //MARK: - Main
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    // Interface
    private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var dateAndTimePlaced: UILabel!
    @IBOutlet private weak var selectSiteTextField: UITextField!
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
    
    // Dependencies
    private var sdk = app.sdk
    private var notifications = app.notifications
    
    // Non-interface
    var hormoneIndex = -1
    var hormone: Hormonal!
    var site: String = ""
    var datePlaced: Date = Date()
    var dateSelected: Date?
    private var siteTextHasChanged = false
    private var dateTextHasChanged = false
    private var shouldSaveSelectedSiteIndex = false
    private var shouldSaveIncrementedSiteIndex = false
    private var siteIndexSelected = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hormone = sdk.hormones.at(hormoneIndex)
        loadTitle()
        selectSiteTextField.autocapitalizationType = .words
        view.backgroundColor = UIColor.white
        let save = PDActionStrings.save
        let handleSave = #selector(saveButtonTapped(_:))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: save,
                                                            style: .plain,
                                                            target: self,
                                                            action: handleSave)
        saveButton = navigationItem.rightBarButtonItem
        saveButton.isEnabled = false
        autofillButton.setTitleColor(UIColor.darkGray, for: UIControl.State.disabled)
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.phone) {
            topConstraint.constant = 100
            autofillButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        }
        
        // Load data
        setUpLabelsInUI()
        displayAttributeTexts()
        
        // Delegation
        selectSiteTextField.delegate = self
        sitePicker.delegate = self
        sitePicker.dataSource = self
        
        // Site Type setup
        selectSiteTextField.restorationIdentifier = "pick"
        verticalLineInSiteStack.backgroundColor = lineUnderDate.backgroundColor
        typeSiteButton.setTitle(PDActionStrings.type, for: .normal)
    }

    @objc private func saveButtonTapped(_ sender: Any) {
        if let mone = hormone {
            let wasExpiredBeforeSave = mone.isExpired
            saveData()
            let isExpiredAfterSave = mone.isExpired
            configureBadgeIcon(wasExpiredBeforeSave, isExpiredAfterSave)
            requestNotifications()
            sdk.hormones.sort()
        }
        self.tabs.reflectHormone()
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
        selectSiteTextField.restorationIdentifier = "type"
        selectSiteTextField.becomeFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectSiteTextField.isUserInteractionEnabled = true
        chooseDateButton.isEnabled = false
        autofillButton.isHidden = true
        typeSiteButton.setTitle(PDActionStrings.done, for: .normal)
        typeSiteButton.removeTarget(self, action: #selector(keyboardTapped(_:)), for: .touchUpInside)
        switch (textField.restorationIdentifier) {
            case "type" :
                selectSiteTextField.isEnabled = true
                selectSiteTextField.text = ""
                textField.restorationIdentifier = "pick"
                typeSiteButton.addTarget(self, action: #selector(closeTextField), for: .touchUpInside)
            case "pick" :
                view.endEditing(true)
                selectSiteTextField.isEnabled = false
                typeSiteButton.addTarget(self, action: #selector(closeSitePicker), for: .touchUpInside)
                fallthrough
            default : openSitePicker(textField)
        }
    }
    
    @objc func closeTextField() {
        self.selectedSite = nil
        siteTextHasChanged = true
        if selectSiteTextField.text == "" {
            selectSiteTextField.text = PDStrings.PlaceholderStrings.newSite
        }
        typeSiteButton.setTitle(PDActionStrings.type, for: .normal)
        selectSiteTextField.endEditing(true)
        selectSiteTextField.isEnabled = true
        chooseDateButton.isEnabled = true
        autofillButton.isHidden = false
        selectSiteTextField.isHidden = false
        saveButton.isEnabled = true
        typeSiteButton.removeTarget(
            self,
            action: #selector(closeTextField),
            for: .touchUpInside
        )
        typeSiteButton.addTarget(self, action: #selector(keyboardTapped(_:)), for: .touchUpInside)
        siteIndexSelected = sdk.sites.count
        if let n = selectSiteTextField.text {
            alerts.presentNewSiteAlert(
                with: n,
                at: siteIndexSelected,
                moneVC: self
            )
        }
    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeTextField()
        return true
    }
    
    // MARK: - Picker Functions
    
    @IBAction func openSitePicker(_ sender: Any) {
        UIView.transition(with: sitePicker as UIView,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: { self.sitePicker.isHidden = false
        }, completion: nil)
        sitePicker.selectRow(findSiteStartRow(site), inComponent: 0, animated: false)
        autofillButton.isHidden = true
        autofillButton.isEnabled = false
        selectSiteTextField.isEnabled = false
        chooseDateButton.isEnabled = false
    }
    
    @objc func closeSitePicker() {
        sitePicker.isHidden = true
        autofillButton.isEnabled = true
        chooseDateButton.isEnabled = true
        selectSiteTextField.isEnabled = true
        selectSiteTextField.isHidden = false
        autofillButton.isHidden = false
        siteTextHasChanged = true
        saveButton.isEnabled = true
        shouldSaveSelectedSiteIndex = true
        shouldSaveIncrementedSiteIndex = false
        typeSiteButton.setTitle(PDActionStrings.type, for: .normal)
        typeSiteButton.removeTarget(self,
                                    action: #selector(closeSitePicker),
                                    for: .touchUpInside)
        typeSiteButton.addTarget(self,
                                 action: #selector(keyboardTapped(_:)),
                                 for: .touchUpInside)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return sdk.sites.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        let names = sdk.sites.names
        if row < names.count && row >= 0 {
            return names[row]
        }
        return ""
    }
    
    // Done
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        let names = sdk.sites.names
        if row < names.count && row >= 0 {
            selectedSite = sdk.sites.at(row)
            let name = names[row]
            selectSiteTextField.text = name
            closeSitePicker()
            siteIndexSelected = row
        }
    }

    // MARK: - Date Picker funcs
    
    @IBAction func chooseDateTextTapped(_ sender: Any) {
        // Unhide date picker
        UIView.transition(with: datePickerInputView as UIView,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: { self.datePickerInputView.isHidden = false
        }, completion: nil)
        datePicker.date = dateSelected ?? hormone.date
        let doneButton = makeDoneButton()
        datePickerInputView.addSubview(doneButton)
        autofillButton.isHidden = true
        chooseDateButton.isEnabled = false
        typeSiteButton.isEnabled = false
        selectSiteTextField.isEnabled = false
    }
    
    @objc func datePickerDone(_ sender: Any) {
        let doneButton = sender as! UIButton
        doneButton.removeFromSuperview()
        datePickerInputView.isHidden = true
        dateSelected = datePicker.date
        let interval = sdk.defaults.expirationInterval.hours
        let dateStr = PDDateHelper.format(date: datePicker.date, useWords: true)
        chooseDateButton.setTitle(dateStr, for: UIControl.State.normal)
        if let expDate = PDDateHelper.expirationDate(from: datePicker.date, interval) {
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
        selectSiteTextField.isEnabled = true
    }
    
    // MARK: - private funcs
    
    private func displayAttributeTexts() {
        ledft isNewSite = hormone.siteName == PDStrings.PlaceholderStrings.newSite
        selectSiteTextField.text = name
        
        if hormone.siteName == PDStrings.PlaceholderStrings.newSite {
            selectSiteTextField.text = PDActionStrings.select
        } else {
            selectSiteTextField.text = name
        }
        
        switch hormone.siteName {
        case PDStrings.PlaceholderStrings.newSite:
            selectSiteTextField.text = PDActionStrings.select
        default:
            selectSiteTextField.text = name
        }
        let interval = sdk.defaults.expirationInterval
        let formattedDate = PDDateHelper.format(date: hormone.date, useWords: true)
        chooseDateButton.setTitle(formattedDate, for: .normal)
        expirationDateLabel.text = hormone.expirationString
    }

    /// Saves any changed attributes.
    private func saveData() {
        if siteTextHasChanged, let siteName = selectSiteTextField.text {
            if let site = selectedSite {
                sdk.setHormoneSite(at: siteIndexSelected, with: site)
            } else {
                sdk.hormones.setBackUpSiteName(at: siteIndexSelected, with: siteName)
            }
        }
        
        if dateTextHasChanged {
            sdk.hormones.setDate(at: estrogenScheduleIndex, with: datePicker.date)
        }
        if !dateTextHasChanged {
            state.onlySiteChanged = true
        }
    }
    
    private func autoPickSite() {
        let set = defaults.setSiteIndex
        if let suggestedSite = siteSchedule.suggest(changeIndex: set) {
            selectedSite = suggestedSite
            shouldSaveIncrementedSiteIndex = true
            shouldSaveSelectedSiteIndex = false
            if let suggestedSiteName = suggestedSite.name{
                selectSiteTextField.text = suggestedSiteName
                siteTextHasChanged = true
                siteIndexSelected = Int(suggestedSite.order)
            }
        }
    }
    
    private func autoPickDate() {
        let now = Date()
        let interval = defaults.expirationInterval.hours
        chooseDateButton.setTitle(PDDateHelper.format(date: now, useWords: true), for: .normal)
        if let expDate = PDDateHelper.expirationDate(from: now, interval) {
            expirationDateLabel.text = PDDateHelper.format(date: expDate, useWords: true)
            dateTextHasChanged = true
            dateSelected = now
        }
    }
    
    private func requestNotifications() {
        if let mone = hormone {
            notifications.requestHormoneExpiredNotification(for: estro)

            // Overnight
            let interval = defaults.expirationInterval
            if let expDate = estro.expirationDate(interval: interval),
                expDate.isOvernight() {
                notifications.requestOvernightNotification(estro, expDate: expDate)
            }
        }
    }
    
    private func cancelNotification() {
        notifications.cancelHormoneNotification(at: hormoneIndex)
    }
    
    // MARK: - Private
    
    private func findSiteStartRow(_ site: String) -> Int {
        if siteIndexSelected != -1 {
            return siteIndexSelected
        } else if let site = estrogen.getSite() {
            let order = site.order
            if order >= 1 && order <= siteSchedule.count() {
                let i = Int(order)
                siteIndexSelected = i
                return i
            }
        }
        return 0
    }
    
    /// Sets titles related to the hormone's expiration date.
    private func setUpLabelsInUI() {
        if let mone = hormone {
            let method = sdk.deliveryMethod
            let viewStrings = PDColonedStrings.getHormoneViewStrings(
                deliveryMethod: method,
                hormone: mone
            )
            expLabel.text = viewStrings.expirationText
            dateAndTimePlaced.text = viewStrings.dateAndTimePlacedText
            siteLabel.text = viewStrings.siteLabeText
            expirationDateLabel.text  = mone.expirationString
        } else {
            expirationDateLabel.text  = PDStrings.PlaceholderStrings.dotDotDot
        }
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
        doneButton.setTitle(PDActionStrings.done, for: UIControl.State.normal)
        doneButton.setTitle(PDActionStrings.done, for: UIControl.State.highlighted)
        doneButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        doneButton.setTitleColor(UIColor.black, for: UIControl.State.highlighted)
        doneButton.removeTarget(nil, action: nil, for: .allEvents)
        doneButton.addTarget(self, action: #selector(datePickerDone), for: .touchUpInside)
        return doneButton
    }

    private func loadTitle() {
        title = PDVCTitleStrings.getTitle(for: sdk.deliveryMethod)
    }
    
    /// Gives start x for date picker Done button depending on iPad vs iPhone.
    private func configureDoneButtonStartX() -> CGFloat {
        let x = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ?
            (view.frame.size.width / 2) - 50 : 0
        return x
    }
    
    private func configureBadgeIcon(_ wasExpiredBeforeSave: Bool,_ isExpiredAfterSave: Bool) {
        // New mone is fresh
        let hasBadge = UIApplication.shared.applicationIconBadgeNumber > 0
        if !isExpiredAfterSave && hasBadge {
            UIApplication.shared.applicationIconBadgeNumber -= 1
        } else if !wasExpiredBeforeSave && isExpiredAfterSave {
            // New mone is not fresh
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
