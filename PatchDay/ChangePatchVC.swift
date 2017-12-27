//
//  ChangePatchVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class ChangePatchVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
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
    @IBOutlet private weak var changePatchButton: UIButton!
    
    // MOEstrogenDeliveryre location related
    @IBOutlet private weak var locationPicker: UIPickerView!
    
    // cosmetics
    @IBOutlet private weak var bigGap2: UIView!
    @IBOutlet private weak var bigGap: UIView!
    @IBOutlet private weak var headingLabel: UILabel!
    @IBOutlet private weak var lineUnderExpires: UIView!
    @IBOutlet private weak var lineUnderDateAndTimePlaced: UIView!
    @IBOutlet private weak var lineUnderdate: UIView!
    
    // reference to which patch it is (index in patches = reference - 1)
    internal var reference = 0
    
    // date picker vars
    private var dateInputView = UIView()
    private var datePicker = UIDatePicker()
    
    // bools
    private var locationTextHasChanged = false
    private var dateTextHasChanged = false
    
    @IBOutlet private weak var lineUnderExpirationDate: UIView!
    @IBOutlet private weak var dateAndTimePlaced: UILabel!
    
    override func viewDidLoad() {
        PDAlertController.currentVC = self
        super.viewDidLoad()
        view.backgroundColor = PDColors.pdPink
        self.save.isHidden = true
        self.setExpirationAndHeading()
        self.locationPicker.isHidden = true
        self.changePatchButton.setTitleColor(UIColor.darkGray, for: UIControlState.disabled)
        self.bigGap.backgroundColor = PDColors.pdPink
        self.bigGap2.backgroundColor = PDColors.pdPink
        
        // default texts
        self.displayAttributeTexts()
        
        // text editing delegate as self
        self.locationTextEdit.delegate = self

        // location picker set up
        self.locationPicker.delegate = self
        self.locationPicker.dataSource = self
        self.locationPicker.selectRow(self.findLocationStartRow(), inComponent: 0, animated: false)
    }
    
    // Save Button
    @IBAction private func hitSaveButton(_ sender: Any) {
        self.saveAttributes()
        self.requestNotifications()
        self.performSegue(withIdentifier: PDStrings.patchDetailsSegueID, sender: self)
        // lower badge number if patch was expired and it had a notification number
        if let patch = ScheduleController.getMO(index: self.reference - 1) {
            if patch.isExpired(timeInterval: SettingsDefaultsController.getTimeInterval()) && UIApplication.shared.applicationIconBadgeNumber > 0 {
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        }
    }
    
    @IBAction private func changePatchTapped(_ sender: Any) {
        // Location is a suggested by SLP's alg.,
        // Date is now.
        self.autoPickLocation()
        self.autoPickDate()
        // Enable save button
        self.save.isEnabled = true
        self.save.isHidden = false
        // Bools
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
        if textField.restorationIdentifier == "pick" {
            self.openLocationPicker(textField)
        }
        else if textField.restorationIdentifier == "type" {
            self.locationTextEdit.text = ""
            self.locationTextEdit.becomeFirstResponder()
        }
        self.chooseDateTextButton.isEnabled = false
        self.addLocationTextButton.isEnabled = false
        self.save.isHidden = true
        self.changePatchButton.isHidden = true
        textField.restorationIdentifier = "pick"
 
    }
 
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.locationTextEdit.endEditing(true)
        self.save.isEnabled = true
        self.save.isHidden = false
        self.locationTextEdit.isEnabled = true
        self.chooseDateTextButton.isEnabled = true
        self.changePatchButton.isHidden = false
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
        self.changePatchButton.isHidden = true
        self.changePatchButton.isEnabled = false
        self.addLocationTextButton.isEnabled = false
        self.locationTextEdit.isEnabled = false
        self.chooseDateTextButton.isEnabled = false
        self.save.isHidden = true

    }

    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PDStrings.locationNames.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PDStrings.locationNames[row]
    }
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.locationTextEdit.text = PDStrings.locationNames[row]
        // other view changes
        self.save.isEnabled = true
        self.save.isHidden = false
        self.locationPicker.isHidden = true
        self.changePatchButton.isEnabled = true
        self.chooseDateTextButton.isEnabled = true
        self.addLocationTextButton.isEnabled = true
        self.locationTextEdit.isEnabled = true
        self.locationTextEdit.isHidden = false
        self.changePatchButton.isHidden = false
        self.locationTextHasChanged = true
        
    }

    // MARK: - Date Picker funcs
    
    @IBAction internal func chooseDateTextTapped(_ sender: Any) {
        
        self.createDateAddSubview()
        // disable \ hide stuff
        self.changePatchButton.isHidden = true
        self.chooseDateTextButton.isEnabled = false
        self.addLocationTextButton.isEnabled = false
        self.save.isHidden = true
        self.locationTextEdit.isEnabled = false

    }
    
    @objc internal func datePickerDone(sender: UIButton) {
        self.dateInputView.isHidden = true
        // disp date and time placed
        self.chooseDateTextButton.setTitle(MOEstrogenDelivery.makeDateString(from: self.datePicker.date), for: UIControlState.normal)
        if let expDate = MOEstrogenDelivery.expiredDate(fromDate: self.datePicker.date) {            // disp exp date
            self.expirationDateLabel.text = MOEstrogenDelivery.makeDateString(from: expDate)
        }
        // outer view changes
        self.save.isEnabled = true
        self.chooseDateTextButton.isEnabled = true
        self.addLocationTextButton.isEnabled = true
        self.changePatchButton.isHidden = false
        self.save.isEnabled = true
        self.save.isHidden = false
        self.locationStackView.isHidden = false
        self.locationLabel.isHidden = false
        self.dateTextHasChanged = true
        self.locationTextEdit.isEnabled = true

    }
    
    // MARK: - private funcs
    
    private func displayAttributeTexts() {
        if let patch = ScheduleController.getMO(index: self.reference - 1) {
            // location placed
            if patch.getLocation() != PDStrings.unplaced_string {
                // set location label text to patch's location
                self.locationTextEdit.text = patch.getLocation()
            }
            // location not placed
            else {
                self.locationTextEdit.text = PDStrings.emptyLocationInstruction
            }
            // date placed
            if let date = patch.getdate() {
                // set date choose button's text to patch's date palced data
                self.chooseDateTextButton.setTitle(MOEstrogenDelivery.makeDateString(from: date) , for: .normal)
                self.expirationDateLabel.text = patch.expirationDateAsString(timeInterval: SettingsDefaultsController.getTimeInterval())
            }
            // date unplaced
            else {
                self.chooseDateTextButton.setTitle(PDStrings.emptyDateInstruction
                    , for: UIControlState.normal)
            }
        }
        // nil patch
        else {
            self.locationTextEdit.text = PDStrings.emptyLocationInstruction
            self.chooseDateTextButton.setTitle(PDStrings.emptyDateInstruction
                , for: UIControlState.normal)
        }
    }
    
    internal func setreference(to: Int) {
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
            ScheduleController.setLocation(scheduleIndex: self.reference - 1, with: newLocation)
        }
        if self.dateTextHasChanged {
            ScheduleController.setDate(scheduleIndex: self.reference - 1, with: datePicker.date)
        }
    }
    
    private func autoPickLocation() {
        // "Suggest Patch Location" functionality is enabled...
        if SettingsDefaultsController.getSLF() {
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
        self.chooseDateTextButton.setTitle(MOEstrogenDelivery.makeDateString(from: now), for: .normal)
        if let expDate = MOEstrogenDelivery.expiredDate(fromDate: now) {
            self.expirationDateLabel.text = MOEstrogenDelivery.makeDateString(from: expDate)
        }
    }
    
    private func requestNotifications() {
        // request notification iff exists Patch.date
        if let _ = ScheduleController.getMO(index: self.reference - 1) {
            (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyExpired(scheduleIndex: self.reference - 1)
            if SettingsDefaultsController.getRemindMeBefore() {
                (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyChangeSoon(scheduleIndex: self.reference - 1)
            }
        }
        
    }
    
    // MARK: - Private view creators / MOEstrogenDeliverydifiers
    
    private func findLocationStartRow() -> Int {
        var selected = 0
        let len = PDStrings.locationNames.count
        if let currentPatch = ScheduleController.getMO(index: self.reference - 1) {
            let currentLocation = currentPatch.getLocation()
            for i in 0...(len-1){
               // print(currentLocation)
                if PDStrings.locationNames[i] == currentLocation {
                    selected = i
                    break
                }
            }
        }
        return selected
    }
    
    private func setExpirationAndHeading() {
        let interval = SettingsDefaultsController.getTimeInterval()
        var exp = ""
        var heading = ""
        if let patch = ScheduleController.getMO(index: self.reference - 1) {            // unplaced patch instruction
            if patch.getLocation() == PDStrings.unplaced_string {
                exp = PDStrings.patchDetailsInstruction
                heading = PDStrings.addPatch_string
            }
            else {
                if patch.isExpired(timeInterval: interval) {
                    self.expiresOrExpiredLabel.text = PDStrings.patchExpired_string
                }
                else {
                    self.expiresOrExpiredLabel.text = PDStrings.patchExpires_string
                }
                exp = patch.expirationDateAsString(timeInterval: interval)
                heading = PDStrings.changePatch_string
            }
            self.expirationDateLabel.text = exp
            self.headingLabel.text = heading
        }
        else {
            exp = PDStrings.patchDetailsInstruction
            heading = PDStrings.addPatch_string
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
