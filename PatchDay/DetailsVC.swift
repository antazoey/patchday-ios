//
//  DetailsVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class DetailsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //MARK: - Main
    
    // main subview
    @IBOutlet private weak var popUpView: UIView!
    
    // edit date and site buttons
    @IBOutlet private weak var chooseSiteButton: UITextField!
    @IBOutlet private weak var chooseDateButton: UIButton!
    @IBOutlet private var typeSiteButton: UIButton!
    @IBOutlet private weak var expiresOrExpiredLabel: UILabel!
    @IBOutlet private weak var expirationDateLabel: UILabel!
    @IBOutlet private var horizontalLineBelowSite: UIView!
    
    // Site bar
    @IBOutlet private weak var horizontalLineAboveSite: UIView!
    @IBOutlet private weak var siteStackView: UIStackView!
    @IBOutlet private weak var siteLabel: UILabel!

    // Autofill
    @IBOutlet private weak var autofillButton: UIButton!
    
    // MOEstrogenre site related
    @IBOutlet private weak var sitePicker: UIPickerView!
    
    // cosmetics
    @IBOutlet private weak var bigGap2: UIView!
    @IBOutlet private weak var bigGap: UIView!
    @IBOutlet private weak var lineUnderExpires: UIView!
    @IBOutlet private weak var lineUnderDateAndTimePlaced: UIView!
    @IBOutlet private weak var lineUnderDate: UIView!
    @IBOutlet private weak var verticalLineInSiteStack: UIView!
    
    // Non-IB
    private weak var saveButton: UIBarButtonItem!
    internal var estrogenScheduleIndex = -1
    internal var sites = ScheduleController.siteSchedule().siteNamesArray
    
    // temp save
    internal var site: String = ""
    internal var datePlaced: Date = Date()
    
    // date picker vars
    private var dateInputView = UIView()
    private var datePicker = UIDatePicker()
    
    // bools
    private var siteTextHasChanged = false
    private var dateTextHasChanged = false
    private var shouldSaveSelectedSiteIndex = false
    private var shouldSaveIncrementedSiteIndex = false
    private var siteIndexSelected = -1
    
    @IBOutlet private weak var lineUnderScheduleDate: UIView!
    @IBOutlet private weak var dateAndTimePlaced: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseSiteButton.autocapitalizationType = .words
        view.backgroundColor = PDColors.pdPink
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: PDStrings.actionStrings.save, style: .plain, target: self, action: #selector(saveButtonTapped(_:)))
        saveButton = navigationItem.rightBarButtonItem
        saveButton.isEnabled = false
        setScheduleAndHeading()
        sitePicker.isHidden = true
        autofillButton.setTitleColor(UIColor.darkGray, for: UIControlState.disabled)
        bigGap.backgroundColor = PDColors.pdPink
        bigGap2.backgroundColor = PDColors.pdPink
        
        // Default texts
        displayAttributeTexts()
        
        // Text editing delegate as self
        chooseSiteButton.delegate = self
 
        // Site picker set up
        sitePicker.delegate = self
        sitePicker.dataSource = self
        
        // Site Type setup
        verticalLineInSiteStack.backgroundColor = lineUnderDate.backgroundColor
        typeSiteButton.setTitle(PDStrings.actionStrings.type, for: .normal)
        if let lab = typeSiteButton.titleLabel, let t = lab.text, t.count > 4 {
            typeSiteButton.setTitle("⌨️", for: .normal)
        }
    }
    
    // Save Button
    // 1.) Side effects related to schedule animation
    // 2.) Save data
    // 3.) Notification badge number config
    // 4.) Segue back to the ScheduleVC
    // 5.) Set site index
    @objc private func saveButtonTapped(_ sender: Any) {
        
        // Save + badge icon
        if let estro = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: estrogenScheduleIndex) {
            let wasExpiredBeforeSave: Bool = estro.isExpired(timeInterval: UserDefaultsController.getTimeInterval())
            saveAttributes()
            let isExpiredAfterSave = estro.isExpired(timeInterval: UserDefaultsController.getTimeInterval())
            configureBadgeIcon(wasExpiredBeforeSave, isExpiredAfterSave)
        }
        let estroCount = ScheduleController.estrogenSchedule().datePlacedCount()
        
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
        
        // Transition
        if let navCon = navigationController {
            navCon.popViewController(animated: true)
        }
    }
    
    @IBAction private func autofillTapped(_ sender: Any) {
        autoPickSite()                                // Loc from SLF
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
        sitePicker.isHidden = false
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
        
        createDateAddSubview()
        // disable \ hide stuff
        autofillButton.isHidden = true
        chooseDateButton.isEnabled = false
        typeSiteButton.isEnabled = false
        chooseSiteButton.isEnabled = false
        
    }
    
    @objc internal func datePickerDone(sender: UIButton) {
        dateInputView.isHidden = true
        // disp date and time applied
        let d = datePicker.date
        datePlaced = d             // set temp
        chooseDateButton.setTitle(MOEstrogen.makeDateString(from: d, useWords: true), for: UIControlState.normal)
        if let expDate = MOEstrogen.expiredDate(fromDate: datePicker.date) {            // disp exp date
            expirationDateLabel.text = MOEstrogen.makeDateString(from: expDate, useWords: true)
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
        if let estro = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: estrogenScheduleIndex) {
            // site placed
            if estro.getLocation() != PDStrings.placeholderStrings.unplaced {
                // set site label text to patch's site
                let loc = estro.getLocation()              // set temp
                chooseSiteButton.text = loc
                site = loc
            }
            // site not placed
            else {
                chooseSiteButton.text = PDStrings.actionStrings.select
            }
            // date placed
            if let date = estro.getDate() {
                // set date choose button's text to patch's date palced data
                datePlaced = date                  // set temp
                chooseDateButton.setTitle(MOEstrogen.makeDateString(from: date, useWords: true) , for: .normal)
                expirationDateLabel.text = estro.expirationDateAsString(timeInterval: UserDefaultsController.getTimeInterval(), useWords: true)
            }
            // date unplaced
            else {
                chooseDateButton.setTitle(PDStrings.actionStrings.select, for: .normal)
            }
        }
        // nil patch
        else {
            chooseSiteButton.text = PDStrings.actionStrings.select
            chooseDateButton.setTitle(PDStrings.actionStrings.select, for: .normal)
        }
    }
    
    internal func setEstrogenScheduleIndex(to: Int) {
        estrogenScheduleIndex = to
    }
    
    private func saveAttributes() {
        // save only if there are changes.
        if siteTextHasChanged {
            // current patch must exist since we are editing it
            guard let newSite = chooseSiteButton.text, newSite != "" else {
                return
            }
            ScheduleController.coreDataController.setEstrogenDeliveryLocation(scheduleIndex: estrogenScheduleIndex, with: newSite)
            // set values for ScheduleVC animation algorithm
            if !dateTextHasChanged {
                ScheduleController.onlySiteChanged = true
            }
        }
        if dateTextHasChanged {
            ScheduleController.coreDataController.setEstrogenDeliveryDate(scheduleIndex: estrogenScheduleIndex, with: datePicker.date)
        }
        
    }
    
    private func autoPickSite() {
        if let currentSiteName = chooseSiteButton.text {
            let scheduleSites: [String] = ScheduleController.siteSchedule().siteNamesArray
            let currentSites: [String] = ScheduleController.estrogenSchedule().currentSiteNames
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
        chooseDateButton.setTitle(MOEstrogen.makeDateString(from: now, useWords: true), for: .normal)
        if let expDate = MOEstrogen.expiredDate(fromDate: now) {
            expirationDateLabel.text = MOEstrogen.makeDateString(from: expDate, useWords: true)
        }
    }
    
    private func requestNotification() {
        // request notification iff exists Patch.date
        appDelegate.notificationsController.requestNotifyExpired(scheduleIndex: estrogenScheduleIndex)
    }
    
    private func cancelNotification() {
        appDelegate.notificationsController.cancelSchedule(index: estrogenScheduleIndex)
    }
    
    // MARK: - Private view creators / MOEstrogendifiers
    
    private func findSiteStartRow(_ site: String) -> Int {
        if let i = sites.index(of: site) {
            return i
        }
        return 0
    }
    
    private func setScheduleAndHeading() {
        let interval = UserDefaultsController.getTimeInterval()
        var exp = ""
        if let estro = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: estrogenScheduleIndex) {            // unplaced patch instruction
            if estro.getLocation() == PDStrings.placeholderStrings.unplaced {
                exp = PDStrings.placeholderStrings.dotdotdot
            }
            else {
                if estro.isExpired(timeInterval: interval) {
                    expiresOrExpiredLabel.text = PDStrings.colonedStrings.expired
                }
                else {
                    expiresOrExpiredLabel.text = PDStrings.colonedStrings.expires
                }
                exp = estro.expirationDateAsString(timeInterval: interval, useWords: true)
            }
            expirationDateLabel.text = exp
        }
        else {
            exp = PDStrings.placeholderStrings.dotdotdot
        }
    }
    
    // for createDateAddSubview() dateAddTapped()
    private func makeInputViewForDatePicker() -> UIView {
        let viewPoint = CGPoint(x: configureDatePickerStartX(), y: view.frame.height/2)
        let viewSize = CGSize(width: view.frame.width, height: 240)
        let viewRect = CGRect(origin: viewPoint, size: viewSize)
        return UIView(frame: viewRect)
        
    }
    
    // for makeInputViewForDatePicker
    // two different x values based on on whether iphone or ipad
    private func configureDatePickerStartX() -> CGFloat {
        // iPhone
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
            return 0
        }
        // iPad
        else {
            return view.frame.width/2.8
        }
    }
    
    // for createDateAddSubview() dateAddTapped()
    private func makeDatePickerView() -> UIDatePicker {
        let datePickerPoint = CGPoint(x: 0, y: 40)
        let datePickerSize = CGSize(width: 0, height: 0)
        let datePickerRect = CGRect(origin: datePickerPoint, size: datePickerSize)
        let datePickerView: UIDatePicker = UIDatePicker(frame: datePickerRect)
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        datePickerView.date = datePlaced
        datePickerView.maximumDate = Date()
        return datePickerView
        
    }
    
    // for createDateAddSubview() from dateAddTapped()
    private func makeDoneButton() -> UIButton {
        let donePoint = CGPoint(x: configureDoneButtonStartX(), y: 0)
        let doneSize = CGSize(width: 100, height: 50)
        let doneRect = CGRect(origin: donePoint, size: doneSize)
        let doneButton = UIButton(frame: doneRect)
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
        return doneButton
        
    }
    
    // for makedoneButton()
    private func configureDoneButtonStartX() -> CGFloat {
        // iPhone
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
            return (view.frame.size.width/2) - 50
        }
            // iPad
        else {
            return 0
        }
    }
    
    // Save a
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
    
    // for dateAddTapped()
    private func createDateAddSubview() {
        let inputView = makeInputViewForDatePicker()
        let datePickerView: UIDatePicker = makeDatePickerView()
        inputView.addSubview(datePickerView)
        let doneButton = makeDoneButton()
        inputView.addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(datePickerDone), for: .touchUpInside)
        view.addSubview(inputView)
        
        // update members vars
        datePicker = datePickerView
        dateInputView = inputView
        
    }

    // lines
    private func hideLines() {
        lineUnderScheduleDate.isHidden = true
        lineUnderDateAndTimePlaced.isHidden = true
        lineUnderExpires.isHidden = true
        horizontalLineAboveSite.isHidden = true
        horizontalLineBelowSite.isHidden = true
        lineUnderDate.isHidden = true
        verticalLineInSiteStack.isHidden = true
    }
    
    // lines
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
