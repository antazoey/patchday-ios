//
//  PatchDetailsViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class PatchDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //MARK: - Main
    
    // main subview
    @IBOutlet var popUpView: UIView!
    
    // edit date and location buttons

    @IBOutlet var locationTextEdit: UITextField!
    
    @IBOutlet weak var chooseDateTextButton: UIButton!
    @IBOutlet var addLocationTextButton: UIButton!
    
    @IBOutlet var expiresOrExpiredLabel: UILabel!
    
    @IBOutlet var expirationDateLabel: UILabel!
    
    @IBOutlet var horizontalLineBelowLocation: UIView!
    // Location bar
    @IBOutlet weak var horizontalLineAboveLocation: UIView!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!

    // save, auto choose
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var autoChooseButton: UIButton!
    
    // more location related
    @IBOutlet weak var locationPicker: UIPickerView!
    
    // cosmetics
    @IBOutlet var bigGap2: UIView!
    @IBOutlet weak var bigGap: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet var lineUnderExpires: UIView!
    @IBOutlet var lineUnderDateAndTimePlaced: UIView!
    @IBOutlet var lineUnderDatePlaced: UIView!
    
    // reference to which patch it is (index in patches = patchReference - 1)
    private var patchReferernce = 0
    
    // date picker vars
    private var dateInputView = UIView()
    private var datePicker = UIDatePicker()
    
    // bools
    private var locationTextHasChanged = false
    private var patchDateTextHasChanged = false
    
    @IBOutlet var lineUnderExpirationDate: UIView!
    @IBOutlet var dateAndTimePlaced: UILabel!
    
    override func viewDidLoad() {
        PDAlertController.currentVC = self
        super.viewDidLoad()
        self.setBackgroundColor(to: PatchDayColors.pdPink)
        self.hideSaveButton()
        self.setExpirationAndHeading()
        self.hideLocationPicker()
        self.autoChooseButton.setTitleColor(UIColor.darkGray, for: UIControlState.disabled)
        self.bigGap.backgroundColor = PatchDayColors.pdPink
        self.bigGap2.backgroundColor = PatchDayColors.pdPink
        
        // default texts
        self.displayAttributeTexts()
        
        // text editing delegate as self
        self.locationTextEdit.delegate = self

 
        // location picker set up
        self.locationPicker.delegate = self
        self.locationPicker.dataSource = self
    }
    
    // Save Button
    @IBAction func hitSaveButton(_ sender: Any) {
        self.saveAttributes()
        self.requestNotifications()
        self.performSegue(withIdentifier: PatchDayStrings.patchDetailsSegueID, sender: self)
        // lower badge number if patch was expired and it had a notification number
        if let patch = PatchDataController.getPatch(index: self.getPatchIndex()) {
            if patch.isExpired() && UIApplication.shared.applicationIconBadgeNumber > 0 {
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        }
    }
    
    @IBAction func autoTapped(_ sender: Any) {
        // Location is a suggested by SuggedPatchLocation's algorithm,
        // Date is now.
        self.autoPickLocationAndDate()
        // Enable save button
        self.saveButtonLightUp()
        // Bools
        self.dateChanged()
        if SettingsDefaultsController.getAutoChooseLocation() {
            self.locationChanged()
        }
        
    }
    
    
    // MARK: - Text Edit Functions
    
    @IBAction func keyboardTapped(_ sender: Any) {
        self.locationTextEdit.restorationIdentifier = "type"
        self.locationTextEdit.becomeFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.locationTextEdit.isUserInteractionEnabled = true
        if textField.restorationIdentifier == "pick" {
            self.openLocationPicker(textField)
        }
        else if textField.restorationIdentifier == "type" {
            self.locationTextEdit.text = ""
            self.locationTextEdit.becomeFirstResponder()
        }
        self.disablePatchDateTextButton()
        self.disableLocationText()
        self.hideSaveButton()
        self.hideAutoButton()
        textField.restorationIdentifier = "pick"
 
    }
 
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.locationTextEdit.endEditing(true)
        self.saveButtonLightUp()
        self.enableLocationTextEdit()
        self.enablePatchDateTextButton()
        self.unhideAutoButton()
        self.locationChanged()
        self.unhideLocationTextbutton()
        self.enableLocationText()
        return true
        
    }
    
    // MARK: - Picker Functions
    
    @IBAction func openLocationPicker(_ sender: Any) {
        self.unhideLocationPicker()
        
        // other View changes
        self.hideAutoButton()
        self.disableAutoButton()
        self.disableLocationText()
        self.disableLocationTextEdit()
        self.disablePatchDateTextButton()
        self.hideSaveButton()

    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PatchDayStrings.patchLocationNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PatchDayStrings.patchLocationNames[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.locationTextEdit.text = PatchDayStrings.patchLocationNames[row]
        // other view changes
        self.saveButtonLightUp()
        self.hideLocationPicker()
        self.enableAutoButton()
        self.enablePatchDateTextButton()
        self.enableLocationText()
        self.enableLocationTextEdit()
        self.unhideLocationTextbutton()
        self.unhideAutoButton()
        self.locationChanged()
        
    }

    // MARK: - Date Picker funcs
    
    @IBAction func chooseDateTextTapped(_ sender: Any) {
        
        self.createDateAddSubview()
        // disable \ hide stuff
        self.hideAutoButton()
        self.disablePatchDateTextButton()
        self.disableLocationText()
        self.hideSaveButton()
        self.disableLocationTextEdit()

    }
    
    func datePickerDone(sender: UIButton) {
        self.dateInputView.isHidden = true
        // set date and time placed on screen
        self.chooseDateTextButton.setTitle(Patch.makeDateString(from: self.datePicker.date), for: UIControlState.normal)
        // set exp date and time on screen
        self.expirationDateLabel.text = Patch.makeDateString(from: Patch.expiredDate(fromDate: self.datePicker.date))

        // outer view changes
        self.enableSaveButton()
        self.enablePatchDateTextButton()
        self.enableLocationText()
        self.unhideAutoButton()
        self.saveButtonLightUp()
        self.unhideLocationBar()
        self.dateChanged()
        self.enableLocationTextEdit()

    }
    
    private func displayAttributeTexts() {
        if let patch = PatchDataController.getPatch(index: self.getPatchIndex()) {
            // location placed
            if patch.getLocation() != PatchDayStrings.unplaced_string {
                // set location label text to patch's location
                self.locationTextEdit.text = patch.getLocation()
            }
            // location not placed
            else {
                self.locationTextEdit.text = PatchDayStrings.emptyLocationInstruction
            }
            // date placed
            if let datePlaced = patch.getDatePlaced() {
                // set date choose button's text to patch's date palced data
                self.chooseDateTextButton.setTitle(Patch.makeDateString(from: datePlaced) , for: .normal)
                self.expirationDateLabel.text = patch.expirationDateAsString()
            }
            // date unplaced
            else {
                self.chooseDateTextButton.setTitle(PatchDayStrings.emptyDateInstruction
                    , for: UIControlState.normal)
            }
        }
        // nil patch
        else {
            self.locationTextEdit.text = PatchDayStrings.emptyLocationInstruction
            self.chooseDateTextButton.setTitle(PatchDayStrings.emptyDateInstruction
                , for: UIControlState.normal)
        }
    }
    
    // MARK: -- public
    public func setPatchReference(to: Int) {
        self.patchReferernce = to
    }
    
    public func getPatchReference() -> Int {
        return self.patchReferernce
    }
    
    // enables the save button and lights it up
    public func saveButtonLightUp() {
        self.enableSaveButton()
        self.unhideSaveButton()
    }
    
    public func saveAttributes() {
        if self.locationTextHasChanged {
            // current patch must exist since we are editing it
            guard let newLocation = self.locationTextEdit.text, newLocation != "" else {
                return
            }
            PatchDataController.setPatchLocation(patchIndex: self.getPatchIndex(), with: newLocation)
        }
        if self.patchDateTextHasChanged {
            PatchDataController.setPatchDate(patchIndex: self.getPatchIndex(), with: datePicker.date)
        }
        PatchDataController.save()
    }
    
    public func autoPickLocation() {
        if SettingsDefaultsController.getAutoChooseLocation() {
            let suggestedLocation = SuggestedPatchLocation.suggest(patchIndex: self.getPatchIndex())
            self.locationTextEdit.text = suggestedLocation
        }
        else {
            self.locationTextEdit.text = ""
        }
    }
    
    public func autoPickDate() {
        let now = Date()
        self.chooseDateTextButton.setTitle(Patch.makeDateString(from: now), for: .normal)
        let expDate = Patch.expiredDate(fromDate: now)
        self.expirationDateLabel.text = Patch.makeDateString(from: expDate)
    }
    
    public func autoPickLocationAndDate() {
        self.autoPickLocation()
        self.autoPickDate()
    }
    
    public func requestNotifications() {
        // request notification iff exists Patch.datePlaced
        if let _ = PatchDataController.getPatch(index: self.getPatchIndex()) {
            (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyExpired(patchIndex: self.getPatchIndex())
            if SettingsDefaultsController.getRemindMe() {
                (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyChangeSoon(patchIndex: self.getPatchIndex())
            }
        }
        
    }
    
    // MARK: - Private view creators
    
    private func setExpirationAndHeading() {
        var exp = ""
        var heading = ""
        if let patch = PatchDataController.getPatch(index: self.getPatchIndex()) {            // unplaced patch instruction
            if patch.getLocation() == PatchDayStrings.unplaced_string {
                exp = PatchDayStrings.patchDetailsInstruction
                heading = PatchDayStrings.addPatch_string
            }
            else {
                if patch.isExpired() {
                    self.expiresOrExpiredLabel.text = PatchDayStrings.patchExpired_string
                }
                else {
                    self.expiresOrExpiredLabel.text = PatchDayStrings.patchExpires_string
                }
                exp = patch.expirationDateAsString()
                heading = PatchDayStrings.changePatch_string
            }
            self.expirationDateLabel.text = exp
            self.headingLabel.text = heading
        }
        else {
            exp = PatchDayStrings.patchDetailsInstruction
            heading = PatchDayStrings.addPatch_string
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
    private func configureDatePickerStartX() -> CGFloat {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
            return 0
        }
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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
            return (self.view.frame.size.width/2) - 50
        }
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
        self.setDatePicker(with: datePickerView)
        self.setDateInputView(with: inputView)
        
    }
    
    private func testAlert() {
        PDAlertController.alertForCoreDataSaveError()
    }
    
    // MARK: private getters and setters
    
    private func getDateInputView() -> UIView {
        return self.dateInputView
    }
    
    private func getDatePicker() -> UIDatePicker {
        return self.datePicker
    }
    
    private func getPatchIndex() -> Int {
        return patchReferernce - 1
    }
    
    private func setDateInputView(with: UIView) {
        self.dateInputView = with
    }
    
    private func setDatePicker(with: UIDatePicker) {
        self.datePicker = with
    }
    
    private func setBackgroundColor(to: UIColor) {
        view.backgroundColor = to
    }
    
    // MARK: - private bool functions
    
    private func locationChanged() {
        self.locationTextHasChanged = true
    }
    
    private func dateChanged() {
        self.patchDateTextHasChanged = true
    }
    
    private func locationAndDateChanged() {
        self.locationChanged()
        self.dateChanged()
    }
    
    // MARK: DISABLING
    
    //auto
    private func disableAutoButton() {
        if self.autoChooseButton.isEnabled {
            self.autoChooseButton.isEnabled = false
        }
    }
    
    // patch date text
    private func disablePatchDateTextButton() {
        if self.chooseDateTextButton.isEnabled {
            self.chooseDateTextButton.isEnabled = false
        }
    }
    
    // save
    private func disableSaveButton() {
        if self.save.isEnabled {
            self.save.isEnabled = false
        }
    }
    
    // location text
    private func disableLocationText() {
        if self.addLocationTextButton.isEnabled {
            self.addLocationTextButton.isEnabled = false
        }
    }
    
    private func disableLocationTextEdit() {
        if self.locationTextEdit.isEnabled {
            self.locationTextEdit.isEnabled = false
        }
    }
    
    // MARK: HIDING
    
    // date
    private func hideDatePlaced() {
        if !self.chooseDateTextButton.isHidden {
            self.chooseDateTextButton.isHidden = true
        }
    }
    
    // auto
    private func hideAutoButton() {
        if !self.autoChooseButton.isHidden {
            self.autoChooseButton.isHidden = true
        }
    }
    
    // location picker
    private func hideLocationPicker() {
        if !self.locationPicker.isHidden {
            self.locationPicker.isHidden = true
        }
    }
    
    // save
    private func hideSaveButton() {
        if !self.save.isHidden {
            self.save.isHidden = true
        }
    }
    
    // gaps
    
    private func hideGaps() {
        if !self.bigGap.isHidden {
            self.bigGap.isHidden = true
        }
        if !self.bigGap2.isHidden {
            self.bigGap2.isHidden = true
        }
    }
    
    private func hideLines() {
        if !self.lineUnderExpirationDate.isHidden {
            self.lineUnderExpirationDate.isHidden = true
        }
        if !self.lineUnderDateAndTimePlaced.isHidden {
            self.lineUnderDateAndTimePlaced.isHidden = true
        }
        if !self.lineUnderExpires.isHidden {
            self.lineUnderExpires.isHidden = true
        }
        if !self.horizontalLineAboveLocation.isHidden {
            self.horizontalLineAboveLocation.isHidden = true
        }
        if !self.horizontalLineBelowLocation.isHidden {
            self.horizontalLineBelowLocation.isHidden = true
        }
        if !self.lineUnderDatePlaced.isHidden {
            self.lineUnderDatePlaced.isHidden = true
        }
        
    }
    
    // location bar
    private func hideLocationBar() {
        if !self.locationLabel.isHidden {
            self.locationLabel.isHidden = true
        }
        if !self.locationStackView.isHidden {
            self.locationStackView.isHidden = true
        }
        
    }
    
    private func hideExpDate() {
        if !self.expirationDateLabel.isHidden {
            self.expirationDateLabel.isHidden = true
        }
        if !self.expiresOrExpiredLabel.isHidden {
            self.expiresOrExpiredLabel.isHidden =  true
        }
    }
    
    private func hideLocText() {
        if !self.locationTextEdit.isHidden {
            self.locationTextEdit.isHidden = true
        }
    }
    
    // MARK: ENABLING
    
    // auto
    private func enableAutoButton() {
        if !self.autoChooseButton.isEnabled {
            self.autoChooseButton.isEnabled = true
        }
    }
    
    // patch date text
    private func enablePatchDateTextButton() {
        if !self.chooseDateTextButton.isEnabled {
            self.chooseDateTextButton.isEnabled = true
        }
    }
    
    // save
    private func enableSaveButton() {
        if !self.save.isEnabled {
            self.save.isEnabled = true
        }
    }
    
    // location text
    private func enableLocationText() {
        if !self.addLocationTextButton.isEnabled {
            self.addLocationTextButton.isEnabled = true
        }
    }
    
    private func enableLocationTextEdit() {
        if !self.locationTextEdit.isEnabled {
            self.locationTextEdit.isEnabled = true
        }
    }
    
    // MARK: UNHIDING
    
    // date
    
    private func unhideDatePlaced() {
        if self.chooseDateTextButton.isHidden {
            self.chooseDateTextButton.isHidden = false
        }
    }
    
    // auto
    private func unhideAutoButton() {
        if self.autoChooseButton.isHidden {
            self.autoChooseButton.isHidden = false
        }
    }
    
    // location picker
    private func unhideLocationPicker() {
        if self.locationPicker.isHidden {
            self.locationPicker.isHidden = false
        }
    }
    
    // save
    private func unhideSaveButton() {
        if self.save.isHidden {
            self.save.isHidden = false
        }
    }
    
    // gaps
    
    private func unhideGaps() {
        if self.bigGap.isHidden {
            self.bigGap.isHidden = false
        }
        if self.bigGap2.isHidden {
            self.bigGap2.isHidden = false
        }
    }
    
    private func unhideLines() {
        if self.lineUnderExpirationDate.isHidden {
            self.lineUnderExpirationDate.isHidden = false
        }
        if self.lineUnderDateAndTimePlaced.isHidden {
            self.lineUnderDateAndTimePlaced.isHidden = false
        }
        if self.lineUnderExpires.isHidden {
            self.lineUnderExpires.isHidden = false
        }
        if self.horizontalLineAboveLocation.isHidden {
            self.horizontalLineAboveLocation.isHidden = false
        }
        if self.horizontalLineBelowLocation.isHidden {
            self.horizontalLineBelowLocation.isHidden = false
        }
        if self.lineUnderDatePlaced.isHidden {
            self.lineUnderDatePlaced.isHidden = false
        }
        
    }
    
    private func unhideExpDate() {
        if self.expirationDateLabel.isHidden {
            self.expirationDateLabel.isHidden = false
        }
        if self.expiresOrExpiredLabel.isHidden {
            self.expiresOrExpiredLabel.isHidden = false
        }
    }
    
    // location bar
    private func unhideLocationBar() {
        if self.locationStackView.isHidden {
            self.locationStackView.isHidden = false
        }
        if self.locationLabel.isHidden {
            self.locationLabel.isHidden = false
        }
    }
    
    
    // loc text edit
    private func unhideLocationTextbutton() {
        if self.locationTextEdit.isHidden {
            self.locationTextEdit.isHidden = false
        }
    }

}
