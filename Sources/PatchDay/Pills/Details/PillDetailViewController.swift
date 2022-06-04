//
//  PillDetailViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/28/18.

import UIKit
import PDKit

class PillDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    private var viewModel: PillDetailViewModelProtocol!
    private var selectedPicker: UIPickerView?
    private var selectedDaysNumber = 0

    @IBOutlet private var detailsView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var detailStack: UIStackView!
    @IBOutlet private weak var drugNameLabel: UILabel!
    @IBOutlet private weak var lineUnderDrugNameLabel: UIView!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var verticalLineInDrugNameStack: UIView!
    @IBOutlet private weak var selectNameButton: UIButton!
    @IBOutlet private weak var namePicker: UIPickerView!
    @IBOutlet private weak var lineUnderDrugNameStack: UIView!
    @IBOutlet private weak var notificationsIcon: UIImageView!
    @IBOutlet private weak var notificationsLabel: UILabel!
    @IBOutlet private weak var paddingAboveNotificationsSwitch: UIView!
    @IBOutlet private weak var notificationSwitch: UISwitch!
    @IBOutlet private weak var paddingBelowNotificationsSwitch: UIView!
    @IBOutlet private weak var timesadayLabel: UILabel!
    @IBOutlet private weak var lineUnderNotifications: UIView!
    @IBOutlet private weak var expirationIntervalIcon: UIImageView!
    @IBOutlet private weak var expirationIntervalButton: UIButton!
    @IBOutlet private weak var expirationIntervalLabel: UILabel!
    @IBOutlet private weak var expirationIntervalArrowButton: UIButton!
    @IBOutlet private weak var lineUnderExpirationInterval: UIView!
    @IBOutlet private weak var expirationIntervalPicker: UIPickerView!
    @IBOutlet private weak var daysOneStack: UIStackView!
    @IBOutlet private weak var daysOneLabel: UILabel!
    @IBOutlet private weak var daysOneButton: UIButton!
    @IBOutlet private weak var daysOneArrowButton: UIButton!
    @IBOutlet private weak var lineUnderDaysOne: UIView!
    @IBOutlet private weak var daysTwoStack: UIStackView!
    @IBOutlet private weak var daysTwoLabel: UILabel!
    @IBOutlet private weak var daysTwoButton: UIButton!
    @IBOutlet private weak var daysTwoArrowButton: UIButton!
    @IBOutlet private weak var daysPositionStack: UIStackView!
    @IBOutlet private weak var daysPositionLabel: UILabel!
    @IBOutlet private weak var daysPositionVerticalLine: UIView!
    @IBOutlet private weak var daysPositionSetButton: UIButton!
    @IBOutlet private weak var lineUnderDaysPosition: UIView!
    @IBOutlet private weak var daysPicker: UIPickerView!
    @IBOutlet private weak var lineUnderDaysTwo: UIView!
    @IBOutlet private weak var timesadaySlider: UISlider!
    @IBOutlet private weak var timePickerOne: UIDatePicker!
    @IBOutlet private weak var timePickerTwo: UIDatePicker!
    @IBOutlet private weak var timePickerThree: UIDatePicker!
    @IBOutlet private weak var timePickerFour: UIDatePicker!
    @IBOutlet private weak var firstTimeLabel: UILabel!
    @IBOutlet private weak var secondTimeLabel: UILabel!
    @IBOutlet private weak var thirdTimeLabel: UILabel!
    @IBOutlet private weak var fourthTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegates()
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
        setPickerButtonTargets()
        enableSaveButton(doEnable: viewModel.hasUnsavedChanges)
        reflectPillAttributes()
        applyTheme()
    }

    static func createPillDetailVC(
        _ source: UIViewController, _ index: Index
    ) -> PillDetailViewController? {
        let viewController = createPillDetailVC(source)
        return viewController?.initWithPillIndex(index)
    }

    @objc func back() {
        checkForUnsavedChanges()
    }

    // MARK: - Pill actions

    @IBAction func selectNameTapped() {
        selectedPicker = namePicker
        openNamePicker()
        selectNameButton.setTitle(ActionStrings.Done)
        selectNameButton.replaceTarget(self, newAction: #selector(doneWithSelectNameTapped))
    }

    @objc func doneWithSelectNameTapped() {
        closeNamePicker()
        selectNameButton.setTitle(ActionStrings.Select)
        selectNameButton.replaceTarget(self, newAction: #selector(selectNameTapped))
        if viewModel.nameIsSelected {
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
        if viewModel.expirationIntervalIsSelected {
            enableSaveButton()
        }
        loadExpirationInterval()
    }

    @IBAction func daysOneButtonTapped(_ sender: Any) {
        selectedPicker = daysPicker
        selectedDaysNumber = 1
        openDaysPicker()
        daysOneButton.setTitle(ActionStrings.Done)
        daysOneButton.replaceTarget(
            self, newAction: #selector(doneWithDaysPickerTapped)
        )
    }

    @IBAction func daysTwoButtonTapped(_ sender: Any) {
        selectedPicker = daysPicker
        selectedDaysNumber = 2
        openDaysPicker()
        daysTwoButton.setTitle(ActionStrings.Done)
        daysTwoButton.replaceTarget(
            self, newAction: #selector(doneWithDaysPickerTapped)
        )
    }

    @IBAction func daysPositionButtonTapped(_ sender: Any) {
        selectedPicker = daysPicker
        selectedDaysNumber = 0
        openDaysPicker()
        daysPositionSetButton.setTitle(ActionStrings.Done)
        daysPositionSetButton.replaceTarget(
            self, newAction: #selector(doneWithDaysPickerTapped)
        )
    }

    @objc func doneWithDaysPickerTapped() {
        closeDaysPicker()
        let daysOnText = viewModel.daysOn
        let daysOffText = viewModel.daysOff
        daysOneButton.setTitle(daysOnText)
        daysOneButton.replaceTarget(self, newAction: #selector(daysOneButtonTapped(_:)))
        daysTwoButton.setTitle(daysOffText)
        daysTwoButton.replaceTarget(self, newAction: #selector(daysTwoButtonTapped(_:)))
        if viewModel.daysSelected {
            enableSaveButton()
        }
        daysPositionSetButton.setTitle(
            NSLocalizedString("Set", comment: "small button text")
        )
        daysPositionSetButton.replaceTarget(self, newAction: #selector(daysPositionButtonTapped(_:)))
        loadExpirationIntervalDays()
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
        viewModel.enableOrDisable(timePickers, timeLabels)
        viewModel.setPickerTimes(timePickers)
        enableSaveButton()
    }

    // MARK: - Picker functions

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        DefaultNumberOfPickerComponents
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectedPicker == namePicker {
            return viewModel.nameOptions.count
        } else if selectedPicker == expirationIntervalPicker {
            return viewModel.expirationIntervalOptions.count
        } else if selectedPicker == daysPicker {
            return viewModel.getOptionsForSelectedPicker(selectedDaysNumber).count
        }
        return DefaultNumberOfPickerComponents
    }

    func pickerView(
        _ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int
    ) -> NSAttributedString? {
        var title = "start_"
        if selectedPicker == namePicker {
            title = viewModel.nameOptions.tryGet(at: row) ?? ""
        } else if selectedPicker == expirationIntervalPicker {
            title = viewModel.expirationIntervalOptions.tryGet(at: row) ?? ""
        } else if selectedPicker == daysPicker {
            let options = viewModel.getOptionsForSelectedPicker(selectedDaysNumber)
            title = options.tryGet(at: row) ?? ""
        }
        return NSAttributedString(
            string: title, attributes: [NSAttributedString.Key.foregroundColor: PDColors[.Text]]
        )
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        enableSaveButton()
        if selectedPicker == namePicker {
            viewModel.selectName(row)
            nameTextField.text = viewModel.name
        } else if selectedPicker == expirationIntervalPicker {
            viewModel.selectExpirationInterval(row)
        } else if selectedPicker == daysPicker {
            viewModel.selectFromDaysPicker(row, daysNumber: selectedDaysNumber)
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

    /// Prevents the text field from exceededing a reasonable limit of characters.
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        let result = TextFieldHelper.canSet(
            currentString: currentText, replacementString: string, range: range
        )
        if result.canReplace {
            viewModel.selections.name = result.updatedText
            enableSaveButton()
        }
        return result.canReplace
    }

    // MARK: - Private loaders

    private func setPickerDelegates() {
        namePicker.delegate = self
        nameTextField.delegate = self
        expirationIntervalPicker.delegate = self
        daysPicker.delegate = self
    }

    private func setPickerButtonTargets() {
        if namePicker.isHidden {
            selectNameButton.replaceTarget(
                self, newAction: #selector(selectNameTapped), for: .touchUpInside
            )
        } else {
            selectNameButton.replaceTarget(self, newAction: #selector(doneWithSelectNameTapped))
        }

        if expirationIntervalPicker.isHidden {
            expirationIntervalButton.replaceTarget(self, newAction: #selector(expirationIntervalTapped))
        } else {
            expirationIntervalButton.replaceTarget(
                self, newAction: #selector(doneWithSelectExpirationIntervalTapped)
            )
        }
    }

    private func loadTitle() {
        title = viewModel.title
    }

    private func reflectPillAttributes() {
        guard viewModel.pill != nil else {
            // Remove outdated observer
            NotificationCenter.default.removeObserver(
                self,
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
            return
        }
        loadName()
        loadTimes()
        loadNotify()
        loadExpirationInterval()
    }

    private func loadName() {
        nameTextField.text = viewModel.name
    }

    private func loadNotify() {
        notificationSwitch.isOn = viewModel.notify
    }

    private func loadTimes() {
        let timesaday = viewModel.timesaday
        timesadaySlider.setValue(Float(timesaday), animated: false)
        updateTimesdayValueLabel()
        loadTimePickers()
    }

    private func updateTimesdayValueLabel() {
        timesadayLabel.text = viewModel.timesadayText
    }

    private func loadExpirationInterval() {
        let pickerHidden = expirationIntervalPicker.isHidden
        let title = pickerHidden ? viewModel.expirationIntervalText : ActionStrings.Done
        expirationIntervalButton.setTitle(title)
        loadExpirationIntervalDays()
    }

    private func loadExpirationIntervalDays() {
        hideOrUnhideDaysStack()
        guard daysPicker.isHidden else { return }
        daysOneLabel.text = viewModel.daysOneLabelText
        daysOneButton.setTitle(viewModel.daysOn)
        daysTwoLabel.text = viewModel.daysTwoLabelText
        daysTwoButton.setTitle(viewModel.daysOff)
        daysPositionLabel.text = viewModel.daysPositionText
    }

    private func hideOrUnhideDaysStack() {
        let usesDays = viewModel.expirationIntervalUsesDays
        let usesDaysOnDaysOff = viewModel.expirationInterval == .XDaysOnXDaysOff
        daysOneStack.isHidden = !usesDays
        daysTwoStack.isHidden = !usesDays
        lineUnderDaysOne.isHidden = !usesDays
        daysTwoStack.isHidden = !usesDaysOnDaysOff
        lineUnderDaysTwo.isHidden = !usesDaysOnDaysOff
        daysPositionStack.isHidden = !usesDaysOnDaysOff
        lineUnderDaysPosition.isHidden = !usesDaysOnDaysOff
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

    private func openNamePicker() {
        nameTextField.isEnabled = false
        unhideNamePicker()
        setNamePickerStartIndex()
    }

    private func openExpirationIntervalPicker() {
        if !daysPicker.isHidden {
            closeDaysPicker()
        }
        expirationIntervalArrowButton.isEnabled = false
        daysOneButton.isEnabled = false
        daysTwoButton.isEnabled = false
        daysOneArrowButton.isEnabled = false
        daysTwoArrowButton.isEnabled = false
        unhideExpirationIntervalPicker()
        setExpirationIntervalPickerStartIndex()
        expirationIntervalPicker.isHidden = false
        daysPositionSetButton.isEnabled = false
    }

    private func openDaysPicker() {
        if !expirationIntervalPicker.isHidden {
            closeExpirationIntervalPicker()
        }
        if selectedDaysNumber == 1 {
            daysTwoButton.isEnabled = false
            daysPositionSetButton.isEnabled = false

        } else if selectedDaysNumber == 2 {
            daysOneButton.isEnabled = false
            daysPositionSetButton.isEnabled = false
        } else {
            daysOneButton.isEnabled = false
            daysTwoButton.isEnabled = false
        }

        daysOneArrowButton.isEnabled = false
        daysTwoArrowButton.isEnabled = false
        expirationIntervalButton.isEnabled = false
        expirationIntervalArrowButton.isEnabled = false
        unhideDaysPicker()
        setDaysPickerStartIndex()
    }

    private func unhideNamePicker() {
        PillDetailViewController.unhidePicker(namePicker)
    }

    private func unhideExpirationIntervalPicker() {
        PillDetailViewController.unhidePicker(expirationIntervalPicker)
    }

    private func unhideDaysPicker() {
        PillDetailViewController.unhidePicker(daysPicker)
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

    private func setNamePickerStartIndex() {
        let nameIndex = viewModel.namePickerStartIndex
        namePicker.selectRow(nameIndex, inComponent: 0, animated: false)
    }

    private func setExpirationIntervalPickerStartIndex() {
        let index = viewModel.expirationIntervalStartIndex
        expirationIntervalPicker.selectRow(index, inComponent: 0, animated: false)
    }

    private func setDaysPickerStartIndex() {
        let index = viewModel.getStartIndexForDaysPicker(pickerNumber: selectedDaysNumber)
        daysPicker.selectRow(index, inComponent: 0, animated: false)
    }

    private func closeNamePicker() {
        setNamePickerStartIndex()
        nameTextField.isEnabled = true
        namePicker.isHidden = true
        selectedPicker = nil
        expirationIntervalArrowButton.isEnabled = true
    }

    private func closeExpirationIntervalPicker() {
        setExpirationIntervalPickerStartIndex()
        expirationIntervalPicker.isHidden = true
        selectedPicker = nil
        daysOneButton.isEnabled = true
        daysTwoButton.isEnabled = true
        daysOneArrowButton.isEnabled = true
        daysTwoArrowButton.isEnabled = true
        expirationIntervalArrowButton.isEnabled = true
        daysPositionSetButton.isEnabled = true
    }

    private func closeDaysPicker() {
        setDaysPickerStartIndex()
        daysPicker.isHidden = true
        selectedPicker = nil
        expirationIntervalButton.isEnabled = true
        expirationIntervalArrowButton.isEnabled = true
        daysOneButton.isEnabled = true
        daysOneArrowButton.isEnabled = true
        daysTwoButton.isEnabled = true
        daysTwoArrowButton.isEnabled = true
        daysPositionSetButton.isEnabled = true
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
        viewModel.setPickerTimes(timePickers)
    }

    private func loadTimePickers() {
        loadTimePickerEventHandlers()
        viewModel.setPickerTimes(timePickers)
        viewModel.enableOrDisable(timePickers, timeLabels)
    }

    private var timePickers: [UIDatePicker] {
        [timePickerOne, timePickerTwo, timePickerThree, timePickerFour]
    }

    private var timeLabels: [UILabel] {
        [firstTimeLabel, secondTimeLabel, thirdTimeLabel, fourthTimeLabel]
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
        timePickerOne.preferredDatePickerStyle = .compact
        timePickerTwo.preferredDatePickerStyle = .compact
        timePickerThree.preferredDatePickerStyle = .compact
        timePickerFour.preferredDatePickerStyle = .compact
    }

    private func enableSaveButton(doEnable: Bool = true) {
        navigationItem.rightBarButtonItem?.isEnabled = doEnable
    }

    private func segueToPillsVC() {
        guard let navCon = navigationController else { return }
        navCon.popViewController(animated: true)
    }

    private static func createPillDetailVC(
        _ source: UIViewController
    ) -> PillDetailViewController? {
        source.storyboard?.instantiateViewController(
            withIdentifier: ViewControllerIds.PillDetail
        ) as? PillDetailViewController
    }

    private func initWithPillIndex(_ index: Index) -> PillDetailViewController {
        viewModel = PillDetailViewModel(index)
        return self
    }

    private func applyTheme() {
        // Background spaces
        view.backgroundColor = UIColor.systemBackground
        detailStack.backgroundColor = UIColor.systemBackground
        paddingAboveNotificationsSwitch.backgroundColor = UIColor.systemBackground
        timesadaySlider.backgroundColor = UIColor.systemBackground
        paddingBelowNotificationsSwitch.backgroundColor = UIColor.systemBackground

        // Icons
        notificationsIcon.image = notificationsIcon.image?.withTintColor(PDColors[.Text])
        expirationIntervalIcon.image = expirationIntervalIcon.image?.withTintColor(PDColors[.Text])
        notificationsIcon.tintColor = PDColors[.Text]

        // Labels
        drugNameLabel.textColor = PDColors[.Text]
        notificationsLabel.textColor = PDColors[.Text]
        expirationIntervalLabel.textColor = PDColors[.Text]
        daysOneLabel.textColor = PDColors[.Text]
        daysTwoLabel.textColor = PDColors[.Text]
        daysPositionLabel.textColor = PDColors[.Text]
        timesadayLabel.textColor = PDColors[.Text]

        // Lines
        lineUnderDrugNameLabel.backgroundColor = PDColors[.Border]
        verticalLineInDrugNameStack.backgroundColor = PDColors[.Border]
        lineUnderDrugNameStack.backgroundColor = PDColors[.Border]
        lineUnderNotifications.backgroundColor = PDColors[.Border]
        lineUnderExpirationInterval.backgroundColor = PDColors[.Border]
        lineUnderDaysOne.backgroundColor = PDColors[.Border]
        lineUnderDaysTwo.backgroundColor = PDColors[.Border]
        daysPositionVerticalLine.backgroundColor = PDColors[.Border]
        lineUnderDaysPosition.backgroundColor = PDColors[.Border]

        // Button enabled states
        selectNameButton.setTitleColor(PDColors[.Button])
        expirationIntervalButton.setTitleColor(PDColors[.Button])
        daysOneButton.setTitleColor(PDColors[.Button])
        daysTwoButton.setTitleColor(PDColors[.Button])
        daysPositionSetButton.setTitleColor(PDColors[.Button])
        saveButton.tintColor = PDColors[.Button]
        nameTextField.textColor = PDColors[.Button]

        // Disabled button colors
        selectNameButton.setTitleColor(PDColors[.Unselected], for: .disabled)
        expirationIntervalButton.setTitleColor(PDColors[.Unselected], for: .disabled)
        daysOneButton.setTitleColor(PDColors[.Unselected], for: .disabled)
        daysTwoButton.setTitleColor(PDColors[.Unselected], for: .disabled)
        daysPositionSetButton.setTitleColor(PDColors[.Unselected], for: .disabled)
    }
}

extension PillDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { detailsView }
}
