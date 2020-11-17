//
//  PillDetailViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/28/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PillDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    private var viewModel: PillDetailViewModelProtocol!

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

    @IBOutlet weak var timePickerOne: UIDatePicker!
    @IBOutlet weak var timePickerTwo: UIDatePicker!
    @IBOutlet weak var timePickerThree: UIDatePicker!
    @IBOutlet weak var timePickerFour: UIDatePicker!

    private var timePickers: [UIDatePicker] {
        [timePickerOne, timePickerTwo, timePickerThree, timePickerFour]
    }

    private var selectedPicker: UIPickerView?

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

    static func createPillDetailVC(
        _ source: UIViewController, _ index: Index
    ) -> PillDetailViewController? {
        let vc = createPillDetailVC(source)
        return vc?.initWithPillIndex(index)
    }

    private static func createPillDetailVC(_ source: UIViewController) -> PillDetailViewController? {
        let id = ViewControllerIds.PillDetail
        let vc = source.storyboard?.instantiateViewController(withIdentifier: id)
        return vc as? PillDetailViewController
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
        expirationIntervalButton.replaceTarget(
            self, newAction: #selector(doneWithSelectExpirationIntervalTapped)
        )
    }

    @objc func doneWithSelectExpirationIntervalTapped() {
        closeExpirationIntervalPicker()
        let intervalText = viewModel.expirationIntervalText
        expirationIntervalButton.setTitle(intervalText)
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
        let newTimesaday = Int(round(slider.value))
        guard newTimesaday != viewModel.timesaday else { return }
        guard newTimesaday <= timePickers.count else { return }
        guard newTimesaday >= 0 else { return }
        viewModel.setTimesaday(newTimesaday)
        updateTimesdayValueLabel()
        viewModel.enableOrDisablePickers(timePickers)
        enableSaveButton()
    }

    // MARK: - Picker functions

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        DefaultNumberOfPickerComponents
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectedPicker == namePicker {
            return viewModel.nameSelectionCount
        }
        return PillStrings.Intervals.all.count
    }

    func pickerView(
        _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int
    ) -> String? {
        if selectedPicker == namePicker {
            return viewModel.providedNameSelection.tryGet(at: row)
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
        selectNameButton.replaceTarget(self, newAction: #selector(selectNameTapped), for: .touchUpInside)
    }

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
        notificationSwitch.isOn = viewModel.notify
    }

    private func loadTimes() {
        loadTimePickers()
        let timesaday = viewModel.timesaday
        timesadaySlider.setValue(Float(timesaday), animated: false)
        updateTimesdayValueLabel()
        viewModel.enableOrDisablePickers(timePickers)
        viewModel.assignTimePickerMinsAndMaxes(timePickers)
    }

    private func updateTimesdayValueLabel() {
        let prefix = NSLocalizedString("How many per day: ", comment: "Label prefix")
        let timesaday = viewModel.timesaday
        timesadayLabel.text = "\(prefix) \(timesaday)"
    }

    private func loadExpirationInterval() {
        expirationIntervalButton.setTitle(viewModel.expirationIntervalText)
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

    @objc private func handleTimeOnePickerDone() {
        handleTimePickerDone(timePickerOne)
    }

    @objc private func handleTimeTwoPickerDone() {
        handleTimePickerDone(timePickerTwo)
    }

    @objc private func handleTimeThreePickerDone() {
        handleTimePickerDone(timePickerThree)
    }

    @objc private func handleTimeFourPickerDone() {
        handleTimePickerDone(timePickerFour)
    }

    @objc private func handleTimePickerDone(_ timePicker: UIDatePicker) {
        enableSaveButton()
        let timeIndex = timePickers.firstIndex(of: timePicker) ?? 0
        let newTime = timePicker.date
        viewModel.selectTime(newTime, timeIndex)
    }

    private func loadTimePickers() {
        loadTimePickerEventHandlers()
        for i in 0..<timePickers.count {
            let picker = timePickers[i]
            let times = viewModel.getPickerTimes(timeIndex: i)
            picker.setDate(times.start, animated: false)
        }
        viewModel.assignTimePickerMinsAndMaxes(timePickers)
    }

    private func loadTimePickerEventHandlers() {
        timePickerOne.addTarget(
            self, action: #selector(handleTimeOnePickerDone), for: .allEditingEvents
        )
        timePickerTwo.addTarget(
            self, action: #selector(handleTimeTwoPickerDone), for: .allEditingEvents
        )
        timePickerThree.addTarget(
            self, action: #selector(handleTimeThreePickerDone), for: .allEditingEvents
        )
        timePickerFour.addTarget(
            self, action: #selector(handleTimeFourPickerDone), for: .allEditingEvents
        )
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
        timePickerOne.backgroundColor = UIColor.systemBackground
        timePickerTwo.backgroundColor = UIColor.systemBackground
        timePickerThree.backgroundColor = UIColor.systemBackground
        timePickerFour.backgroundColor = UIColor.systemBackground
    }
}
