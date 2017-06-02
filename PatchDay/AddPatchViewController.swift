//
//  AddPatchViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class AddPatchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // main subview
    @IBOutlet var popUpView: UIView!
    
    // edit date and location buttons
    @IBOutlet var addLocationButton: UIButton!
    @IBOutlet var addDateButton: UIButton!
    @IBOutlet var chooseDateTextButton: UIButton!
    
    @IBOutlet var horizontalLineBelowLocation: UIView!
    // Location bar
    @IBOutlet var horizontalLineAboveLocation: UIView!
    @IBOutlet var locationStackView: UIStackView!
    @IBOutlet var locationLabel: UILabel!

    // save, auto choose
    @IBOutlet var save: UIButton!
    @IBOutlet var autoChooseButton: UIButton!
    
    // more location related
    @IBOutlet var locationPicker: UIPickerView!
    @IBOutlet var patchLocationText: UITextField!
    
    // cosmetics
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var bigGap: UIView!
    
    // date picker vars
    private var dateInputView = UIView()
    private var datePicker = UIDatePicker()
    
    var defaultLocations = ["Right Buttock", "Left Buttock", "Right Stomach", "Left Stomach"]
    
    let savePatchImage: UIImage = #imageLiteral(resourceName: "Save")
    
    let savePatchImageDisabled: UIImage = #imageLiteral(resourceName: "SaveDisabled")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackgroundColor(to: PatchDayColors.pdPink)
        self.setUpSaveButtonStart()
        self.setInstruction()
        self.hideLocationPicker()
        self.patchLocationText.backgroundColor = PatchDayColors.pdPink
        self.autoChooseButton.setTitleColor(UIColor.darkGray, for: UIControlState.disabled)
        self.bigGap.backgroundColor = PatchDayColors.pdPink
        self.chooseDateTextButton.titleLabel!.sizeToFit()
        
        // default texts
        self.chooseDateTextButton.setTitle("choose ⇢                            "
            , for: UIControlState.normal)
        self.patchLocationText.text = "⌨ custom or choose ⇢"
        
        // text editing delegate as self
        self.patchLocationText.delegate = self
        
        // location picker set up
        self.locationPicker.delegate = self
        self.locationPicker.dataSource = self
        
    }
    
    // Save Button
    
    @IBAction func hitSaveButton(_ sender: Any) {
        self.performSegue(withIdentifier: "idAddPatchSegue", sender: self)
        
    }
    
    // Text Edit Functions
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.restorationIdentifier == "where" {
            self.patchLocationText.text = ""
        }
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
        return true
        
    }
    
    // END Text Edit Functions

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Picker Functions
    
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
        return self.defaultLocations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.defaultLocations[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.patchLocationText.text = self.defaultLocations[row]
        
        // other view changes
        self.saveButtonLightUp()
        self.hideLocationPicker()
        self.enableAutoButton()
        self.enableLocationButton()
        self.enablePatchDateTextButton()
        self.enablePatchDateButton()
        self.enableLocationText()
        self.unhideAutoButton()
        
    }
    
    // END Picker funcs
    
    // Date Picker funcs
    
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
        self.chooseDateTextButton.titleLabel!.text = dateFormatter.string(from: self.datePicker.date)

        // outer view changes
        self.enableSaveButton()
        self.enablePatchDateButton()
        self.enablePatchDateTextButton()
        self.enableLocationButton()
        self.enableLocationText()
        self.unhideAutoButton()
        self.saveButtonLightUp()
        self.unhideLocationBar()

    }
    
    
    // END Date Picker funcs
    
    func setBackgroundColor(to: UIColor) {
        view.backgroundColor = to
        
    }
    
    func setInstruction() {
        let instruction = "Edit when and where " +
        "the patch was placed"
        self.instructionLabel.text = instruction
        
    }
    
    // enables the save button and lights it up
    func saveButtonLightUp() {
        self.enableSaveButton()
        self.unhideSaveButton()
        if self.save.backgroundImage(for: .normal) != self.savePatchImage {
            self.save.setBackgroundImage(self.savePatchImage, for: .normal)
        }
    }
    
    func setUpSaveButtonStart() {
        self.disableSaveButton()
        self.save.setBackgroundImage(self.savePatchImageDisabled, for: .disabled)
        
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
    
    // MARK: getters and setters
    
    private func getDateInputView() -> UIView {
        return self.dateInputView
    }
    
    private func getDatePicker() -> UIDatePicker {
        return self.datePicker
    }
    
    private func setDateInputView(with: UIView) {
        self.dateInputView = with
    }
    
    private func setDatePicker(with: UIDatePicker) {
        self.datePicker = with
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
