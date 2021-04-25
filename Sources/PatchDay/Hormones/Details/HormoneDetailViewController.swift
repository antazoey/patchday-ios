//
//  HormoneDetailViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.

import UIKit
import PDKit

class HormoneDetailViewController: UIViewController,
    UIPickerViewDelegate,
    UIPickerViewDataSource,
    UITextFieldDelegate {

    var viewModel: HormoneDetailViewModelProtocol!
    private lazy var log = PDLog<HormoneDetailViewController>()

    private var saveButton: UIBarButtonItem!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dateAndTimeAppliedHeader: UILabel!
    @IBOutlet private weak var lineUnderDateInputView: UIView!
    @IBOutlet private weak var datePicker: HormoneDatePicker!
    @IBOutlet private weak var lineUnderScheduleDate: UIView!
    @IBOutlet private weak var lineUnderDateAndTimeAppliedLabel: UIView!
    @IBOutlet private weak var bigGapUnderDateAppliedViews: UIView!
    @IBOutlet private weak var expirationDateLabelHeader: UILabel!
    @IBOutlet private weak var expirationDateLabel: UILabel!
    @IBOutlet private weak var lineUnderExpirationDate: UIView!
    @IBOutlet private weak var bigGapUnderExpirationDateViews: UIView!
    @IBOutlet private weak var horizontalLineAboveSite: UIView!
    @IBOutlet private weak var siteStackView: UIStackView!
    @IBOutlet private weak var siteLabel: UILabel!
    @IBOutlet private weak var selectSiteTextField: UITextField!
    @IBOutlet private weak var verticalLineInSiteStack: UIView!
    @IBOutlet private weak var typeSiteButton: UIButton!
    @IBOutlet private weak var sitePicker: UIPickerView!
    @IBOutlet private weak var horizontalLineBelowSite: UIView!
    @IBOutlet private weak var autofillButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTitle()
        willEnterForeground()
        setBackButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        willEnterForeground()
        super.viewDidAppear(animated)
    }

    private func checkForUnsavedChanges() {
        guard let viewModel = viewModel else { return }
        viewModel.handleIfUnsaved(self)
    }

    @objc func willEnterForeground() {
        loadSiteControls()
        loadSaveButton()
        loadAutofillButton()
        loadDateControls()
        applyTheme()
    }

    static func create(
        _ source: UIViewController, _ index: Index
    ) -> HormoneDetailViewController? {
        let viewController = create(source)
        return viewController?.initWithHormoneIndex(index)
    }

    static func create(
        source: UIViewController, viewModel: HormoneDetailViewModel
    ) -> HormoneDetailViewController? {
        let viewController = create(source)
        return viewController?.initWithViewModel(viewModel)
    }

    private static func create(_ source: UIViewController) -> HormoneDetailViewController? {
        source.storyboard?.instantiateViewController(
            withIdentifier: ViewControllerIds.HormoneDetail
        ) as? HormoneDetailViewController
    }

    private func initWithHormoneIndex(_ index: Index) -> HormoneDetailViewController {
        let viewModel = HormoneDetailViewModel(index, {
            () in self.sitePicker.reloadAllComponents()
        })
        return initWithViewModel(viewModel)
    }

    private func initWithViewModel(
        _ viewModel: HormoneDetailViewModel
    ) -> HormoneDetailViewController {
        self.viewModel = viewModel
        return self
    }

    // MARK: TextField delegate functions

    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectSiteTextField.isUserInteractionEnabled = true
        datePicker.isEnabled = false
        autofillButton.isHidden = true
        typeSiteButton.setTitle(ActionStrings.Done)
        let id = textField.restorationIdentifier ?? ""
        if let senderType = TextFieldButtonSenderType(rawValue: id) {
            handleSenderType(senderType, textFieldSender: textField)
        }
    }

    /// Prevents the text field from exceededing a reasonable limit of characters.
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentString = textField.text ?? ""
        return MaxString.canSet(
            currentString: currentString, replacementString: string, range: range
        )
    }

    @objc func closeSiteTextField() {
        guard let viewModel = viewModel else { return }
        let siteNameTyped = viewModel.extractSiteNameFromTextField(selectSiteTextField)
        typeSiteButton.setTitle(ActionStrings._Type)
        selectSiteTextField.endEditing(true)
        selectSiteTextField.isEnabled = true
        datePicker.isEnabled = true
        autofillButton.isHidden = false
        selectSiteTextField.isHidden = false
        saveButton.isEnabled = true
        typeSiteButton.replaceTarget(self, newAction: #selector(keyboardTapped(_:)))
        if siteNameTyped == "" {
            selectSiteTextField.text = viewModel.selectSiteStartText
        } else {
            viewModel.presentNewSiteAlert(newSiteName: siteNameTyped)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeSiteTextField()
        return true
    }

    @IBAction private func keyboardTapped(_ sender: Any) {
        let id = TextFieldButtonSenderType.DefaultTextFieldEditor.rawValue
        selectSiteTextField.restorationIdentifier = id
        selectSiteTextField.becomeFirstResponder()
    }

    // MARK: - Picker Functions

    @IBAction func openSitePicker(_ sender: Any) {
        showSitePicker()
        sitePicker.selectRow(viewModel.siteStartRow, inComponent: 0, animated: false)
        autofillButton.isHidden = true
        autofillButton.isEnabled = false
        selectSiteTextField.isEnabled = false
    }

    @objc func closeSitePicker() {
        sitePicker.isHidden = true
        datePicker.isEnabled = true
        autofillButton.isEnabled = true
        selectSiteTextField.isEnabled = true
        selectSiteTextField.isHidden = false
        autofillButton.isHidden = false
        saveButton.isEnabled = true
        typeSiteButton.setTitle(ActionStrings._Type)
        typeSiteButton.replaceTarget(self, newAction: #selector(keyboardTapped(_:)))
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        DefaultNumberOfPickerComponents
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.siteCount
    }

    func pickerView(
        _ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int
    ) -> NSAttributedString? {
        guard let title = viewModel.getSiteName(at: row) else { return nil }
        return NSAttributedString(
            string: title, attributes: [NSAttributedString.Key.foregroundColor: PDColors[.Text]]
        )
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let siteName = viewModel.trySelectSite(at: row) else { return }
        selectSiteTextField.text = siteName
    }

    // MARK: Other UI

    @objc private func saveButtonTapped(_ sender: Any) {
        guard let viewModel = viewModel else { return }
        viewModel.saveSelections()
        viewModel.nav?.pop(source: self)
    }

    @IBAction private func autofillTapped(_ sender: Any) {
        autoSetSiteText()
        autoSetDate()
        saveButton.isEnabled = true
    }

    // MARK: - Private

    private func loadTitle() {
        title = PDTitleStrings.EditHormoneTitle
    }

    @objc func selectDateFromPicker() {
        viewModel.dateSelected = datePicker.date
        saveButton.isEnabled = true
    }

    private func loadDateControls() {
        guard let viewModel = viewModel else { return }
        guard let viewStrings = viewModel.createHormoneViewStrings() else { return }
        datePicker.preferredDatePickerStyle = .compact
        expirationDateLabelHeader.text = viewStrings.expirationText
        dateAndTimeAppliedHeader.text = viewStrings.dateAndTimePlacedText
        siteLabel.text = viewStrings.siteLabelText
        expirationDateLabel.text = viewModel.expirationDateText
        datePicker.date = viewModel.datePickerDate
        datePicker.addTarget(self, action: #selector(selectDateFromPicker), for: .allEditingEvents)
    }

    private func loadSiteControls() {
        if let viewModel = viewModel {
            selectSiteTextField.text = viewModel.selectSiteStartText
        }
        let id = TextFieldButtonSenderType.PickerActivator.rawValue
        selectSiteTextField.restorationIdentifier = id
        selectSiteTextField.autocapitalizationType = .words
        selectSiteTextField.delegate = self
        sitePicker.delegate = self
        sitePicker.dataSource = self
        typeSiteButton.setTitle(ActionStrings._Type)
    }

    private func loadSaveButton() {
        let save = ActionStrings.Save
        let handleSave = #selector(saveButtonTapped(_:))
        saveButton = UIBarButtonItem(title: save, style: .plain, target: self, action: handleSave)
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
    }

    private func loadAutofillButton() {
        autofillButton.setTitleColor(UIColor.darkGray, for: UIControl.State.disabled)
        if AppDelegate.isPad {
            topConstraint.constant = 100
            autofillButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        }
    }

    private func showSitePicker() {
        UIView.transition(
            with: sitePicker as UIView,
            duration: 0.4,
            options: .transitionCrossDissolve,
            animations: { self.sitePicker.isHidden = false },
            completion: nil
        )
    }

    private func autoSetSiteText() {
        selectSiteTextField.text = viewModel.selectSuggestedSite()
    }

    private func autoSetDate() {
        datePicker.date = viewModel.autoPickedDate
    }

    private func handleSenderType(
        _ senderType: TextFieldButtonSenderType?, textFieldSender: UITextField
    ) {
        if senderType == .PickerActivator {
            handleTextFieldButtonOpeningPicker(typeButton: typeSiteButton)
            openSitePicker(textFieldSender)
        } else {
            handleTextFieldBeginEditing(textFieldSender, typeButton: typeSiteButton)
        }
    }

    private func handleTextFieldBeginEditing(_ textField: UITextField, typeButton: UIButton) {
        selectSiteTextField.isEnabled = true
        selectSiteTextField.text = ""
        textField.restorationIdentifier = TextFieldButtonSenderType.PickerActivator.rawValue
        typeButton.replaceTarget(self, newAction: #selector(closeSiteTextField))
    }

    private func handleTextFieldButtonOpeningPicker(typeButton: UIButton) {
        view.endEditing(true)
        selectSiteTextField.isEnabled = false
        typeButton.replaceTarget(self, newAction: #selector(closeSitePicker))
    }

    private func hideLines() {
        lineUnderScheduleDate.isHidden = true
        lineUnderDateAndTimeAppliedLabel.isHidden = true
        lineUnderExpirationDate.isHidden = true
        horizontalLineAboveSite.isHidden = true
        horizontalLineBelowSite.isHidden = true
        verticalLineInSiteStack.isHidden = true
    }

    private func unhideLines() {
        lineUnderScheduleDate.isHidden = false
        lineUnderDateAndTimeAppliedLabel.isHidden = false
        lineUnderExpirationDate.isHidden = false
        horizontalLineAboveSite.isHidden = false
        horizontalLineBelowSite.isHidden = false
        verticalLineInSiteStack.isHidden = false
    }

    @objc func back() {
        checkForUnsavedChanges()
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

    private func applyTheme() {
        // Containers
        view.backgroundColor = UIColor.systemBackground
        lineUnderScheduleDate.backgroundColor = PDColors[.Border]
        lineUnderDateAndTimeAppliedLabel.backgroundColor = PDColors[.Border]
        lineUnderDateInputView.backgroundColor = PDColors[.Border]
        bigGapUnderDateAppliedViews.backgroundColor = UIColor.systemBackground
        lineUnderExpirationDate.backgroundColor = PDColors[.Border]
        bigGapUnderExpirationDateViews.backgroundColor = UIColor.systemBackground
        horizontalLineAboveSite.backgroundColor = PDColors[.Border]
        siteStackView.backgroundColor = UIColor.systemBackground
        verticalLineInSiteStack.backgroundColor = PDColors[.Border]
        horizontalLineBelowSite.backgroundColor = PDColors[.Border]

        // Labels
        dateAndTimeAppliedHeader.textColor = PDColors[.Text]
        expirationDateLabelHeader.textColor = PDColors[.Text]
        expirationDateLabel.textColor = PDColors[.Text]
        siteLabel.textColor = PDColors[.Text]

        // Textfields
        selectSiteTextField.textColor = PDColors[.Purple]

        // Buttons
        typeSiteButton.setTitleColor(PDColors[.Button])
        autofillButton.setTitleColor(PDColors[.Button])
        saveButton.tintColor = PDColors[.Button]

        datePicker.backgroundColor = PDColors[.OddCell]
    }
}
