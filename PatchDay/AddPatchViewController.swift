//
//  AddPatchViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class AddPatchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //MARK: - Main
    
    // main subview
    @IBOutlet var popUpView: UIView!
    
    // edit date and location buttons
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var addDateButton: UIButton!
    @IBOutlet weak var chooseDateTextButton: UIButton!
    
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
    @IBOutlet weak var patchLocationText: UITextField!
    
    // cosmetics
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var bigGap: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    
    // reference to which patch it is (index in patches = patchReference - 1)
    private var patchReferernce = 0
    
    // date picker vars
    private var dateInputView = UIView()
    private var datePicker = UIDatePicker()
    
    // bools
    private var locationTextHasChanged = false
    private var patchDateTextHasChanged = false
    
    override func viewDidLoad() {
        PDAlertController.currentVC = self
        self.patchLocationText.isUserInteractionEnabled = true
        super.viewDidLoad()
        self.setBackgroundColor(to: PatchDayColors.pdPink)
        self.setUpSaveButtonStart()
        self.setInstructionAndHeading()
        self.hideLocationPicker()
        self.patchLocationText.backgroundColor = PatchDayColors.pdPink
        self.autoChooseButton.setTitleColor(UIColor.darkGray, for: UIControlState.disabled)
        self.bigGap.backgroundColor = PatchDayColors.pdPink
        
        // default texts
        self.displayAttributeTexts()
        
        // text editing delegate as self
        self.patchLocationText.delegate = self
        
        // location picker set up
        self.locationPicker.delegate = self
        self.locationPicker.dataSource = self
    }
    
    // Save Button
    @IBAction func hitSaveButton(_ sender: Any) {
        self.saveSettings()
        self.requestNotifications()
        self.performSegue(withIdentifier: PatchDayStrings.addPatchSegueID, sender: self)
        // lower badge number if patch was expired and it had a notification number
        if let patch = PatchDataController.getPatch(forIndex: self.getPatchIndex()) {
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
        self.locationAndDateChanged()
        
    }
    
    // MARK: - Text Edit Functions
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.patchLocationText.isUserInteractionEnabled = true
        if textField.restorationIdentifier == "where" {
            self.patchLocationText.text = ""
        }
        self.patchLocationText.becomeFirstResponder()
        self.disablePatchDateButton()
        self.disablePatchDateTextButton()
        self.disableLocationButton()
        self.hideSaveButton()
        self.hideAutoButton()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.patchLocationText.endEditing(true)
        self.saveButtonLightUp()
        self.enableLocationText()
        self.enableLocationButton()
        self.enablePatchDateButton()
        self.enablePatchDateTextButton()
        self.unhideAutoButton()
        self.locationChanged()
        return true
        
    }
    
    // MARK: - Picker Functions
    
    @IBAction func openLocationPicker(_ sender: Any) {
        self.unhideLocationPicker()
        
        // other View changes
        self.hideAutoButton()
        self.disableAutoButton()
        self.disableLocationText()
        self.disablePatchDateButton()
        self.disablePatchDateTextButton()
        self.disableLocationButton()
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
        self.patchLocationText.text = PatchDayStrings.patchLocationNames[row]
        // other view changes
        self.saveButtonLightUp()
        self.hideLocationPicker()
        self.enableAutoButton()
        self.enableLocationButton()
        self.enablePatchDateTextButton()
        self.enablePatchDateButton()
        self.enableLocationText()
        self.unhideAutoButton()
        self.locationChanged()
        
    }

    // MARK: - Date Picker funcs
    
    @IBAction func chooseDateTextTapped(_ sender: Any) {
        
        self.createDateAddSubview()
        // disable \ hide stuff
        self.disableLocationButton()
        self.hideAutoButton()
        self.disablePatchDateButton()
        self.disablePatchDateTextButton()
        self.disableLocationText()
        self.hideSaveButton()
        self.hideLocationBar()

    }
    
    @IBAction func dateAddTapped(_ sender: Any) {
        
        self.createDateAddSubview()
        
        // disable \ hide stuff
        self.disableLocationButton()
        self.hideAutoButton()
        self.disablePatchDateTextButton()
        self.disablePatchDateButton()
        self.disableLocationText()
        self.hideSaveButton()
        self.hideLocationBar()
        
    }
    
    func datePickerDone(sender: UIButton) {
        self.dateInputView.isHidden = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        self.chooseDateTextButton.setTitle(dateFormatter.string(from: self.datePicker.date), for: UIControlState.normal)
        // update patch attribute in core data

        // outer view changes
        self.enableSaveButton()
        self.enablePatchDateButton()
        self.enablePatchDateTextButton()
        self.enableLocationButton()
        self.enableLocationText()
        self.unhideAutoButton()
        self.saveButtonLightUp()
        self.unhideLocationBar()
        self.dateChanged()

    }
    
    private func displayAttributeTexts() {
        if let patch = PatchDataController.getPatch(forIndex: self.getPatchIndex()) {
            // location placed
            if patch.getLocation() != PatchDayStrings.unplaced_string {
                // set location label text to patch's location
                self.patchLocationText.text = patch.getLocation()
            }
            // location not placed
            else {
                self.patchLocationText.text = PatchDayStrings.emptyLocationInstruction
            }
            // date placed
            if let datePlaced = patch.getDatePlaced() {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                // set date choose button's text to patch's date palced data
                self.chooseDateTextButton.setTitle(dateFormatter.string(from: datePlaced) , for: .normal)
            }
            // date unplaced
            else {
                self.chooseDateTextButton.setTitle(PatchDayStrings.emptyDateInstruction
                    , for: UIControlState.normal)
            }
        }
        // nil patch
        else {
            self.patchLocationText.text = PatchDayStrings.emptyLocationInstruction
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
        if self.save.backgroundImage(for: .normal) != PatchDayImages.save {
            self.save.setBackgroundImage(PatchDayImages.save, for: .normal)
        }
    }
    
    public func saveSettings() {
        if self.locationTextHasChanged {
            // current patch must exist since we are editing it
            guard let newLocation = self.patchLocationText.text, newLocation != "" else {
                return
            }
            PatchDataController.setPatchLocation(patchIndex: self.getPatchIndex(), with: newLocation)
        }
        if self.patchDateTextHasChanged {
            PatchDataController.setPatchDate(patchIndex: self.getPatchIndex(), with: datePicker.date)
        }
        PatchDataController.saveContext()
    }
    
    public func autoPickLocation() {
        let suggestedLocation = SuggestedPatchLocation.suggest(patchIndex: self.getPatchIndex())
        self.patchLocationText.text = suggestedLocation
    }
    
    public func autoPickDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let now = Date()
        self.chooseDateTextButton.setTitle(dateFormatter.string(from: now), for: .normal)
    }
    
    public func autoPickLocationAndDate() {
        self.autoPickLocation()
        self.autoPickDate()
    }
    
    public func requestNotifications() {
        let patch = PatchDataController.getPatch(forIndex: self.getPatchIndex())
        // request notification iff exists Patch.datePlaced
        if patch?.getDatePlaced() != nil {
            (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyExpiredAndChangeSoon(patchIndex: self.getPatchIndex())
        }
    }
    
    // MARK: - Private view creators
    
    private func setInstructionAndHeading() {
        var instruction = ""
        var heading = ""
        if let patch = PatchDataController.getPatch(forIndex: self.getPatchIndex()) {            // unplaced patch instruction
            if patch.getLocation() == PatchDayStrings.unplaced_string {
                instruction = PatchDayStrings.addPatchInstruction
                heading = PatchDayStrings.addPatch_string
            }
            else {
                if patch.isExpired() {
                    instruction = PatchDayStrings.patchExpired_string
                }
                else {
                    instruction = PatchDayStrings.patchExpires_string
                }
                instruction += patch.expirationDateAsString()
                heading = PatchDayStrings.changePatch_string
            
            }
            self.instructionLabel.text = instruction
            self.headingLabel.text = heading
        }
        else {
            instruction = PatchDayStrings.addPatchInstruction
            heading = PatchDayStrings.addPatch_string
        }
    }
    
    // for self.createDateAddSubview() self.dateAddTapped()
    private func makeInputViewForDatePicker() -> UIView {
        let viewPoint = CGPoint(x: 0, y: self.view.frame.height/2)
        let viewSize = CGSize(width: self.view.frame.width, height: 240)
        let viewRect = CGRect(origin: viewPoint, size: viewSize)
        return UIView(frame: viewRect)
        
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
        let donePoint = CGPoint(x: (self.view.frame.size.width/2) - (100/2), y: 0)
        let doneSize = CGSize(width: 100, height: 50)
        let doneRect = CGRect(origin: donePoint, size: doneSize)
        let doneButton = UIButton(frame: doneRect)
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        return doneButton
        
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
    
    private func setUpSaveButtonStart() {
        self.disableSaveButton()
        self.save.setBackgroundImage(#imageLiteral(resourceName: "SaveDisabled"), for: .disabled)
        
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
    
    // location
    private func disableLocationButton() {
        if self.addLocationButton.isEnabled {
            self.addLocationButton.isEnabled = false
        }
        
    }
    
    //auto
    private func disableAutoButton() {
        if self.autoChooseButton.isEnabled {
            self.autoChooseButton.isEnabled = false
        }
    }
    
    // patch date
    private func disablePatchDateButton() {
        if self.addDateButton.isEnabled {
            self.addDateButton.isEnabled = false
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
        if self.patchLocationText.isEnabled {
            self.patchLocationText.isEnabled = false
        }
    }
    
    // MARK: HIDING
    
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
    
    // location bar
    private func hideLocationBar() {
        if !self.horizontalLineBelowLocation.isHidden {
            self.horizontalLineBelowLocation.isHidden = true
        }
        if !self.horizontalLineAboveLocation.isHidden {
            self.horizontalLineAboveLocation.isHidden = true
        }
        if !self.locationLabel.isHidden {
            self.locationLabel.isHidden = true
        }
        if !self.locationStackView.isHidden {
            self.locationStackView.isHidden = true
        }
        
    }
    
    // MARK: ENABLING
    
    // location
    private func enableLocationButton() {
        if !self.addLocationButton.isEnabled {
            self.addLocationButton.isEnabled = true
        }
    }
    
    // auto
    private func enableAutoButton() {
        if !self.autoChooseButton.isEnabled {
            self.autoChooseButton.isEnabled = true
        }
    }
    
    // patch date
    private func enablePatchDateButton() {
        if !self.addDateButton.isEnabled {
            self.addDateButton.isEnabled = true
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
        if !self.patchLocationText.isEnabled {
            self.patchLocationText.isEnabled = true
        }
    }
    
    // MARK: UNHIDING
    
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
    
    // location bar
    private func unhideLocationBar() {
        if self.locationStackView.isHidden {
            self.locationStackView.isHidden = false
        }
        if self.locationLabel.isHidden {
            self.locationLabel.isHidden = false
        }
        if self.horizontalLineAboveLocation.isHidden {
            self.horizontalLineAboveLocation.isHidden = false
        }
        if self.horizontalLineBelowLocation.isHidden {
            self.horizontalLineBelowLocation.isHidden = false
        }
    }

}
