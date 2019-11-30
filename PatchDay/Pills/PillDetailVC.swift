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

    var viewModel: PillDetailViewModel? = nil

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegates()
        handleHardwareConstraints()
        loadSelectNameButton()
        loadTimesadaySlider()
        loadTimeButtons()
        disableSaveButton()
        reflectPillAttributes()
        fixPillTimes(save: true)
        loadTitle()
    }
    
    public static func createPillDetailVC(
        source: UIViewController, sdk: PatchDataDelegate, pill: Swallowable
    ) -> PillDetailVC? {
        let id = "PillDetailVC_id"
        if let vc = source.storyboard?.instantiateViewController(withIdentifier: id) as? PillDetailVC {
            vc.viewModel = PillDetailViewModel(pill)
            return vc
        }
        return nil
    }
    
    // MARK: -- Pill actions
    
    @objc func selectNameTapped() {
        activatePicker(closing: false)
        selectNameButton.setTitle(ActionStrings.done, for: .normal)
        selectNameButton.replaceTarget(self, newAction: #selector(doneWithSelectNameTapped))
    }

    @objc func doneWithSelectNameTapped() {
        activatePicker(closing: true)
        selectNameButton.setTitle(ActionStrings.select, for: .normal)
        selectNameButton.replaceTarget(self, newAction: #selector(selectNameTapped))
        if viewModel?.selections.name != nil {
            enableSaveButton()
        }
    }
    
    @IBAction func saveButtonTapped() {
        viewModel?.save()
        segueToPillsVC()
    }
    
    @IBAction func notificationSwitched(_ sender: Any) {
        let notifySwitch = sender as! UISwitch
        enableSaveButton()
    }
    
    @IBAction func timesadaySliderValueChanged(_ sender: Any) {
        let slider = sender as! UISlider
        if slider.value >= 2 {
            enableTime2()
            viewModel?.selections.timesaday = 2
        } else {
            time2Button.isEnabled = false
            viewModel?.selections.timesaday = 1

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
        if let pill = viewModel?.pill {
            timePicker.isHidden = false
            timePicker.minimumDate = nil
            transformIntoDoneButton(time1Button)
            disableNonTimeInteractions()
            timePicker.date = viewModel?.selections.time1 ?? pill.time1
            timePicker.maximumDate = time2Button.isEnabled ? viewModel?.selections.time2 ?? pill.time2 : nil
            time2Button.isEnabled = false // temporarily disable time2button
        }
    }
    
    @objc func time2ButtonTapped(_ sender: Any) {
        timePicker.isHidden = false
        timePicker.maximumDate = nil
        time1Button.isEnabled = false
        transformIntoDoneButton(time2Button)
        disableNonTimeInteractions()
        time1Button.isEnabled = false
        timePicker.minimumDate = viewModel?.startMinimumTimePickerTwoTime
        if let startTime = viewModel?.startTimePickerTwoTime {
            timePicker.date = startTime
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
            viewModel?.selections.time1 = timePicker.date
            time1Button.replaceTarget(self, newAction: #selector(time1ButtonTapped(_:)))
            if sliderSaysTwoPills() {
                time2Button.isEnabled = true
            }
        } else {
            viewModel?.selections.time2 = timePicker.date
            time2Button.replaceTarget(self, newAction: #selector(time2ButtonTapped(_:)))
            time1Button.isEnabled = true
        }
    }
    
    // MARK: - Picker functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        DefaultNumberOfPickerComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        PDStrings.PillTypes.defaultPills.count + PDStrings.PillTypes.extraPills.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel?.providedPillNameSelection[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let vm = viewModel {
            let name = vm.providedPillNameSelection[row]
            vm.selections.name = name
            nameTextField.text = name
        }
    }
    
    private func activatePicker(closing: Bool) {
        let nameIndex = viewModel?.namePickerStartIndex ?? 0
        self.namePicker.selectRow(nameIndex, inComponent: 0, animated: false)
        
        if !closing {
            openPicker()
        } else {
            self.namePicker.isHidden = true
        }
        nameTextField.isEnabled = closing
    }

    private func openPicker() {
        UIView.transition(
            with: namePicker as UIView,
            duration: 0.4,
            options: .transitionFlipFromTop,
            animations: { self.namePicker.isHidden = false },
            completion: { void in }
        )
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
        viewModel?.selections.name = nameTextField.text
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
    
    private func loadTimesadaySlider() {
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
        title = viewModel?.title ?? viewModel.DefaultViewControllerTitle
    }
    
    // Set VC pill as well as reflected attributes in the interactive UI
    private func reflectPillAttributes() {
        if let p = viewModel.pill {
            loadName(from: p)
            loadTimesaday(from: p)
            loadTime1(from: p)
            loadTime2(from: p)
            loadNotify(from: p)
        }
    }
    
    private func loadName(from pill: Swallowable) {
        nameTextField.text = pill.name
    }
    
    private func loadNotify(from pill: Swallowable) {
        notificationSwitch.isOn = pill.notify
    }
    
    private func loadTimesaday(from pill: Swallowable) {
        let timesaday = Float((pill.timesaday == 1) ? 1.0 : 3.0)
        timesadaySlider.setValue(timesaday, animated: false)
        time2Button.isEnabled = pill.timesaday == 2
    }
    
    private func loadTime1(from pill: Swallowable) {
        time1Button.setTitle(viewModel?.time1Text, for: .normal)
    }
    
    private func loadTime2(from pill: Swallowable) {
        time2Button.setTitle(viewModel?.time2Text, for: .normal)
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
    
    private func disableSaveButton() {
        saveButton.isEnabled = false
        saveButton.tintColor = UIColor.lightGray
    }
    
    private func segueToPillsVC() {
        if let navCon = navigationController {
            navCon.popViewController(animated: true)
        }
    }
    
    private func sliderSaysTwoPills() -> Bool {
        timesadaySlider.value >= 2.0
    }
}
