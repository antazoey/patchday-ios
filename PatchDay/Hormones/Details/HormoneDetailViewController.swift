//
//  HormoneDetailVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class HormoneDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    var viewModel: HormoneDetailViewModel!
    var log = PDLog<HormoneDetailViewController>()

    private var saveButton: UIBarButtonItem!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dateAndTimeAppliedHeader: UILabel!
    @IBOutlet private weak var selectSiteTextField: UITextField!
    @IBOutlet private weak var selectDateButton: UIButton!
    @IBOutlet private weak var datePickerInputView: UIView!
    @IBOutlet private weak var datePicker: UIDatePicker!
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
    @IBOutlet private weak var verticalLineInSiteStack: UIView!
    @IBOutlet private weak var typeSiteButton: UIButton!
    @IBOutlet private weak var sitePicker: UIPickerView!
    @IBOutlet private weak var horizontalLineBelowSite: UIView!
    @IBOutlet private weak var autofillButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTitle()
        loadSiteControls()
        loadSaveButton()
        loadAutofillButton()
        loadDateControls()
        loadSiteControls()
    }

    override func viewWillAppear(_ animated: Bool) {
        applyTheme()
        super.viewDidAppear(animated)
    }

    static func createHormoneDetailVC(_ source: UIViewController, _ hormone: Hormonal) -> HormoneDetailViewController? {
        let id = ViewControllerIds.HormoneDetail
        if let hormoneVC = source.storyboard?.instantiateViewController(withIdentifier: id) as? HormoneDetailViewController {
            return hormoneVC.initWithHormone(hormone)
        }
        return nil
    }

    static func createHormoneDetailVC(source: UIViewController, viewModel: HormoneDetailViewModel) -> HormoneDetailViewController? {
        let id = ViewControllerIds.HormoneDetail
        if let hormoneVC = source.storyboard?.instantiateViewController(withIdentifier: id) as? HormoneDetailViewController {
            return hormoneVC.initWithViewModel(viewModel)
        }
        return nil
    }
    
    fileprivate func initWithHormone(_ hormone: Hormonal) -> HormoneDetailViewController {
        let viewModel = HormoneDetailViewModel(hormone, { () in self.sitePicker.reloadAllComponents() })
        return initWithViewModel(viewModel)
    }

    fileprivate func initWithViewModel(_ viewModel: HormoneDetailViewModel) -> HormoneDetailViewController {
        self.viewModel = viewModel
        return self
    }

    // MARK: TextField delegate functions

    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectSiteTextField.isUserInteractionEnabled = true
        selectDateButton.isEnabled = false
        autofillButton.isHidden = true
        typeSiteButton.setTitle(ActionStrings.Done)

        if let senderType = TextFieldButtonSenderType(rawValue: textField.restorationIdentifier ?? "") {
            handleSenderType(senderType, textFieldSender: textField)
        }
    }
    
    @objc func closeTextField() {
        if let viewModel = viewModel {
            let siteNameTyped = viewModel.extractSiteNameFromTextField(selectSiteTextField)
            typeSiteButton.setTitle(ActionStrings._Type)
            selectSiteTextField.endEditing(true)
            selectSiteTextField.isEnabled = true
            selectDateButton.isEnabled = true
            autofillButton.isHidden = false
            selectSiteTextField.isHidden = false
            saveButton.isEnabled = true
            typeSiteButton.replaceTarget(self, newAction: #selector(keyboardTapped(_:)))
            viewModel.presentNewSiteAlert(source: self, newSiteName: siteNameTyped)
        }
    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeTextField()
        return true
    }

    @IBAction private func keyboardTapped(_ sender: Any) {
        selectSiteTextField.restorationIdentifier = TextFieldButtonSenderType.DefaultTextFieldEditor.rawValue
        selectSiteTextField.becomeFirstResponder()
    }
    
    // MARK: - Picker Functions
    
    @IBAction func openSitePicker(_ sender: Any) {
        showSitePicker()
        sitePicker.selectRow(viewModel.siteIndexStartRow, inComponent: 0, animated: false)
        autofillButton.isHidden = true
        autofillButton.isEnabled = false
        selectSiteTextField.isEnabled = false
        selectDateButton.isEnabled = false
    }
    
    @objc func closeSitePicker() {
        sitePicker.isHidden = true
        autofillButton.isEnabled = true
        selectDateButton.isEnabled = true
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
        viewModel.sitesCount
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.sdk?.sites.names.tryGet(at: row) ?? ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let siteName = viewModel.trySelectSite(at: row) {
            selectSiteTextField.text = siteName
            closeSitePicker()
        }
    }

    // MARK: - Date Picker funcs
    
    @IBAction func selectDateTextTapped(_ sender: Any) {
        datePicker.date = viewModel.dateSelected
        let doneButtonFactory = DoneButtonFactory()
        let doneButton = doneButtonFactory.createDoneButton(doneAction: #selector(datePickerDone), mainView: view)
        datePickerInputView.addSubview(doneButton)
        autofillButton.isHidden = true
        selectDateButton.isEnabled = false
        typeSiteButton.isEnabled = false
        selectSiteTextField.isEnabled = false
        showDatePicker()
    }
    
    @objc func datePickerDone(_ sender: Any) {
        let doneButton = sender as! UIButton
        doneButton.removeFromSuperview()
        datePickerInputView.isHidden = true
        viewModel.dateSelected = datePicker.date
        selectDateButton.setTitle(viewModel.dateSelectedText, for: UIControl.State.normal)
        expirationDateLabel.text = viewModel.expirationDateText
        saveButton.isEnabled = true
        selectDateButton.isEnabled = true
        typeSiteButton.isEnabled = true
        autofillButton.isHidden = false
        siteStackView.isHidden = false
        siteLabel.isHidden = false
        selectSiteTextField.isEnabled = true
    }

    // MARK: Other UI

    @objc private func saveButtonTapped(_ sender: Any) {
        if let viewModel = viewModel {
            viewModel.saveFromSelectionState()
            viewModel.nav?.pop(source: self)
        }
    }

    @IBAction private func autofillTapped(_ sender: Any) {
        autoSetSiteText()
        autoSetDateText()
        saveButton.isEnabled = true
    }

    // MARK: - Private

    private func loadTitle() {
        title = VCTitleStrings.getTitle(for: viewModel.sdk?.defaults.deliveryMethod.value ?? DefaultDeliveryMethod)
    }

    private func loadDateControls() {
        if let viewModel = viewModel {
            let viewStrings = viewModel.createHormoneViewStrings()
            selectDateButton.setTitle(viewModel.selectDateButtonStartText)
            expirationDateLabelHeader.text = viewStrings.expirationText
            dateAndTimeAppliedHeader.text = viewStrings.dateAndTimePlacedText
            siteLabel.text = viewStrings.siteLabelText
            expirationDateLabel.text  = viewModel.expirationDateText
        }
    }

    private func loadSiteControls() {
        if let viewModel = viewModel {
            selectSiteTextField.text = viewModel.selectSiteTextFieldStartText
        }
        selectSiteTextField.autocapitalizationType = .words
        selectSiteTextField.restorationIdentifier = TextFieldButtonSenderType.PickerActivator.rawValue
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

    private func showDatePicker() {
        UIView.transition(
            with: datePickerInputView as UIView,
            duration: 0.4,
            options: .transitionCrossDissolve,
            animations: { self.datePickerInputView.isHidden = false },
            completion: nil
        )
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
        if let nextSite = viewModel.sdk?.sites.suggested {
            selectSiteTextField.text = nextSite.name
            viewModel.selectionState.selectedSite = nextSite
        } else {
            log.error("Failed auto picking next site.")
        }
    }
    
    private func autoSetDateText() {
        if let viewModel = viewModel {
            selectDateButton.setTitle(viewModel.autoPickedDateText)
            expirationDateLabel.text = viewModel.autoPickedExpirationDateText
        } else {
            log.error("Failed auto picking next date.")
        }
    }

    private func handleSenderType(_ senderType: TextFieldButtonSenderType?, textFieldSender: UITextField) {
        switch senderType {
        case .PickerActivator:
            handleTextFieldButtonOpeningPicker(typeButton: typeSiteButton)
            openSitePicker(textFieldSender)
        default:
            handleTextFieldBeginEditing(textFieldSender, typeButton: typeSiteButton)
        }
    }

    private func handleTextFieldBeginEditing(_ textField: UITextField, typeButton: UIButton) {
        selectSiteTextField.isEnabled = true
        selectSiteTextField.text = ""
        textField.restorationIdentifier = TextFieldButtonSenderType.PickerActivator.rawValue
        typeButton.replaceTarget(self, newAction: #selector(closeTextField))
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

    private func applyTheme() {
        if let theme = viewModel.styles?.theme {
            view.backgroundColor = theme[.bg]
            selectSiteTextField.textColor = theme[.purple]
            selectDateButton.setTitleColor(theme[.purple])
        }
    }
}
