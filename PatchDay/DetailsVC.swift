//
//  DetailsVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit

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
        self.chooseSiteButton.autocapitalizationType = .words
        view.backgroundColor = PDColors.pdPink
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: PDStrings.actionStrings.save, style: .plain, target: self, action: #selector(saveButtonTapped(_:)))
        self.saveButton = self.navigationItem.rightBarButtonItem
        self.saveButton.isEnabled = false
        self.setScheduleAndHeading()
        self.sitePicker.isHidden = true
        self.autofillButton.setTitleColor(UIColor.darkGray, for: UIControlState.disabled)
        self.bigGap.backgroundColor = PDColors.pdPink
        self.bigGap2.backgroundColor = PDColors.pdPink
        
        // Default texts
        self.displayAttributeTexts()
        
        // Text editing delegate as self
        self.chooseSiteButton.delegate = self
 
        // Site picker set up
        self.sitePicker.delegate = self
        self.sitePicker.dataSource = self
        
        // Site Type setup
        self.verticalLineInSiteStack.backgroundColor = self.lineUnderDate.backgroundColor
        self.typeSiteButton.setTitle(PDStrings.actionStrings.type, for: .normal)
        if let lab = self.typeSiteButton.titleLabel, let t = lab.text, t.count > 4 {
            self.typeSiteButton.setTitle("⌨️", for: .normal)
        }
    }
    
    // Save Button
    // 1.) Side effects related to schedule animation
    // 2.) Save data
    // 3.) Notification badge number config
    // 4.) Segue back to the ScheduleVC
    // 5.) Set site index
    @objc private func saveButtonTapped(_ sender: Any) {
        self.configureBadgeIcon()
        let estroCount = ScheduleController.estrogenSchedule().datePlacedCount()
        
        // Schedule animation side-effects
        ScheduleController.indexOfChangedDelivery = (estroCount != UserDefaultsController.getQuantityInt() && self.dateTextHasChanged) ? estroCount : (self.estrogenScheduleIndex)
        ScheduleController.animateScheduleFromChangeDelivery = true
        
        // Transition
        if let navCon = self.navigationController {
            navCon.popViewController(animated: true)
        }
        
        if self.shouldSaveIncrementedSiteIndex {
            UserDefaultsController.incrementSiteIndex()
        }
        else if self.shouldSaveSelectedSiteIndex {
            UserDefaultsController.setSiteIndex(to: self.siteIndexSelected)
        }
 
    }
    
    @IBAction private func autofillTapped(_ sender: Any) {
        self.autoPickSite()                                // Loc from SLF
        self.autoPickDate()
        // Date is now.
        // ** Bools for saving **
        self.dateTextHasChanged = true
        self.siteTextHasChanged = true
        self.saveButton.isEnabled = true
    }
    
    // MARK: - Text Edit Functions
    
    @IBAction private func keyboardTapped(_ sender: Any) {
        self.chooseSiteButton.restorationIdentifier = "type"
        self.chooseSiteButton.becomeFirstResponder()
    }
    
    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        self.chooseSiteButton.isUserInteractionEnabled = true
        
        // Use site picker
        if textField.restorationIdentifier == "pick" {
            self.openSitePicker(textField)
        }
        
        // Use keyboard
        else if textField.restorationIdentifier == "type" {
            self.chooseSiteButton.text = ""
        }
        self.chooseDateButton.isEnabled = false
        self.typeSiteButton.isEnabled = false
        self.autofillButton.isHidden = true
        textField.restorationIdentifier = "pick"
 
    }
 
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.chooseSiteButton.endEditing(true)
        self.chooseSiteButton.isEnabled = true
        self.chooseDateButton.isEnabled = true
        self.autofillButton.isHidden = false
        self.siteTextHasChanged = true
        self.chooseSiteButton.isHidden = false
        self.typeSiteButton.isEnabled = true
        if let newSiteName = self.chooseSiteButton.text {
              PDAlertController.alertForAddingNewSite(newSiteName: newSiteName)
        }
        self.saveButton.isEnabled = true
        return true
        
    }
    
    // MARK: - Picker Functions
    
    @IBAction internal func openSitePicker(_ sender: Any) {
        self.sitePicker.isHidden = false
        self.sitePicker.selectRow(self.findSiteStartRow(self.site), inComponent: 0, animated: false)
        // other View changes
        self.autofillButton.isHidden = true
        self.autofillButton.isEnabled = false
        self.typeSiteButton.isEnabled = false
        self.chooseSiteButton.isEnabled = false
        self.chooseDateButton.isEnabled = false

    }

    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.sites.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sites[row]
    }
    
    // Done
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let newLoc = sites[row]
        self.chooseSiteButton.text = newLoc
        self.site = newLoc
        // other view changes
        self.sitePicker.isHidden = true
        self.autofillButton.isEnabled = true
        self.chooseDateButton.isEnabled = true
        self.typeSiteButton.isEnabled = true
        self.chooseSiteButton.isEnabled = true
        self.chooseSiteButton.isHidden = false
        self.autofillButton.isHidden = false
        self.siteTextHasChanged = true
        self.saveButton.isEnabled = true
        self.shouldSaveSelectedSiteIndex = true
        self.shouldSaveIncrementedSiteIndex = false
        self.siteIndexSelected = row
    }

    // MARK: - Date Picker funcs
    
    @IBAction internal func chooseDateTextTapped(_ sender: Any) {
        
        self.createDateAddSubview()
        // disable \ hide stuff
        self.autofillButton.isHidden = true
        self.chooseDateButton.isEnabled = false
        self.typeSiteButton.isEnabled = false
        self.chooseSiteButton.isEnabled = false
        
    }
    
    @objc internal func datePickerDone(sender: UIButton) {
        self.dateInputView.isHidden = true
        // disp date and time applied
        let d = self.datePicker.date
        self.datePlaced = d             // set temp
        self.chooseDateButton.setTitle(MOEstrogen.makeDateString(from: d, useWords: true), for: UIControlState.normal)
        if let expDate = MOEstrogen.expiredDate(fromDate: self.datePicker.date) {            // disp exp date
            self.expirationDateLabel.text = MOEstrogen.makeDateString(from: expDate, useWords: true)
        }
        // outer view changes
        self.saveButton.isEnabled = true
        self.chooseDateButton.isEnabled = true
        self.typeSiteButton.isEnabled = true
        self.autofillButton.isHidden = false
        self.siteStackView.isHidden = false
        self.siteLabel.isHidden = false
        self.dateTextHasChanged = true
        self.chooseSiteButton.isEnabled = true

    }
    
    // MARK: - private funcs
    
    private func displayAttributeTexts() {
        if let estro = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: self.estrogenScheduleIndex) {
            // site placed
            if estro.getLocation() != PDStrings.placeholderStrings.unplaced {
                // set site label text to patch's site
                let loc = estro.getLocation()              // set temp
                self.chooseSiteButton.text = loc
                self.site = loc
            }
            // site not placed
            else {
                self.chooseSiteButton.text = PDStrings.actionStrings.select
            }
            // date placed
            if let date = estro.getDate() {
                // set date choose button's text to patch's date palced data
                self.datePlaced = date                  // set temp
                self.chooseDateButton.setTitle(MOEstrogen.makeDateString(from: date, useWords: true) , for: .normal)
                self.expirationDateLabel.text = estro.expirationDateAsString(timeInterval: UserDefaultsController.getTimeInterval(), useWords: true)
            }
            // date unplaced
            else {
                self.chooseDateButton.setTitle(PDStrings.actionStrings.select, for: .normal)
            }
        }
        // nil patch
        else {
            self.chooseSiteButton.text = PDStrings.actionStrings.select
            self.chooseDateButton.setTitle(PDStrings.actionStrings.select, for: .normal)
        }
    }
    
    internal func setEstrogenScheduleIndex(to: Int) {
        self.estrogenScheduleIndex = to
    }
    
    private func saveAttributes() {
        // save only if there are changes.
        if self.siteTextHasChanged {
            // current patch must exist since we are editing it
            guard let newSite = self.chooseSiteButton.text, newSite != "" else {
                return
            }
            ScheduleController.coreDataController.setEstrogenDeliveryLocation(scheduleIndex: self.estrogenScheduleIndex, with: newSite)
            // set values for ScheduleVC animation algorithm
            if !self.dateTextHasChanged {
                ScheduleController.onlySiteChanged = true
            }
        }
        if self.dateTextHasChanged {
            ScheduleController.coreDataController.setEstrogenDeliveryDate(scheduleIndex: self.estrogenScheduleIndex, with: datePicker.date)
        }
        
    }
    
    private func autoPickSite() {
        let scheduleSites: [String] = ScheduleController.siteSchedule().siteNamesArray
        let currentSites: [String] = ScheduleController.estrogenSchedule().currentSiteNames
        let suggestedSiteIndex = SiteSuggester.suggest(estrogenScheduleIndex: self.estrogenScheduleIndex, currentSites: currentSites)
        if suggestedSiteIndex >= 0 && suggestedSiteIndex < scheduleSites.count {
            self.shouldSaveIncrementedSiteIndex = true
            self.shouldSaveSelectedSiteIndex = false
            self.chooseSiteButton.text = scheduleSites[suggestedSiteIndex]
        }
    }
    
    private func autoPickDate() {
        let now = Date()
        self.chooseDateButton.setTitle(MOEstrogen.makeDateString(from: now, useWords: true), for: .normal)
        if let expDate = MOEstrogen.expiredDate(fromDate: now) {
            self.expirationDateLabel.text = MOEstrogen.makeDateString(from: expDate, useWords: true)
        }
    }
    
    private func requestNotification() {
        // request notification iff exists Patch.date
        appDelegate.notificationsController.requestNotifyExpired(scheduleIndex: self.estrogenScheduleIndex)
    }
    
    private func cancelNotification() {
        appDelegate.notificationsController.cancelSchedule(index: self.estrogenScheduleIndex)
    }
    
    // MARK: - Private view creators / MOEstrogendifiers
    
    private func findSiteStartRow(_ site: String) -> Int {
        if let i = self.sites.index(of: site) {
            return i
        }
        return 0
    }
    
    private func setScheduleAndHeading() {
        let interval = UserDefaultsController.getTimeInterval()
        var exp = ""
        if let estro = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: self.estrogenScheduleIndex) {            // unplaced patch instruction
            if estro.getLocation() == PDStrings.placeholderStrings.unplaced {
                exp = PDStrings.placeholderStrings.dotdotdot
            }
            else {
                if estro.isExpired(timeInterval: interval) {
                    self.expiresOrExpiredLabel.text = PDStrings.colonedStrings.expired
                }
                else {
                    self.expiresOrExpiredLabel.text = PDStrings.colonedStrings.expires
                }
                exp = estro.expirationDateAsString(timeInterval: interval, useWords: true)
            }
            self.expirationDateLabel.text = exp
        }
        else {
            exp = PDStrings.placeholderStrings.dotdotdot
        }
    }
    
    // for self.createDateAddSubview() self.dateAddTapped()
    private func makeInputViewForDatePicker() -> UIView {
        let viewPoint = CGPoint(x: configureDatePickerStartX(), y: self.view.frame.height/2)
        let viewSize = CGSize(width: self.view.frame.width, height: 240)
        let viewRect = CGRect(origin: viewPoint, size: viewSize)
        return UIView(frame: viewRect)
        
    }
    
    // for self.makeInputViewForDatePicker
    // two different x values based on on whether iphone or ipad
    private func configureDatePickerStartX() -> CGFloat {
        // iPhone
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
            return 0
        }
        // iPad
        else {
            return self.view.frame.width/2.8
        }
    }
    
    // for self.createDateAddSubview() self.dateAddTapped()
    private func makeDatePickerView() -> UIDatePicker {
        let datePickerPoint = CGPoint(x: 0, y: 40)
        let datePickerSize = CGSize(width: 0, height: 0)
        let datePickerRect = CGRect(origin: datePickerPoint, size: datePickerSize)
        let datePickerView: UIDatePicker = UIDatePicker(frame: datePickerRect)
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        datePickerView.date = self.datePlaced
        datePickerView.maximumDate = Date()
        return datePickerView
        
    }
    
    // for self.createDateAddSubview() from self.dateAddTapped()
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
    
    // for self.makedoneButton()
    private func configureDoneButtonStartX() -> CGFloat {
        // iPhone
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
            return (self.view.frame.size.width/2) - 50
        }
            // iPad
        else {
            return 0
        }
    }
    
    private func configureBadgeIcon() {
        if let estro = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: self.estrogenScheduleIndex) {
            
            let wasExpiredBeforeSave: Bool = estro.isExpired(timeInterval: UserDefaultsController.getTimeInterval())
            self.saveAttributes()
            let isExpiredAfterSave = estro.isExpired(timeInterval: UserDefaultsController.getTimeInterval())
            
            // New estro is fresh
            if !isExpiredAfterSave && UIApplication.shared.applicationIconBadgeNumber > 0 {
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
                
                // New estro is not fresh
            else if !wasExpiredBeforeSave && isExpiredAfterSave {
                UIApplication.shared.applicationIconBadgeNumber += 1
            }
            
            if !wasExpiredBeforeSave {
                self.cancelNotification()
            }
            self.requestNotification()
            
        }
    }
    
    // for self.dateAddTapped()
    private func createDateAddSubview() {
        let inputView = self.makeInputViewForDatePicker()
        let datePickerView: UIDatePicker = self.makeDatePickerView()
        inputView.addSubview(datePickerView)
        let doneButton = self.makeDoneButton()
        inputView.addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(datePickerDone), for: .touchUpInside)
        self.view.addSubview(inputView)
        
        // update members vars
        self.datePicker = datePickerView
        self.dateInputView = inputView
        
    }

    // lines
    private func hideLines() {
        self.lineUnderScheduleDate.isHidden = true
        self.lineUnderDateAndTimePlaced.isHidden = true
        self.lineUnderExpires.isHidden = true
        self.horizontalLineAboveSite.isHidden = true
        self.horizontalLineBelowSite.isHidden = true
        self.lineUnderDate.isHidden = true
        self.verticalLineInSiteStack.isHidden = true
    }
    
    // lines
    private func unhideLines() {
        self.lineUnderScheduleDate.isHidden = false
        self.lineUnderDateAndTimePlaced.isHidden = false
        self.lineUnderExpires.isHidden = false
        self.horizontalLineAboveSite.isHidden = false
        self.horizontalLineBelowSite.isHidden = false
        self.lineUnderDate.isHidden = false
        self.verticalLineInSiteStack.isHidden = false
    }

}
