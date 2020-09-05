//
//  PillDetailVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/28/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PillDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    private var viewModel: PillDetailViewModel!

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var detailStack: UIStackView!
    @IBOutlet weak var drugNameLabel: UILabel!
    @IBOutlet weak var lineUnderDrugNameLabel: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var verticalLineInDrugNameStack: UIView!
    @IBOutlet weak var selectNameButton: UIButton!
    @IBOutlet weak var namePicker: UIPickerView!
    @IBOutlet weak var lineUnderDrugNameStack: UIView!
    @IBOutlet weak var notificationsIcon: UIImageView!
    @IBOutlet weak var notificationsLabel: UILabel!

    @IBOutlet weak var lineUnderNotifications: UIView!
    @IBOutlet weak var expirationIntervalIcon: UIImageView!
    @IBOutlet weak var expirationIntervalButton: UIButton!
    @IBOutlet weak var expirationIntervalLabel: UILabel!
    @IBOutlet weak var expirationIntervalArrowButton: UIButton!
    @IBOutlet weak var lineUnderExpirationInterval: UIView!

    @IBOutlet weak var expirationIntervalPicker: UIPickerView!
    @IBOutlet weak var paddingAboveNotificationsSwitch: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var paddingBelowNotificationsSwitch: UIView!
    @IBOutlet weak var timesadayLabel: UILabel!
    @IBOutlet weak var timesadaySlider: UISlider!
    @IBOutlet weak var timePicker: UIDatePicker!

    @IBOutlet weak var timeOneButton: UIButton!
    @IBOutlet weak var timeTwoButton: UIButton!
    @IBOutlet weak var timeThreeButton: UIButton!
    @IBOutlet weak var timeFourButton: UIButton!

    private var selectedPicker: UIPickerView?

    private var timeButtons: [UIButton] {
        [timeOneButton, timeTwoButton, timeThreeButton, timeFourButton]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegates()
        handleHardwareConstraints()
        loadTitle()
        willEnterForeground()
        setBackButton()
        tabBarItem.selectedImage = tabBarItem.selectedImage?.withTintColor(PDColors[.Purple])
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        willEnterForeground()
        super.viewDidAppear(animated)
    }

    @objc func willEnterForeground() {
        loadSelectNameButton()
        disableSaveButton()
        reflectPillAttributes()
        applyTheme()
    }

    static func createPillDetailVC(_ source: UIViewController, _ index: Index) -> PillDetailViewController? {
        let vc = createPillDetailVC(source)
        return vc?.initWithPillIndex(index)
    }

    private static func createPillDetailVC(_ source: UIViewController) -> PillDetailViewController? {
        let id = ViewControllerIds.PillDetail
        return source.storyboard?.instantiateViewController(withIdentifier: id) as? PillDetailViewController
    }

    private func initWithPillIndex(_ index: Index) -> PillDetailViewController {
        viewModel = PillDetailViewModel(index)
        return self
    }

    @objc func back() {
        checkForUnsavedChanges()
    }

    private func checkForUnsavedChanges() {
        guard let viewModel = viewModel else { return }
        viewModel.handleIfUnsaved(self)
    }

    private func setBackButton() {
        let newButton = UIBarButtonItem(
            title: ActionStrings.Back,
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(back)
        )
        newButton.tintColor = PDColors[.Button]
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = newButton
    }

    // MARK: - Pill actions

    @IBAction func timeButtonTapped(_ sender: Any) {
        guard let timeButton = sender as? UIButton else { return }
        guard timeButton.isEnabled else { return }

    }

    @objc func selectNameTapped() {
        openNamePicker()
        selectNameButton.setTitle(ActionStrings.Done)
        selectNameButton.replaceTarget(self, newAction: #selector(doneWithSelectNameTapped))
    }

    @objc func doneWithSelectNameTapped() {
        closeNamePicker()
        selectNameButton.setTitle(ActionStrings.Select)
        selectNameButton.replaceTarget(self, newAction: #selector(selectNameTapped))
        if viewModel.selections.name != nil {
            enableSaveButton()
        }
    }

    @IBAction func expirationIntervalTapped(_ sender: Any) {
        selectedPicker = expirationIntervalPicker
        openExpirationIntervalPicker()
        expirationIntervalButton.setTitle(ActionStrings.Done)
        expirationIntervalButton.replaceTarget(self, newAction: #selector(doneWithSelectExpirationIntervalTapped))
    }

    @objc func doneWithSelectExpirationIntervalTapped() {
        closeExpirationIntervalPicker()
        if let interval = viewModel.selections.expirationInterval {
            expirationIntervalButton.setTitle(interval)
        }
        expirationIntervalButton.replaceTarget(self, newAction: #selector(expirationIntervalTapped))
        if viewModel.selections.expirationInterval != nil {
            enableSaveButton()
        }
    }

    @IBAction func saveButtonTapped() {
        viewModel.save()
        segueToPillsVC()
    }

    @IBAction func notificationSwitched(_ sender: Any) {
        guard let _switch = sender as? UISwitch else { return }
        viewModel.selections.notify = _switch.isOn
        enableSaveButton()
    }

    @IBAction func timesadaySliderValueChanged(_ sender: Any) {
        let slider = sender as! UISlider
        let newValue = Int(round(slider.value))
        guard 1...timeButtons.count ~= newValue else { return }
        updateTimesdayValueLabel(with: newValue)
        handleTimeButtonActivation(newValue)
        enableSaveButton()
    }

    @objc func timePickerDone(sender: Any) {
        guard let timeButton = sender as? UIButton else { return }
        setControlsFromTimePickerDone(timeButton: timeButton)
        handleTimeNumberTypeDone(viewModel.createTimeNumberTypeFromButton(timeButton))
    }

    // MARK: - Picker functions

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        DefaultNumberOfPickerComponents
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectedPicker == namePicker {
            return viewModel.pillSelectionCount
        }
        return PillStrings.Intervals.all.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if selectedPicker == namePicker {
            return viewModel.providedPillNameSelection.tryGet(at: row)
        }
        return PillStrings.Intervals.all.tryGet(at: row)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if selectedPicker == namePicker {
            nameTextField.text = viewModel.selectNameFromRow(row)
        } else {
            viewModel.selectExpirationIntervalFromRow(row)
        }
    }

    // MARK: - Text field

    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectNameButton.isEnabled = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        nameTextField.text = nameTextField.text == "" ? PillStrings.NewPill : nameTextField.text
        selectNameButton.isEnabled = true
        viewModel.selections.name = nameTextField.text
        enableSaveButton()
        return true
    }

    // MARK: - Private loaders

    private func setPickerDelegates() {
        namePicker.delegate = self
        nameTextField.delegate = self
        expirationIntervalPicker.delegate = self
    }

    private func handleHardwareConstraints() {
        guard AppDelegate.isPad else { return }
        topConstraint.constant = 100
    }

    private func loadSelectNameButton() {
        selectNameButton.setTitleColor(UIColor.lightGray, for: .disabled)
        selectNameButton.addTarget(self, action: #selector(selectNameTapped), for: .touchUpInside)
    }

//    private func loadTimeButtons() {
//        for button in timeButtonMap.values {
//            button.setTitleColor(UIColor.lightGray, for: .disabled)
//            button.addTarget(self, action: #selector(timeButtonTapped(_:)), for: .touchUpInside)
//            button.setTitle(ActionStrings.Done, for: .selected)
//            button.setTitleColor(UIColor.blue, for: .selected)
//        }
//    }

    private func loadTitle() {
        title = viewModel.title
    }

    private func reflectPillAttributes() {
        loadName()
        loadTimes()
        loadNotify()
        loadExpirationInterval()
    }

    private func loadName() {
        nameTextField.text = viewModel.pill.name
    }

    private func loadNotify() {
        notificationSwitch.isOn = viewModel.notifyStartValue
    }

    private func loadTimes() {
        loadTimeButtonStaticStates()
        let timesaday = viewModel.pill.timesaday
        timesadaySlider.setValue(Float(timesaday), animated: false)
        updateTimesdayValueLabel(with: timesaday)
        handleTimeButtonActivation(timesaday)
    }

    private func loadTimeButtonStaticStates() {
        for button in timeButtons {
            button.setTitleColor(UIColor.lightGray, for: .disabled)
            button.addTarget(self, action: #selector(timeButtonTapped(_:)), for: .touchUpInside)
            button.setTitle(ActionStrings.Done, for: .selected)
            button.setTitleColor(UIColor.blue, for: .selected)
        }
    }

    private func handleTimeButtonActivation(_ timesaday: Int) {
        guard 1...timeButtons.count ~= timesaday else { return }
        for i in 0...timesaday - 1 {
            timeButtons[i].isEnabled = true
        }
        for i in timesaday..<timeButtons.count {
            timeButtons[i].isEnabled = false
        }
    }

    private func updateTimesdayValueLabel(with timesaday: Int) {
        let prefix = NSLocalizedString("How many per day: ", comment: "Label prefix")
        timesadayLabel.text = "\(prefix) \(timesaday)"
    }

    private func loadExpirationInterval() {
        expirationIntervalButton.setTitle(viewModel.pill.expirationInterval)
    }

    private func disableNonTimeInteractions() {
        timesadaySlider.isEnabled = false
        selectNameButton.isEnabled = false
        nameTextField.isEnabled = false
    }

    private func transformIntoDoneButton(_ button: UIButton) {
        button.isSelected = true
        button.replaceTarget(self, newAction: #selector(timePickerDone(sender:)))
    }

    private func openNamePicker() {
        selectedPicker = namePicker
        startNamePickerActivation()
        nameTextField.isEnabled = false
        unhideNamePicker()
    }

    private func openExpirationIntervalPicker() {
        startExpirationPickerActivation()
        expirationIntervalPicker.isHidden = false
    }

    private func unhideNamePicker() {
        PillDetailViewController.unhidePicker(namePicker)
    }

    private func unhideExpirationIntervalPicker() {
        PillDetailViewController.unhidePicker(expirationIntervalPicker)
    }

    private static func unhidePicker(_ picker: UIPickerView) {
        UIView.transition(
            with: picker as UIView,
            duration: 0.4,
            options: .transitionFlipFromTop,
            animations: { picker.isHidden = false },
            completion: { _ in }
        )
    }

    private func startNamePickerActivation() {
        let nameIndex = viewModel.namePickerStartIndex
        namePicker.selectRow(nameIndex, inComponent: 0, animated: false)
    }

    private func startExpirationPickerActivation() {
        let index = viewModel.expirationIntervalStartIndex
        expirationIntervalPicker.selectRow(index, inComponent: 0, animated: false)
    }

    private func closeNamePicker() {
        startNamePickerActivation()
        nameTextField.isEnabled = true
        namePicker.isHidden = true
        selectedPicker = nil
    }

    private func closeExpirationIntervalPicker() {
        startExpirationPickerActivation()
        expirationIntervalPicker.isHidden = true
        selectedPicker = nil
    }

    private func setControlsFromTimePickerDone(timeButton: UIButton) {
        timeButton.setTitle(PDDateFormatter.formatTime(timePicker.date))
        enableSaveButton()
        timeButton.isSelected = false
        timePicker.isHidden = true
        timesadaySlider.isEnabled = true
        selectNameButton.isEnabled = true
        nameTextField.isEnabled = true
    }

    private func handleTimeNumberTypeDone(_ type: TimeNumber) {
        switch type {
            case .Time1: handleTimeNumberOneDone()
            case .Time2: handleTimeNumberTwoDone()
        }
    }

    private func handleTimeNumberOneDone() {
        // TODO: lalala
        //viewModel.selections.time1 = timePicker.date
        //time1Button.replaceTarget(self, newAction: #selector(time1ButtonTapped(_:)))
//        if sliderSaysMoreThanOne() {
//            time2Button.isEnabled = true
//        }
    }

    private func handleTimeNumberTwoDone() {
        // TODO: lalala
        //viewModel.selections.time2 = timePicker.date
        //time2Button.replaceTarget(self, newAction: #selector(time2ButtonTapped(_:)))
        //time1Button.isEnabled = true
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
        guard let navCon = navigationController else { return }
        navCon.popViewController(animated: true)
    }

    private func sliderSaysMoreThanOne() -> Bool {
        timesadaySlider.value > 1
        //TimesadaySliderDefinition.valueIsGreaterThanOne(timesday: timesadaySlider.value)
    }

    private func applyTheme() {
        view.backgroundColor = UIColor.systemBackground
        saveButton.tintColor = PDColors[.Button]
        detailStack.backgroundColor = UIColor.systemBackground
        drugNameLabel.textColor = PDColors[.Text]
        lineUnderDrugNameLabel.backgroundColor = PDColors[.Border]
        nameTextField.textColor = PDColors[.Button]
        verticalLineInDrugNameStack.backgroundColor = PDColors[.Border]
        selectNameButton.setTitleColor(PDColors[.Button])
        lineUnderDrugNameStack.backgroundColor = PDColors[.Border]
        notificationsIcon.tintColor = PDColors[.Text]
        notificationsIcon.image = notificationsIcon.image?.withTintColor(PDColors[.Text])
        notificationsLabel.textColor = PDColors[.Text]
        lineUnderNotifications.backgroundColor = PDColors[.Border]
        expirationIntervalIcon.image = expirationIntervalIcon.image?.withTintColor(PDColors[.Text])
        expirationIntervalLabel.textColor = PDColors[.Text]
        expirationIntervalButton.setTitleColor(PDColors[.Button])
        lineUnderExpirationInterval.backgroundColor = PDColors[.Border]
        paddingAboveNotificationsSwitch.backgroundColor = UIColor.systemBackground
        timesadaySlider.backgroundColor = UIColor.systemBackground
        paddingBelowNotificationsSwitch.backgroundColor = UIColor.systemBackground
        timesadayLabel.textColor = PDColors[.Text]
       // time1Button.setTitleColor(PDColors[.Button])
       // time2Button.setTitleColor(PDColors[.Button])
    }
}
