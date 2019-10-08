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

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
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

    private var sdk = app.sdk
    private var notifications: PDNotificationCenter
    private var pillIndex: Index?
    private var pill: Swallowable?

    private var names: [String] {
        return PDStrings.PillTypes.defaultPills + PDStrings.PillTypes.extraPills
    }
    
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
        
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.phone) {
            topConstraint.constant = 100
        }
        
        // UI States
        selectNameButton.setTitleColor(UIColor.lightGray, for: .disabled)
        selectNameButton.addTarget(self, action: #selector(selectNameTapped), for: .touchUpInside)
        timesadaySlider.maximumValue = 4.0
        timesadaySlider.minimumValue = 0.0
        time1Button.setTitleColor(UIColor.lightGray, for: .disabled)
        time2Button.setTitleColor(UIColor.lightGray, for: .disabled)
        time1Button.addTarget(self, action: #selector(time1ButtonTapped(_:)), for: .touchUpInside)
        time2Button.addTarget(self, action: #selector(time2ButtonTapped(_:)), for: .touchUpInside)
        time1Button.setTitle(PDActionStrings.done, for: .selected)
        time2Button.setTitle(PDActionStrings.done, for: .selected)
        time1Button.setTitleColor(UIColor.blue, for: .selected)
        time2Button.setTitleColor(UIColor.blue, for: .selected)
        disableSavebutton()
        reflectPillAttributes()
        fixPillTimes(save: true)
        loadVCTitle()
    }
    
    public func setPill(_ pill: PDPill) {
        self.pill = pill
    }
    
    public func setPillIndex(_ index: Index) {
        pillIndex = index
    }
    
    // MARK: -- Pill actions
    
    @objc func selectNameTapped() {
        openOrCloseNamePicker(closing: false)
        selectNameButton.setTitle(PDActionStrings.done, for: .normal)
        selectNameButton.removeTarget(nil, action: nil, for: .allEvents)
        selectNameButton.addTarget(self, action: #selector(doneWithSelectNameTapped), for: .touchUpInside)
    }

    @objc func doneWithSelectNameTapped() {
        openOrCloseNamePicker(closing: true)
        selectNameButton.setTitle(PDActionStrings.select, for: .normal)
        selectNameButton.removeTarget(nil, action: nil, for: .allEvents)
        selectNameButton.addTarget(self, action: #selector(selectNameTapped), for: .touchUpInside)
        if name != nameSelected {
            nameChanged = true
            enableSaveButton()
        }
    }
    
    @IBAction func saveButtonTapped() {
        if let pill = pill {
            notifications.cancel(pill)
            pillSchedule.setPill(for: pill, with: makePillAttributes())
            notifications.requestPillNotification(pill)
            if let vcs = navigationController?.tabBarController?.viewControllers {
                let newValue = pillSchedule.totalDue()
                vcs[1].tabBarItem.badgeValue = (newValue > 0) ? String(newValue) : nil
            }
            shared.setPillDataForToday()
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
        } else {
            time2Button.isEnabled = false
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
        if let pill = pill {
            timePicker.isHidden = false
            timePicker.minimumDate = nil
            transformIntoDoneButton(time1Button)
            disableNonTimeInteractions()
            timePicker.date = time1Selected ?? pill.time1
            timePicker.maximumDate = time2Button.isEnabled ?
                time2Selected ?? pill.time2 : nil
            time2Button.isEnabled = false // temporarily disable time2button
        }
    }
    
    @objc func time2ButtonTapped(_ sender: Any) {
        if let pill = pill {
            timePicker.isHidden = false
            timePicker.maximumDate = nil
            time1Button.isEnabled = false
            transformIntoDoneButton(time2Button)
            disableNonTimeInteractions()
            time1Button.isEnabled = false
            timePicker.date = time2Selected ?? pill.time2
            timePicker.minimumDate = time1Selected ?? pill.time1
        }
    }
    
    private func transformIntoDoneButton(_ button: UIButton) {
        button.isSelected = true
        button.removeTarget(nil, action: nil, for: .allEvents)
        button.addTarget(self, action: #selector(timePickerDone(sender:)), for: .touchUpInside)
    }
    
    @objc func timePickerDone(sender: Any) {
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
            time1Button.removeTarget(nil, action: nil, for: .allEvents)
            time1Button.addTarget(self, action: #selector(time1ButtonTapped(_:)), for: .touchUpInside)
            if sliderSaysTwoPills() {
                time2Button.isEnabled = true
            }
        } else {
            time2Changed = true
            time2Selected = selectedTime
            time2Button.removeTarget(nil, action: nil, for: .allEvents)
            time2Button.addTarget(self, action: #selector(time2ButtonTapped(_:)), for: .touchUpInside)
            time1Button.isEnabled = true
        }
    }
    
    // MARK: - Picker functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        typealias PT = PDStrings.PillTypes
        return PT.defaultPills.count + PT.extraPills.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return names[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nameSelected = names[row]
        nameTextField.text = nameSelected
        nameChanged = true
    }
    
    private func openOrCloseNamePicker(closing: Bool) {
        
        // Select row
        let n = (nameSelected == nil) ? name : nameSelected
        if let selectedName = n, let i = names.firstIndex(of: selectedName) {
            self.namePicker.selectRow(i, inComponent: 0, animated: false)
        }
        
        if !closing {
            UIView.transition(with: namePicker as UIView,
                              duration: 0.4,
                              options: .transitionFlipFromTop,
                              animations: { self.namePicker.isHidden = closing },
                              completion: { void in return })
        } else {
            self.namePicker.isHidden = true
        }
        nameTextField.isEnabled = closing
    }
    
    // MARK: - Text field
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectNameButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
        let isNew = pill?.name == PDStrings.PlaceholderStrings.new_pill
        title = isNew ? PDVCTitleStrings.newPillTitle : PDVCTitleStrings.editPillTitle
    }
    
    // Set VC pill as well as reflected attributes in the interactive UI
    private func reflectPillAttributes() {
        if let index = pillIndex, index >= 0 && index < sdk.pills.count {
            self.pill = sdk.pills.all[index]
            loadName(from: sdk.pills.all[index])
            loadTimesaday(from: sdk.pills.all[index])
            loadTime1(from: sdk.pills.all[index])
            loadTime2(from: sdk.pills.all[index])
            loadNotify(from: sdk.pills.all[index])
        }
    }
    
    private func loadName(from pill: Swallowable) {
        self.name = pill.name
        nameTextField.text = pill.name
    }
    
    private func loadNotify(from pill: Swallowable) {
        notificationSwitch.isOn = pill.notify
    }
    
    private func loadTimesaday(from pill: Swallowable) {
        let timesday = Float((pill.timesaday == 1) ? 1.0 : 3.0)
        timesadaySlider.setValue(timesday, animated: false)
        time2Button.isEnabled = pill.timesaday == 2
    }
    
    private func loadTime1(from pill: Swallowable) {
        time1Button.setTitle(PDDateHelper.format(time: pill.time1), for: .normal)
        time1Selected = pill.time1
    }
    
    private func loadTime2(from pill: Swallowable) {
        time2Button.setTitle(PDDateHelper.format(time: pill.time2), for: .normal)
        time2Selected = pill.time2
    }
    
    private func enableTime2() {
        time2Button.isEnabled = true
        fixPillTimes(save: false)
    }
    
    // Prevents time2 from going beneath time1
    private func fixPillTimes(save: Bool) {
        if let time1 = time1Selected,
            let time2 = time2Selected,
            time2 < time1 {
            time2Selected = time1
            time2Changed = true
            time2Button.setTitle(PDDateHelper.format(time: time1), for: .normal)
            time2Button.setTitle(PDDateHelper.format(time: time1), for: .disabled)
            
            // Save if erronous and not the just the user messing around.
            if save, let index = pillIndex {
                let attributes = makePillAttributes()
                pillSchedule.setPill(at: index, with: attributes);
            }
        }
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
                              lastTaken: nil)
        
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
