//
//  PillDetailVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/28/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class PillDetailVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

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

    private var sdk: PatchDataDelegate = app.sdk
    private var notifications: NotificationScheduling = app.notifications
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
        setPickerDelegates()
        handleHardwareConstraints()
        loadSelectNameButton()
        loadTimeadaySlider()
        loadTimeButtons()
        disableSavebutton()
        reflectPillAttributes()
        fixPillTimes(save: true)
        loadTitle()
    }
    
    public static func createPillDetailVC(
        source: UIViewController, sdk: PatchDataDelegate, pill: Swallowable
    ) -> PillDetailVC? {
        let id = "PillDetailVC_id"
        let sb = source.storyboard
        if let vc = sb?.instantiateViewController(withIdentifier: id) as? PillDetailVC {
            vc.pill = pill
            return vc
        }
        return nil
    }
    
    // MARK: -- Pill actions
    
    @objc func selectNameTapped() {
        openOrCloseNamePicker(closing: false)
        selectNameButton.setTitle(ActionStrings.done, for: .normal)
        selectNameButton.replaceTarget(self, newAction: #selector(doneWithSelectNameTapped))
    }

    @objc func doneWithSelectNameTapped() {
        openOrCloseNamePicker(closing: true)
        selectNameButton.setTitle(ActionStrings.select, for: .normal)
        selectNameButton.replaceTarget(self, newAction: #selector(selectNameTapped))
        if name != nameSelected {
            nameChanged = true
            enableSaveButton()
        }
    }
    
    @IBAction func saveButtonTapped() {
        if let pill = pill {
            notifications.cancelDuePillNotification(pill)
            sdk.pills.set(for: pill, with: createPillAttributes())
            notifications.requestDuePillNotification(pill)
            if let vcs = navigationController?.tabBarController?.viewControllers {
                let newValue = sdk.pills.totalDue
                vcs[1].tabBarItem.badgeValue = newValue > 0 ? "\(newValue)" : nil
            }
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
        button.replaceTarget(self, newAction: #selector(timePickerDone(sender:)))
    }
    
    @objc func timePickerDone(sender: Any) {
        let timeButton = sender as! UIButton
        timeButton.setTitle(DateHelper.format(time: timePicker.date))
        enableSaveButton()
        timeButton.isSelected = false
        timePicker.isHidden = true
        timesadaySlider.isEnabled = true
        selectNameButton.isEnabled = true
        nameTextField.isEnabled = true
        if timeButton.restorationIdentifier == "time1" {
            time1Changed = true
            time1Selected = timePicker.date
            time1Button.replaceTarget(self, newAction: #selector(time1ButtonTapped(_:)))
            if sliderSaysTwoPills() {
                time2Button.isEnabled = true
            }
        } else {
            time2Changed = true
            time2Selected = timePicker.date
            time2Button.replaceTarget(self, newAction: #selector(time2ButtonTapped(_:)))
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
        let n = (nameSelected == nil) ? name : nameSelected
        if let selectedName = n, let i = names.firstIndex(of: selectedName) {
            self.namePicker.selectRow(i, inComponent: 0, animated: false)
        }
        
        if !closing {
            UIView.transition(
                with: namePicker as UIView,
                duration: 0.4,
                options: .transitionFlipFromTop,
                animations: { self.namePicker.isHidden = closing },
                completion: { void in return }
            )
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
            nameTextField.text = PDStrings.PlaceholderStrings.newPill
        }
        selectNameButton.isEnabled = true
        nameSelected = nameTextField.text
        nameChanged = true
        enableSaveButton()
        return true
    }
    
    // MARK: - Private loaders
    
    private func setPickerDelegates() {
        namePicker.delegate = self
        nameTextField.delegate = self
    }
    
    private func handleHardwareConstraints() {
        if AppDelegate.isPad {
            topConstraint.constant = 100
        }
    }
    
    private func loadSelectNameButton() {
         selectNameButton.setTitleColor(UIColor.lightGray, for: .disabled)
         selectNameButton.addTarget(self, action: #selector(selectNameTapped), for: .touchUpInside)
    }
    
    private func loadTimeadaySlider() {
        timesadaySlider.maximumValue = 4.0
        timesadaySlider.minimumValue = 0.0
    }
    
    private func loadTimeButtons() {
        time1Button.setTitleColor(UIColor.lightGray, for: .disabled)
        time2Button.setTitleColor(UIColor.lightGray, for: .disabled)
        time1Button.addTarget(self, action: #selector(time1ButtonTapped(_:)), for: .touchUpInside)
        time2Button.addTarget(self, action: #selector(time2ButtonTapped(_:)), for: .touchUpInside)
        time1Button.setTitle(ActionStrings.done, for: .selected)
        time2Button.setTitle(ActionStrings.done, for: .selected)
        time1Button.setTitleColor(UIColor.blue, for: .selected)
        time2Button.setTitleColor(UIColor.blue, for: .selected)
    }
    
    private func loadTitle() {
        let isNew = pill?.name == PDStrings.PlaceholderStrings.newPill
        title = isNew ? VCTitleStrings.newPillTitle : VCTitleStrings.editPillTitle
    }
    
    // Set VC pill as well as reflected attributes in the interactive UI
    private func reflectPillAttributes() {
        if let p = pill {
            loadName(from: p)
            loadTimesaday(from: p)
            loadTime1(from: p)
            loadTime2(from: p)
            loadNotify(from: p)
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
        time1Button.setTitle(DateHelper.format(time: pill.time1), for: .normal)
        time1Selected = pill.time1
    }
    
    private func loadTime2(from pill: Swallowable) {
        time2Button.setTitle(DateHelper.format(time: pill.time2), for: .normal)
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
            let timeString = DateHelper.format(time: time1)
            time2Button.setTitleForNormalAndDisabled(timeString)
            if save, let p = pill {
                sdk.pills.set(for: p, with: createPillAttributes())
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
    private func createPillAttributes() -> PillAttributes {
        return PillAttributes(
            name: nameSelected,
            timesaday: timesadaySelected,
            time1: time1Selected,
            time2: time2Selected,
            notify: notifySelected,
            timesTakenToday: nil,
            lastTaken: nil
         )
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
