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
    
    // edit date and location buttons
    @IBOutlet private weak var locationTextEdit: UITextField!
    @IBOutlet private weak var chooseDateTextButton: UIButton!
    @IBOutlet private var addLocationTextButton: UIButton!
    @IBOutlet private weak var expiresOrExpiredLabel: UILabel!
    @IBOutlet private weak var expirationDateLabel: UILabel!
    @IBOutlet private var horizontalLineBelowLocation: UIView!
    
    // Location bar
    @IBOutlet private weak var horizontalLineAboveLocation: UIView!
    @IBOutlet private weak var locationStackView: UIStackView!
    @IBOutlet private weak var locationLabel: UILabel!

    // save, change patch
    @IBOutlet private weak var save: UIButton!
    @IBOutlet private weak var autofillButton: UIButton!
    
    // MOEstrogenDeliveryre location related
    @IBOutlet private weak var locationPicker: UIPickerView!
    
    // cosmetics
    @IBOutlet private weak var bigGap2: UIView!
    @IBOutlet private weak var bigGap: UIView!
    @IBOutlet private weak var lineUnderExpires: UIView!
    @IBOutlet private weak var lineUnderDateAndTimePlaced: UIView!
    @IBOutlet private weak var lineUnderdate: UIView!
    
    // reference to which patch it is (index in patches = reference - 1)
    // references: 1,2,3,4
    // note: not indices
    internal var reference = 0
    
    // temp save
    internal var location: String = ""
    internal var datePlaced: Date = Date()
    
    // date picker vars
    private var dateInputView = UIView()
    private var datePicker = UIDatePicker()
    
    // bools
    private var locationTextHasChanged = false
    private var dateTextHasChanged = false
    
    @IBOutlet private weak var lineUnderExpirationDate: UIView!
    @IBOutlet private weak var dateAndTimePlaced: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PDColors.pdPink
        self.save.isHidden = true
        self.setExpirationAndHeading()
        self.locationPicker.isHidden = true
        self.autofillButton.setTitleColor(UIColor.darkGray, for: UIControlState.disabled)
        self.bigGap.backgroundColor = PDColors.pdPink
        self.bigGap2.backgroundColor = PDColors.pdPink
        
        // default texts
        self.displayAttributeTexts()
        
        // text editing delegate as self
        self.locationTextEdit.delegate = self

        // location picker set up
        self.locationPicker.delegate = self
        self.locationPicker.dataSource = self

    }
    
    // Save Button
    // 1.) Side effects related to schedule animation
    // 2.) Save data
    // 3.) Request notifications
    // 4.) Notification badge number config
    // 5.) Segue back to the ScheduleVC
    @IBAction private func saveButtonTapped(_ sender: Any) {
        let moCount = ScheduleController.schedule().datePlacedCount()
        
        // Schedule animation side-effects
        ScheduleController.indexOfChangedDelivery = (moCount != UserDefaultsController.getQuantityInt() && self.dateTextHasChanged) ? moCount : (self.reference - 1)
        ScheduleController.animateScheduleFromChangeDelivery = true
        
        // ***** CONFIG BADGE ICON *****
        if let mo = ScheduleController.coreData.getMO(forIndex: self.reference - 1) {
        
            let wasExpiredBeforeSave: Bool = mo.isExpired(timeInterval: UserDefaultsController.getTimeInterval())
            self.saveAttributes()
            let isExpiredAfterSave = mo.isExpired(timeInterval: UserDefaultsController.getTimeInterval())
            
            // New MO is fresh
            if !isExpiredAfterSave && UIApplication.shared.applicationIconBadgeNumber > 0 {
                    UIApplication.shared.applicationIconBadgeNumber -= 1
            }
                
            // New MO is not fresh
            else if !wasExpiredBeforeSave && isExpiredAfterSave {
                UIApplication.shared.applicationIconBadgeNumber += 1
            }
        
            if !wasExpiredBeforeSave {
                self.cancelNotification()
            }
            self.requestNotification()
        
        }
        
        // Transition
        if let navCon = self.navigationController {
            navCon.popViewController(animated: true)
        }
 
    }
    
    @IBAction private func autofillTapped(_ sender: Any) {
        self.autoPickLocation()                                // Loc from SLF
        self.autoPickDate()                                    // Date is now.
        self.save.isEnabled = true
        self.save.isHidden = false
        // ** Bools for saving **
        self.dateTextHasChanged = true
        self.locationTextHasChanged = true
    }
    
    // MARK: - Text Edit Functions
    
    @IBAction private func keyboardTapped(_ sender: Any) {
        self.locationTextEdit.restorationIdentifier = "type"
        self.locationTextEdit.becomeFirstResponder()
    }
    
    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        self.locationTextEdit.isUserInteractionEnabled = true
        
        // Use location picker
        if textField.restorationIdentifier == "pick" {
            self.openLocationPicker(textField)
        }
        
        // Use keyboard
        else if textField.restorationIdentifier == "type" {
            self.locationTextEdit.text = ""
            self.locationTextEdit.becomeFirstResponder()
        }
        self.chooseDateTextButton.isEnabled = false
        self.addLocationTextButton.isEnabled = false
        self.save.isHidden = true
        self.autofillButton.isHidden = true
        textField.restorationIdentifier = "pick"
 
    }
 
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.locationTextEdit.endEditing(true)
        self.save.isEnabled = true
        self.save.isHidden = false
        self.locationTextEdit.isEnabled = true
        self.chooseDateTextButton.isEnabled = true
        self.autofillButton.isHidden = false
        self.locationTextHasChanged = true
        self.locationTextEdit.isHidden = false
        self.addLocationTextButton.isEnabled = true
        return true
        
    }
    
    // MARK: - Picker Functions
    
    @IBAction internal func openLocationPicker(_ sender: Any) {
        self.locationPicker.isHidden = false
        self.locationPicker.selectRow(self.findLocationStartRow(), inComponent: 0, animated: false)
        // other View changes
        self.autofillButton.isHidden = true
        self.autofillButton.isEnabled = false
        self.addLocationTextButton.isEnabled = false
        self.locationTextEdit.isEnabled = false
        self.chooseDateTextButton.isEnabled = false
        self.save.isHidden = true

    }

    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if UserDefaultsController.getDeliveryMethod() == PDStrings.deliveryMethods[0] {
            return PDStrings.patchLocationNames.count
        }
        else {
            return PDStrings.injectionLocationNames.count
        }
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if UserDefaultsController.getDeliveryMethod() == PDStrings.deliveryMethods[0] {
            return PDStrings.patchLocationNames[row]
        }
        return PDStrings.injectionLocationNames[row]
    }
    
    // Done
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let newLoc = (UserDefaultsController.getDeliveryMethod() == PDStrings.deliveryMethods[0]) ? PDStrings.patchLocationNames[row] : PDStrings.injectionLocationNames[row]
        self.locationTextEdit.text = newLoc
        self.location = newLoc
        // other view changes
        self.save.isEnabled = true
        self.save.isHidden = false
        self.locationPicker.isHidden = true
        self.autofillButton.isEnabled = true
        self.chooseDateTextButton.isEnabled = true
        self.addLocationTextButton.isEnabled = true
        self.locationTextEdit.isEnabled = true
        self.locationTextEdit.isHidden = false
        self.autofillButton.isHidden = false
        self.locationTextHasChanged = true
        
    }

    // MARK: - Date Picker funcs
    
    @IBAction internal func chooseDateTextTapped(_ sender: Any) {
        
        self.createDateAddSubview()
        // disable \ hide stuff
        self.autofillButton.isHidden = true
        self.chooseDateTextButton.isEnabled = false
        self.addLocationTextButton.isEnabled = false
        self.save.isHidden = true
        self.locationTextEdit.isEnabled = false
        
    }
    
    @objc internal func datePickerDone(sender: UIButton) {
        self.dateInputView.isHidden = true
        // disp date and time applied
        let d = self.datePicker.date
        self.datePlaced = d             // set temp
        self.chooseDateTextButton.setTitle(MOEstrogenDelivery.makeDateString(from: d, useWords: true), for: UIControlState.normal)
        if let expDate = MOEstrogenDelivery.expiredDate(fromDate: self.datePicker.date) {            // disp exp date
            self.expirationDateLabel.text = MOEstrogenDelivery.makeDateString(from: expDate, useWords: true)
        }
        // outer view changes
        self.save.isEnabled = true
        self.chooseDateTextButton.isEnabled = true
        self.addLocationTextButton.isEnabled = true
        self.autofillButton.isHidden = false
        self.save.isEnabled = true
        self.save.isHidden = false
        self.locationStackView.isHidden = false
        self.locationLabel.isHidden = false
        self.dateTextHasChanged = true
        self.locationTextEdit.isEnabled = true

    }
    
    // MARK: - private funcs
    
    private func displayAttributeTexts() {
        if let mo = ScheduleController.coreData.getMO(forIndex: self.reference - 1) {
            // location placed
            if mo.getLocation() != PDStrings.unplaced_string {
                // set location label text to patch's location
                let loc = mo.getLocation()              // set temp
                self.locationTextEdit.text = loc
                self.location = loc
            }
            // location not placed
            else {
                self.locationTextEdit.text = PDStrings.emptyLocationInstruction
            }
            // date placed
            if let date = mo.getdate() {
                // set date choose button's text to patch's date palced data
                self.datePlaced = date                  // set temp
                self.chooseDateTextButton.setTitle(MOEstrogenDelivery.makeDateString(from: date, useWords: true) , for: .normal)
                self.expirationDateLabel.text = mo.expirationDateAsString(timeInterval: UserDefaultsController.getTimeInterval(), useWords: true)
            }
            // date unplaced
            else {
                self.chooseDateTextButton.setTitle(PDStrings.emptyDate_placeholder
                    , for: UIControlState.normal)
            }
        }
        // nil patch
        else {
            self.locationTextEdit.text = PDStrings.emptyLocationInstruction
            self.chooseDateTextButton.setTitle(PDStrings.emptyDate_placeholder
                , for: UIControlState.normal)
        }
    }
    
    internal func setReference(to: Int) {
        self.reference = to
    }
    
    internal func getreference() -> Int {
        return self.reference
    }
    
    private func saveAttributes() {
        // save only if there are changes.
        if self.locationTextHasChanged {
            // current patch must exist since we are editing it
            guard let newLocation = self.locationTextEdit.text, newLocation != "" else {
                return
            }
            ScheduleController.coreData.setLocation(scheduleIndex: self.reference - 1, with: newLocation)
            // set values for ScheduleVC animation algorithm
            if !self.dateTextHasChanged {
                ScheduleController.onlyLocationChanged = true
            }
        }
        if self.dateTextHasChanged {
            ScheduleController.coreData.setDate(scheduleIndex: self.reference - 1, with: datePicker.date)
        }
        
    }
    
    private func autoPickLocation() {
        // "Suggest Patch Location" functionality is enabled...
        if UserDefaultsController.getSLF() {
            let suggestedLocation = SLF.suggest(scheduleIndex: self.reference - 1, generalLocations: ScheduleController.schedule().makeArrayOfLocations())
            self.locationTextEdit.text = suggestedLocation
        }
        // "Suggest Patch Location" functionality is disabled...
        else {
            self.locationTextEdit.text = "New Location"
        }
    }
    
    private func autoPickDate() {
        let now = Date()
        self.chooseDateTextButton.setTitle(MOEstrogenDelivery.makeDateString(from: now, useWords: true), for: .normal)
        if let expDate = MOEstrogenDelivery.expiredDate(fromDate: now) {
            self.expirationDateLabel.text = MOEstrogenDelivery.makeDateString(from: expDate, useWords: true)
        }
    }
    
    private func requestNotification() {
        // request notification iff exists Patch.date
        appDelegate.notificationsController.requestNotifyExpired(scheduleIndex: self.reference - 1)
    }
    
    private func cancelNotification() {
        appDelegate.notificationsController.cancelSchedule(index: self.reference - 1)
    }
    
    // MARK: - Private view creators / MOEstrogenDeliverydifiers
    
    private func findLocationStartRow() -> Int {
        var selected = 0
        let len = (UserDefaultsController.getDeliveryMethod() == PDStrings.deliveryMethods[0]) ? PDStrings.patchLocationNames.count : PDStrings.injectionLocationNames.count
        for i in 0...(len-1){
            let testLoc = (UserDefaultsController.getDeliveryMethod() == PDStrings.deliveryMethods[0]) ? PDStrings.patchLocationNames[i] : PDStrings.injectionLocationNames[i]
            if testLoc == self.location {
                    selected = i
                    break
                }
            }
        return selected
    }
    
    private func setExpirationAndHeading() {
        let interval = UserDefaultsController.getTimeInterval()
        var exp = ""
        if let patch = ScheduleController.coreData.getMO(forIndex: self.reference - 1) {            // unplaced patch instruction
            if patch.getLocation() == PDStrings.unplaced_string {
                exp = PDStrings.patchDetailsInstruction
            }
            else {
                if patch.isExpired(timeInterval: interval) {
                    self.expiresOrExpiredLabel.text = PDStrings.patchExpired_string
                }
                else {
                    self.expiresOrExpiredLabel.text = PDStrings.patchExpires_string
                }
                exp = patch.expirationDateAsString(timeInterval: interval, useWords: true)
            }
            self.expirationDateLabel.text = exp
        }
        else {
            exp = PDStrings.patchDetailsInstruction
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
    
    // for self.dateAddTapped()
    private func createDateAddSubview() {
        let inputView = self.makeInputViewForDatePicker()
        let datePickerView: UIDatePicker = self.makeDatePickerView()
        inputView.addSubview(datePickerView)
        let doneButton = self.makeDoneButton()
        inputView.addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(datePickerDone), for: UIControlEvents.touchUpInside)
        self.view.addSubview(inputView)
        
        // update members vars
        self.datePicker = datePickerView
        self.dateInputView = inputView
        
    }

    // lines
    private func hideLines() {
        self.lineUnderExpirationDate.isHidden = true
        self.lineUnderDateAndTimePlaced.isHidden = true
        self.lineUnderExpires.isHidden = true
        self.horizontalLineAboveLocation.isHidden = true
        self.horizontalLineBelowLocation.isHidden = true
        self.lineUnderdate.isHidden = true
    }
    
    // lines
    private func unhideLines() {
        self.lineUnderExpirationDate.isHidden = false
        self.lineUnderDateAndTimePlaced.isHidden = false
        self.lineUnderExpires.isHidden = false
        self.horizontalLineAboveLocation.isHidden = false
        self.horizontalLineBelowLocation.isHidden = false
        self.lineUnderdate.isHidden = false
    }

}
