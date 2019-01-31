//
//  EstrogenVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class EstrogenVC: UIViewController,
                  UIPickerViewDelegate,
                  UIPickerViewDataSource,
                  UITextFieldDelegate {
    
    private var selectedSite: MOSite?
    
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
        estrogen = EstrogenScheduleRef.getEstrogen(at: estrogenScheduleIndex)
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
        let interval = Defaults.getTimeInterval()
        if let estro = estrogen {
            let wasExpiredBeforeSave: Bool = estro.isExpired(interval)
            saveData()    // Save
            let isExpiredAfterSave = estro.isExpired(interval)
            configureBadgeIcon(wasExpiredBeforeSave, isExpiredAfterSave)
            requestNotification()
            EstrogenScheduleRef.sort()
            // Save effects
            State.wereEstrogenChanges = true
            if let i = EstrogenScheduleRef.getIndex(for: estro) {
                State.indexOfChangedDelivery = i
            }
        }
        
        let estrosDue = Schedule.totalDue(interval: interval)
        self.navigationController?.tabBarItem.badgeValue =
            (estrosDue <= 0) ? nil : String(estrosDue)
        
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
        if textField.restorationIdentifier == "pick" {
            // Use site picker
            openSitePicker(textField)
        } else if textField.restorationIdentifier == "type" {
            // Use keyboard
            chooseSiteButton.text = ""
        }
        chooseDateButton.isEnabled = false
        typeSiteButton.isEnabled = false
        autofillButton.isHidden = true
        textField.restorationIdentifier = "pick"
    }
 
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.selectedSite = nil
        chooseSiteButton.endEditing(true)
        chooseSiteButton.isEnabled = true
        chooseDateButton.isEnabled = true
        autofillButton.isHidden = false
        siteTextHasChanged = true
        chooseSiteButton.isHidden = false
        typeSiteButton.isEnabled = true
        saveButton.isEnabled = true
        siteIndexSelected = SiteScheduleRef.count()
        if let n = textField.text {
            PDAlertController.alertForAddSite(with: n,
                                              at: siteIndexSelected,
                                              estroVC: self)
        }
        return true
    }
    
    // MARK: - Picker Functions
    
    @IBAction internal func openSitePicker(_ sender: Any) {
        UIView.transition(with: sitePicker as UIView,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: { self.sitePicker.isHidden = false
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
    
    internal func pickerView(_ pickerView: UIPickerView,
                             numberOfRowsInComponent component: Int) -> Int {
        return SiteScheduleRef.count()
    }
    
    internal func pickerView(_ pickerView: UIPickerView,
                             titleForRow row: Int,
                             forComponent component: Int) -> String? {
        let names = SiteScheduleRef.getNames()
        if row < names.count && row >= 0 {
            return names[row]
        }
        return ""
    }
    
    // Done
    internal func pickerView(_ pickerView: UIPickerView,
                             didSelectRow row: Int,
                             inComponent component: Int) {
        let names = SiteScheduleRef.getNames()
        if row < names.count && row >= 0 {
            selectedSite = SiteScheduleRef.getSite(at: row)
            let name = SiteScheduleRef.getNames()[row]
            chooseSiteButton.text = name
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
    }

    // MARK: - Date Picker funcs
    
    @IBAction internal func chooseDateTextTapped(_ sender: Any) {
        
        // Unhide date picker
        UIView.transition(with: datePickerInputView as UIView,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: { self.datePickerInputView.isHidden = false
        }, completion: nil)
        if let date = dateSelected ?? estrogen?.getDate() as Date? {
             datePicker.date = date
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
        let interval = Defaults.getTimeInterval()
        let dateStr = PDDateHelper.format(date: datePicker.date, useWords: true)
        chooseDateButton.setTitle(dateStr, for: UIControlState.normal)
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
        chooseSiteButton.isEnabled = true
    }
    
    // MARK: - private funcs
    
    private func displayAttributeTexts() {
        let n = estrogen.getSiteName()
        switch n {
        case PDStrings.PlaceholderStrings.new_site:
            chooseSiteButton.text = PDStrings.ActionStrings.select
        default:
            chooseSiteButton.text = n
        }
        if let date = estrogen.getDate() {
            let interval = Defaults.getTimeInterval()
            datePlaced = date as Date
            let formattedDate = PDDateHelper.format(date: date as Date,
                                                    useWords: true)
            chooseDateButton.setTitle(formattedDate, for: .normal)
            expirationDateLabel.text = estrogen.expirationDateAsString(interval,
                                                                       useWords: true)
        } else {
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
    
    private func saveSite() {
        if siteTextHasChanged {
            State.siteChanged = true
            switch (selectedSite, chooseSiteButton.text) {
            // Attempt saving site via MOSite first
            case (let site, _) where site != nil :
                let setter = Schedule.setEstrogenDataForToday
                EstrogenScheduleRef.setSite(of: estrogenScheduleIndex,
                                         with: site!,
                                         setSharedData: setter)
            // Use backupsite name when there is no site.
            case (nil, let name) where name != nil :
                EstrogenScheduleRef.setBackUpSiteName(of: estrogenScheduleIndex,
                                                   with: name!)
            default : break
            }
        }
    }
    
    private func saveDate() {
        if dateTextHasChanged {
            let setter = Schedule.setEstrogenDataForToday
            EstrogenScheduleRef.setDate(of: estrogenScheduleIndex,
                                     with: datePicker.date,
                                     setSharedData: setter)
        }
    }
    
    /// Saves any changed attributes.
    private func saveData() {
        saveSite()
        saveDate()
        // For EstrogensVC animation.
        if !dateTextHasChanged {
            State.onlySiteChanged = true
        }
    }
    
    private func autoPickSite() {
        let set = Defaults.setSiteIndex
        if let suggestedSite = SiteScheduleRef.suggest(changeIndex: set) {
            selectedSite = suggestedSite
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
        let interval = Defaults.getTimeInterval()
        chooseDateButton.setTitle(PDDateHelper.format(date: now, useWords: true), for: .normal)
        if let expDate = PDDateHelper.expirationDate(from: now, interval) {
            expirationDateLabel.text = PDDateHelper.format(date: expDate, useWords: true)
            dateTextHasChanged = true
            dateSelected = now
        }
    }
    
    private func requestNotification() {
        if let estro = estrogen {
            let notCon = appDelegate.notificationsController
            notCon.requestEstrogenExpiredNotification(for: estro)
            // Overnight
            let interval = Defaults.getTimeInterval()
            if let expDate = estro.expirationDate(interval: interval),
                expDate.isOvernight() {
                notCon.requestOvernightNotification(estro, expDate: expDate)
            }
        }
    }
    
    private func cancelNotification() {
        let nc = appDelegate.notificationsController
        nc.cancelEstrogenNotification(at: estrogenScheduleIndex)
    }
    
    // MARK: - Private view creators / MOEstrogendifiers
    
    private func findSiteStartRow(_ site: String) -> Int {
        if siteIndexSelected != -1 {
            return siteIndexSelected
        } else if let site = estrogen.getSite() {
            let order = site.getOrder()
            if order >= 1 && order <= SiteScheduleRef.count() {
                let i = Int(order)
                siteIndexSelected = i
                return i
            }
        }
        return 0
    }
    
    /// Sets titles related to the estrogen's expiration date.
    private func setUpLabelsInUI() {
        var exp = ""
        typealias Strings = PDStrings.ColonedStrings
        let interval = Defaults.getTimeInterval()
        if let estro = EstrogenScheduleRef.getEstrogen(at: estrogenScheduleIndex),
            estro.getDate() != nil {
            switch Defaults.usingPatches() {
            case true :
                expLabel.text = (estro.isExpired(interval)) ?
                    Strings.expired :
                    Strings.expires
                dateAndTimePlaced.text = Strings.date_and_time_applied
                siteLabel.text = Strings.site
            case false :
                expLabel.text = Strings.next_due
                dateAndTimePlaced.text = Strings.date_and_time_injected
                siteLabel.text = Strings.last_site_injected
            }
            exp = estro.expirationDateAsString(interval, useWords: true)
        } else {
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
            typealias Titles = PDStrings.VCTitles
            title = (Defaults.usingPatches()) ?
                Titles.patch :
                Titles.injection
        }
    }
    
    /// Gives start x for date picker Done button depending on iPad vs iPhone.
    private func configureDoneButtonStartX() -> CGFloat {
        let x = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ?
            (view.frame.size.width / 2) - 50 : 0
        return x
    }
    
    private func configureBadgeIcon(_ wasExpiredBeforeSave: Bool,_ isExpiredAfterSave: Bool) {
        // New estro is fresh
        let hasBadge = UIApplication.shared.applicationIconBadgeNumber > 0
        if !isExpiredAfterSave && hasBadge {
            UIApplication.shared.applicationIconBadgeNumber -= 1
        } else if !wasExpiredBeforeSave && isExpiredAfterSave {
            // New estro is not fresh
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
