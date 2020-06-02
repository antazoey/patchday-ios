//
//  HormoneDetailVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class HormoneDetailViewController: UIViewController,
	UIPickerViewDelegate,
	UIPickerViewDataSource,
	UITextFieldDelegate {

	var viewModel: HormoneDetailViewModel!
	private lazy var log = PDLog<HormoneDetailViewController>()

	private var saveButton: UIBarButtonItem!
	@IBOutlet private weak var topConstraint: NSLayoutConstraint!
	@IBOutlet private weak var dateAndTimeAppliedHeader: UILabel!
	@IBOutlet private weak var selectSiteTextField: UITextField!
	@IBOutlet private weak var selectDateButton: UIButton!
	@IBOutlet private weak var datePickerInputView: UIView!
    @IBOutlet private weak var lineUnderDateInputView: UIView!
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
		willEnterForeground()
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
		let vc = create(source)
		return vc?.initWithHormoneIndex(index)
	}

	static func create(
		source: UIViewController, viewModel: HormoneDetailViewModel
	) -> HormoneDetailViewController? {
		let vc = create(source)
		return vc?.initWithViewModel(viewModel)
	}

	private static func create(_ source: UIViewController) -> HormoneDetailViewController? {
		let id = ViewControllerIds.HormoneDetail
		let sb = source.storyboard
		return sb?.instantiateViewController(withIdentifier: id) as? HormoneDetailViewController
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
		selectDateButton.isEnabled = false
		autofillButton.isHidden = true
		typeSiteButton.setTitle(ActionStrings.Done)
		let id = textField.restorationIdentifier ?? ""
		if let senderType = TextFieldButtonSenderType(rawValue: id) {
			handleSenderType(senderType, textFieldSender: textField)
		}
	}

	@objc func closeTextField() {
		guard let viewModel = viewModel else { return }
		let siteNameTyped = viewModel.extractSiteNameFromTextField(selectSiteTextField)
		typeSiteButton.setTitle(ActionStrings._Type)
		selectSiteTextField.endEditing(true)
		selectSiteTextField.isEnabled = true
		selectDateButton.isEnabled = true
		autofillButton.isHidden = false
		selectSiteTextField.isHidden = false
		saveButton.isEnabled = true
		typeSiteButton.replaceTarget(self, newAction: #selector(keyboardTapped(_:)))
		if siteNameTyped == "" {
			selectSiteTextField.text = viewModel.selectSiteStartText
		} else {
			viewModel.presentNewSiteAlert(newSiteName: siteNameTyped)
		}
		selectDateButton.setTitle(viewModel.dateSelectedText, for: UIControl.State.normal)
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		closeTextField()
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
		selectDateButton.setTitle(viewModel.dateSelectedText, for: UIControl.State.normal)
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
		let textColor = PDColors[.Text]
		return NSAttributedString(
			string: title, attributes: [NSAttributedString.Key.foregroundColor: textColor]
		)
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		guard let siteName = viewModel.trySelectSite(at: row) else { return }
		selectSiteTextField.text = siteName
	}

	// MARK: - Date Picker funcs

	@IBAction func selectDateTextTapped(_ sender: Any) {
		datePicker.date = viewModel.datePickerDate
		let doneButton = PDViewFactory.createDoneButton(
			doneAction: #selector(datePickerDone), mainView: view, targetViewController: self
		)
		datePickerInputView.addSubview(doneButton)
		autofillButton.isHidden = true
		selectDateButton.isEnabled = false
		typeSiteButton.isEnabled = false
		selectSiteTextField.isEnabled = false
		showDatePicker()
	}

	@objc func datePickerDone(_ sender: Any) {
		if let doneButton = sender as? UIButton {
			doneButton.removeFromSuperview()
		}
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
		guard let viewModel = viewModel else { return }
		viewModel.saveSelections()
		viewModel.nav?.pop(source: self)
	}

	@IBAction private func autofillTapped(_ sender: Any) {
		autoSetSiteText()
		autoSetDateText()
		saveButton.isEnabled = true
	}

	// MARK: - Private

	private func loadTitle() {
		guard let settings = viewModel.sdk?.settings else { return }
		let method = settings.deliveryMethod.value
		title = PDTitleStrings.Hormone[method]
	}

	private func loadDateControls() {
		guard let viewModel = viewModel else { return }
		guard let viewStrings = viewModel.createHormoneViewStrings() else { return }
		selectDateButton.setTitle(viewModel.selectDateStartText)
		expirationDateLabelHeader.text = viewStrings.expirationText
		dateAndTimeAppliedHeader.text = viewStrings.dateAndTimePlacedText
		siteLabel.text = viewStrings.siteLabelText
		expirationDateLabel.text = viewModel.expirationDateText
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
		selectSiteTextField.text = viewModel.selectSuggestedSite()
	}

	private func autoSetDateText() {
		guard let viewModel = viewModel else { return }
		selectDateButton.setTitle(viewModel.autoPickedDateText)
		expirationDateLabel.text = viewModel.autoPickedExpirationDateText
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
		// Containers
		view.backgroundColor = UIColor.systemBackground
		datePickerInputView.backgroundColor = UIColor.systemBackground
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
		selectDateButton.setTitleColor(PDColors[.Purple])
		typeSiteButton.setTitleColor(PDColors[.Button])
		autofillButton.setTitleColor(PDColors[.Button])
        saveButton.tintColor = PDColors[.Button]
	}
}
