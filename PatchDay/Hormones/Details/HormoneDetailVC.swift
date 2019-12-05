//
//  HormoneDetailVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class HormoneDetailVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    private var viewModel: HormoneDetailViewModel?

    private var saveButton: UIBarButtonItem!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dateAndTimePlaced: UILabel!
    @IBOutlet private weak var selectSiteTextField: UITextField!
    @IBOutlet private weak var chooseDateButton: UIButton!
    @IBOutlet private weak var datePickerInputView: UIView!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var lineUnderScheduleDate: UIView!
    @IBOutlet private weak var lineUnderDate: UIView!
    @IBOutlet private weak var lineUnderDateAndTimePlaced: UIView!
    @IBOutlet private weak var bigGap: UIView!
    @IBOutlet private weak var expLabel: UILabel!
    @IBOutlet private weak var expirationDateLabel: UILabel!
    @IBOutlet private weak var lineUnderExpires: UIView!
    @IBOutlet private weak var bigGap2: UIView!
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
        loadExpirationText()
        loadSiteControls()
        loadSaveButton()
        loadAutofillButton()
        loadExpirationText()
        loadSiteControls()
    }

    public func initWithViewModel(_ viewModel: HormoneDetailViewModel) -> HormoneDetailVC {
        self.viewModel = viewModel
        return self
    }
    
    static func createHormoneDetailVC(_ source: UIViewController, _ hormone: Hormonal) -> HormoneDetailVC? {
        createHormoneDetailVC(source: source, hormoneDetailsCodeBehind: HormoneDetailViewModel(hormone))
    }

    static func createHormoneDetailVC(source: UIViewController, viewModel: HormoneDetailViewModel) -> HormoneDetailVC? {
        let id = HormoneDetailViewModel.viewControllerId
        if let hormoneVC = source.storyboard?.instantiateViewController(withIdentifier: id) as? HormoneDetailVC {
            return hormoneVC.initWithViewModel(viewModel)
        }
        return nil
    }

    // MARK: TextField delegate functions

    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectSiteTextField.isUserInteractionEnabled = true
        chooseDateButton.isEnabled = false
        autofillButton.isHidden = true
        typeSiteButton.setTitle(ActionStrings.done, for: .normal)

        if let senderType = TextFieldButtonSenderType(rawValue: textField.restorationIdentifier ?? "") {
            handleSenderType(senderType, textFieldSender: textField)
        }
    }
    
    @objc func closeTextField() {
        if let viewModel = viewModel {
            let siteNameTyped = viewModel.extractSiteNameFromTextField(selectSiteTextField)
            typeSiteButton.setTitle(ActionStrings.type, for: .normal)
            selectSiteTextField.endEditing(true)
            selectSiteTextField.isEnabled = true
            chooseDateButton.isEnabled = true
            autofillButton.isHidden = false
            selectSiteTextField.isHidden = false
            saveButton.isEnabled = true
            typeSiteButton.replaceTarget(self, newAction: #selector(keyboardTapped(_:)))
            viewModel.selectionState.siteIndexSelected = viewModel.sitesCount
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
        sitePicker.selectRow(viewModel?.siteIndexStartRow ?? 0, inComponent: 0, animated: false)
        autofillButton.isHidden = true
        autofillButton.isEnabled = false
        selectSiteTextField.isEnabled = false
        chooseDateButton.isEnabled = false
    }
    
    @objc func closeSitePicker() {
        sitePicker.isHidden = true
        autofillButton.isEnabled = true
        chooseDateButton.isEnabled = true
        selectSiteTextField.isEnabled = true
        selectSiteTextField.isHidden = false
        autofillButton.isHidden = false
        saveButton.isEnabled = true
        typeSiteButton.setTitle(ActionStrings.type, for: .normal)
        typeSiteButton.replaceTarget(self, newAction: #selector(keyboardTapped(_:)))
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        DefaultNumberOfPickerComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel?.sitesCount ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel?.sdk?.sites.names.tryGet(at: row) ?? ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let siteName = viewModel?.selectSite(at: row) {
            selectSiteTextField.text = siteName
            closeSitePicker()
        }
    }

    // MARK: - Date Picker funcs
    
    @IBAction func chooseDateTextTapped(_ sender: Any) {
        datePicker.date = viewModel?.dateSelected ?? datePicker.date
        let doneButtonFactory = DoneButtonFactory()
        let doneButton = doneButtonFactory.createDoneButton(doneAction: #selector(datePickerDone), mainView: view)
        datePickerInputView.addSubview(doneButton)
        autofillButton.isHidden = true
        chooseDateButton.isEnabled = false
        typeSiteButton.isEnabled = false
        selectSiteTextField.isEnabled = false
        showDatePicker()
    }
    
    @objc func datePickerDone(_ sender: Any) {
        let doneButton = sender as! UIButton
        doneButton.removeFromSuperview()
        datePickerInputView.isHidden = true
        viewModel?.dateSelected = datePicker.date
        chooseDateButton.setTitle(viewModel?.dateSelectedText, for: UIControl.State.normal)
        expirationDateLabel.text = viewModel?.expirationDateText
        saveButton.isEnabled = true
        chooseDateButton.isEnabled = true
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
        title = VCTitleStrings.getTitle(for: viewModel?.sdk?.defaults.deliveryMethod.value ?? DefaultDeliveryMethod)
    }


    private func loadExpirationText() {
        if let viewStrings = viewModel?.createHormoneViewStrings() {
            expLabel.text = viewStrings.expirationText
            dateAndTimePlaced.text = viewStrings.dateAndTimePlacedText
            siteLabel.text = viewStrings.siteLabelText
            expirationDateLabel.text  = viewModel?.expirationDateText
        }
    }

    private func loadSiteControls() {
        selectSiteTextField.autocapitalizationType = .words
        selectSiteTextField.text = viewModel?.selectSiteTextFieldStartText
        selectSiteTextField.restorationIdentifier = TextFieldButtonSenderType.PickerActivator.rawValue
        selectSiteTextField.delegate = self
        sitePicker.delegate = self
        sitePicker.dataSource = self
        verticalLineInSiteStack.backgroundColor = lineUnderDate.backgroundColor
        typeSiteButton.setTitle(ActionStrings.type, for: .normal)
    }

    private func loadSaveButton() {
        let save = ActionStrings.save
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
        if let nextSite = viewModel?.sdk?.sites.suggested {
            selectSiteTextField.text = nextSite.name
            viewModel?.selectionState.siteIndexSelected = nextSite.order
        }
    }
    
    private func autoSetDateText() {
        if let viewModel = viewModel {
            chooseDateButton.setTitle(viewModel.autoPickedDateText, for: .normal)
            expirationDateLabel.text = viewModel.autoPickedExpirationDateText
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
        lineUnderDateAndTimePlaced.isHidden = true
        lineUnderExpires.isHidden = true
        horizontalLineAboveSite.isHidden = true
        horizontalLineBelowSite.isHidden = true
        lineUnderDate.isHidden = true
        verticalLineInSiteStack.isHidden = true
    }
    
    private func unhideLines() {
        lineUnderScheduleDate.isHidden = false
        lineUnderDateAndTimePlaced.isHidden = false
        lineUnderExpires.isHidden = false
        horizontalLineAboveSite.isHidden = false
        horizontalLineBelowSite.isHidden = false
        lineUnderDate.isHidden = false
        verticalLineInSiteStack.isHidden = false
    }
}
