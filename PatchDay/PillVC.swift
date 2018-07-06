//
//  PillVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/28/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PillVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var selectNameButton: UIButton!
    @IBOutlet weak var namePicker: UIPickerView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var timesadaySlider: UISlider!
    @IBOutlet weak var time1Button: UIButton!
    @IBOutlet weak var time2Button: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var takeButton: UIButton!
    
    private var pillIndex: Index?
    private var pill: MOPill?
    private var names = PDStrings.PillTypes.defaultPills + PDStrings.PillTypes.extraPills
    
    private var name: String?
    private var nameSelected: String?
    private var timesadaySelected: Int?
    private var time1Selected: Time?
    private var time2Selected: Time?
    private var notifySelected: Bool?
    private var nameChanged: Bool = false
    private var timesadayChanged: Bool = false
    private var time1Changed: Bool = false
    private var time2Changed: Bool = false
    private var notifyChanged: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        namePicker.delegate = self
        namePicker.delegate = self
        nameTextField.delegate = self
        
        // UI States
        selectNameButton.setTitleColor(UIColor.lightGray, for: .disabled)
        selectNameButton.addTarget(self, action: #selector(selectNameTapped), for: .touchUpInside)
        timesadaySlider.maximumValue = 4.0
        timesadaySlider.minimumValue = 0.0
        time1Button.setTitleColor(UIColor.lightGray, for: .disabled)
        time2Button.setTitleColor(UIColor.lightGray, for: .disabled)
        time1Button.addTarget(self, action: #selector(time1ButtonTapped(_:)), for: .touchUpInside)
        time2Button.addTarget(self, action: #selector(time2ButtonTapped(_:)), for: .touchUpInside)
        time1Button.setTitle(PDStrings.ActionStrings.done, for: .selected)
        time2Button.setTitle(PDStrings.ActionStrings.done, for: .selected)
        time1Button.setTitleColor(UIColor.blue, for: .selected)
        time2Button.setTitleColor(UIColor.blue, for: .selected)
        disableSavebutton()
        reflectPillAttributes()
        fixPillTimes(shouldSave: true)
        loadVCTitle()
    }
    
    public func setPill(_ pill: MOPill) {
        self.pill = pill
    }
    
    public func setPillIndex(_ index: Index) {
        pillIndex = index
    }
    
    // MARK: -- Pill actions
    
    @objc func selectNameTapped() {
        openOrCloseNamePicker(closing: false)
        selectNameButton.setTitle(PDStrings.ActionStrings.done, for: .normal)
        selectNameButton.addTarget(self, action: #selector(doneWithSelectNameTapped), for: .touchUpInside)
    }
    
    @objc func doneWithSelectNameTapped() {
        openOrCloseNamePicker(closing: true)
        selectNameButton.setTitle(PDStrings.ActionStrings.select, for: .normal)
        selectNameButton.addTarget(self, action: #selector(selectNameTapped), for: .touchUpInside)
        if name != nameSelected {
            nameChanged = true
            enableSaveButton()
        }
    }
    
    @IBAction func saveButtonTapped() {
        if let pill = pill {
            PillDataController.setPillAttributes(for: pill, with: makePillAttributes())
            segueToPillsVC()
        }
    }
    
    @IBAction func notificationSwitched(_ sender: Any) {
        let notifySwitch = sender as! UISwitch
        notifySelected = notifySwitch.isOn
        notifyChanged = true
        enableSaveButton()
    }
    
    @IBAction func timesadaySliderValueChanged(_ sender: Any) {
        let slider = sender as! UISlider
        timesadayChanged = true
        if slider.value >= 2 {
            enableTime2()
            timesadaySelected = 2
        }
        else {
            disableTime2()
            timesadaySelected = 1
        }
        enableSaveButton()
    }
    
    // MARK: - Time picker actions
    
    private func disableNonTimeInteractions() {
        timesadaySlider.isEnabled = false
        selectNameButton.isEnabled = false
        nameTextField.isEnabled = false
    }

    @objc func time1ButtonTapped(_ sender: Any) {
        timePicker.isHidden = false
        transformIntoDoneButton(time1Button)
        disableNonTimeInteractions()
        if time2Button.isEnabled, let pill = pill, let time1 = pill.getTime1() {
            timePicker.date = time1 as Date
            timePicker.maximumDate = time2Selected
            timePicker.minimumDate = nil
        }
        time2Button.isEnabled = false
    }
    
    @objc func time2ButtonTapped(_ sender: Any) {
        timePicker.isHidden = false
        transformIntoDoneButton(time2Button)
        disableNonTimeInteractions()
        time1Button.isEnabled = false
        if let pill = pill, let time2 = pill.getTime2() {
            timePicker.date = time2 as Date
            timePicker.minimumDate = time1Selected
            timePicker.maximumDate = nil
        }
        time1Button.isEnabled = false
    }
    
    private func transformIntoDoneButton(_ button: UIButton) {
        button.isSelected = true
        button.addTarget(self, action: #selector(timePickerDone(sender:)), for: .touchUpInside)
    }
    
    @objc internal func timePickerDone(sender: Any) {
        let timeButton = sender as! UIButton
        timeButton.isSelected = false
        timePicker.isHidden = true
        let selectedTime = timePicker.date
        timeButton.setTitle(PDDateHelper.format(time: selectedTime), for: .normal)
        timesadaySlider.isEnabled = true
        selectNameButton.isEnabled = true
        nameTextField.isEnabled = true
        let isTime1 = timeButton.restorationIdentifier == "time1"
        enableSaveButton()
        if isTime1 {
            time1Changed = true
            time1Selected = selectedTime
            time1Button.addTarget(self, action: #selector(time1ButtonTapped(_:)), for: .touchUpInside)
            if sliderSaysTwoPills() {
                time2Button.isEnabled = true
            }
        }
        else {
            time2Changed = true
            time2Selected = selectedTime
            time2Button.addTarget(self, action: #selector(time2ButtonTapped(_:)), for: .touchUpInside)
            time1Button.isEnabled = true
        }
    }
    
    // MARK: - Picker functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PDStrings.PillTypes.defaultPills.count + PDStrings.PillTypes.extraPills.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return names[row]
    }
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nameTextField.text = names[row]
        nameSelected = names[row]
    }
    
    private func openOrCloseNamePicker(closing: Bool) {
        if !closing {
            UIView.transition(with: namePicker as UIView, duration: 0.4, options: .transitionFlipFromTop, animations: { self.namePicker.isHidden = closing
            }, completion: {
                (void) in
                if self.nameTextField.text == PDStrings.PlaceholderStrings.new_pill {
                    self.nameChanged = true
                    self.nameSelected = self.names[self.namePicker.selectedRow(inComponent: 0)]
                    self.nameTextField.text = self.nameSelected
                }
            })
            
        }
        else {
            self.namePicker.isHidden = closing
        }
        nameTextField.isEnabled = closing
    }
    
    // MARK: - Text field
    
    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        selectNameButton.isEnabled = false
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if nameTextField.text == "" {
            nameTextField.text = PDStrings.PlaceholderStrings.new_pill
        }
        selectNameButton.isEnabled = true
        nameSelected = nameTextField.text
        nameChanged = true
        enableSaveButton()
        return true
    }
    
    // MARK: - Private loaders
    
    private func loadVCTitle() {
        title = (pill?.getName() == PDStrings.PlaceholderStrings.new_pill) ? PDStrings.VCTitles.pill_new : PDStrings.VCTitles.pill_edit
    }
    
    // Set VC pill as well as reflected attributes in the interactive UI
    private func reflectPillAttributes() {
        let pills = ScheduleController.pillController.pillArray
        if let index = pillIndex, index >= 0 && index < pills.count {
            self.pill = pills[index]
            loadName(from: pills[index])
            loadTimesaday(from: pills[index])
            loadTime1(from: pills[index])
            loadTime2(from: pills[index])
            loadNotify(from: pills[index])
        }
    }
    
    private func loadName(from pill: MOPill) {
        if let name = pill.getName() {
            self.name = name
            nameTextField.text = name
        }
    }
    
    private func loadNotify(from pill: MOPill) {
        if let notify = pill.getNotify() {
            notificationSwitch.isOn = notify
        }
    }
    
    private func loadTimesaday(from pill: MOPill) {
        if let timesaday = pill.getTimesday() {
            let tVal = (timesaday == 1) ? 1.0 : 3.0
            timesadaySlider.setValue(Float(tVal), animated: false)
            if timesaday < 2 {
                disableTime2()
            }
        }
    }
    
    private func loadTime1(from pill: MOPill) {
        if let time1 = pill.getTime1() {
            time1Button.setTitle(PDDateHelper.format(time: time1 as Time), for: .normal)
            time1Selected = time1 as Time
        }
    }
    
    private func loadTime2(from pill: MOPill) {
        if let time2 = pill.getTime2() {
            time2Button.setTitle(PDDateHelper.format(time: time2 as Time), for: .normal)
            time2Selected = time2 as Time
        }

    }
    
    private func enableTime2() {
        time2Button.isEnabled = true
        fixPillTimes(shouldSave: false)
    }
    
    private func fixPillTimes(shouldSave: Bool) {
        if let time1 = time1Selected,
            let time2 = time2Selected,
            (time2 as Time) < (time1 as Time) {
            time2Selected = time1 as Time
            time2Changed = true
            time2Button.setTitle(PDDateHelper.format(time: time1 as Time), for: .normal)
            time2Button.setTitle(PDDateHelper.format(time: time1 as Time), for: .disabled)
            
            // Save if erronous and not the just the user messing around.
            if shouldSave, let index = pillIndex {
                time2Changed = false
                ScheduleController.pillController.setPillTime2(at: index, to: time1 as Time)
            }
        }
    }
    
    private func disableTime2() {
        time2Button.isEnabled = false
    }
    
    private func enableSaveButton() {
        saveButton.isEnabled = true
        saveButton.tintColor = UIColor.blue
    }
    
    private func disableSavebutton() {
        saveButton.isEnabled = false
        saveButton.tintColor = UIColor.lightGray
    }
    
    // Creates a PillAttributes that reflects the current
    //   state of the interactive UI elements.
    private func makePillAttributes() -> PillAttributes {
        return PillAttributes(name: nameSelected,
                                        timesaday: timesadaySelected,
                                        time1: time1Selected,
                                        time2: time2Selected,
                                        notify: notifySelected,
                                        timesTakenToday: nil,
                                        lastTaken: nil,
                                        id: nil)
        
    }
    
    private func segueToPillsVC() {
        if let navCon = navigationController {
            navCon.popViewController(animated: true)
        }
    }
    
    private func sliderSaysTwoPills() -> Bool {
        return timesadaySlider.value >= 2.0
    }
    
}
