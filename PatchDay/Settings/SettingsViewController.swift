//
//  SettingsViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/20/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

	override public var description: String {
		"The view controller for configuring Application settings."
	}

	private var viewModel: SettingsViewModel?
	private lazy var log = PDLog<SettingsViewController>()

	// Containers
	@IBOutlet private weak var scrollView: UIScrollView!
	@IBOutlet private weak var topConstraint: NSLayoutConstraint!
	@IBOutlet private weak var settingsStack: UIStackView!
	@IBOutlet private weak var settingsView: UIView!
	@IBOutlet private weak var expirationMinutesSliderContainer: UIView!
	@IBOutlet private weak var notificationsSwitchContainer: UIView!

	// StackViews
	@IBOutlet private weak var deliveryMethodStack: UIStackView!
	@IBOutlet private weak var expirationIntervalStack: UIStackView!
	@IBOutlet private weak var quantityStack: UIStackView!
	@IBOutlet private weak var notificationsStack: UIStackView!
	@IBOutlet private weak var notificationsMinutesBeforeStack: UIStackView!

	// Labels
	@IBOutlet private weak var deliveryMethodLabel: UILabel!
	@IBOutlet private weak var expirationIntervalLabel: UILabel!
	@IBOutlet private weak var quantityLabel: UILabel!
	@IBOutlet private weak var notificationsLabel: UILabel!
	@IBOutlet private weak var notificationsMinutesBeforeLabel: UILabel!
	@IBOutlet private weak var notificationsMinutesBeforeValueLabel: UILabel!

	// Pickers
	@IBOutlet private weak var deliveryMethodPicker: SettingsPickerView!
	@IBOutlet private weak var expirationIntervalPicker: SettingsPickerView!
	@IBOutlet private weak var quantityPicker: SettingsPickerView!

	// Buttons
	@IBOutlet private weak var deliveryMethodButton: UIButton!
	@IBOutlet private weak var expirationIntervalButton: UIButton!
	@IBOutlet private weak var quantityButton: UIButton!
	@IBOutlet private weak var quantityArrowButton: UIButton!

	// Icons
	@IBOutlet private weak var deliveryMethodIcon: UIImageView!
	@IBOutlet private weak var expirationIntervalIcon: UIImageView!
	@IBOutlet private weak var quantityIcon: UIImageView!
	@IBOutlet private weak var notificationsIcon: UIImageView!
	@IBOutlet private weak var notificationsMinutesBeforeIcon: UIImageView!

	// Other Controls
	@IBOutlet private weak var notificationsSwitch: UISwitch!
	@IBOutlet private weak var notificationsMinutesBeforeSlider: UISlider!

	// Views
	@IBOutlet private weak var deliveryMethodSideView: UIView!
	@IBOutlet private weak var expirationIntervalSideView: UIView!
	@IBOutlet private weak var quantitySideView: UIView!
	@IBOutlet private weak var notificationsSideView: UIView!
	@IBOutlet private weak var notificationsMinutesBeforeSideView: UIView!

	override func viewDidLoad() {
		super.viewDidLoad()
		loadViewModelIfNil()
		title = PDTitleStrings.SettingsTitle
		setTopConstraint()
		loadButtonDisabledStates()
		viewModel?.reflector.reflect()
		setPickers()
		applyTheme()
	}

	override func viewWillAppear(_ animated: Bool) {
		quantityPicker.isHidden = true
		assignSelfAsDelegateForPickers()
		loadViewModelIfNil()
		super.viewWillAppear(animated)
		applyTheme()
	}

	private var controlsStruct: SettingsControls {
		SettingsControls(
			deliveryMethodButton: self.deliveryMethodButton,
			quantityButton: self.quantityButton,
			quantityArrowButton: self.quantityArrowButton,
			expirationIntervalButton: self.expirationIntervalButton,
			notificationsSwitch: self.notificationsSwitch,
			notificationsMinutesBeforeSlider: self.notificationsMinutesBeforeSlider,
			notificationsMinutesBeforeValueLabel: self.notificationsMinutesBeforeValueLabel
		)
	}

	static func create() -> UIViewController {
		let storyboard = UIStoryboard.createSettingsStoryboard()
		return storyboard.instantiateViewController(withIdentifier: ViewControllerIds.Settings)
	}

	// MARK: - Actions

	@IBAction func notificationsMinutesBeforeValueChanged(_ sender: Any) {
		let newValue = notificationsMinutesBeforeSlider.value.rounded()
		viewModel?.handleNewNotificationsValue(newValue)
		notificationsMinutesBeforeValueLabel.text = String(newValue)
	}

	/// Opens UIPickerView
	@IBAction func selectDefaultButtonTapped(_ sender: UIButton) {
		guard let setting = sender.tryGetSettingFromButtonMetadata() else { return }
		handlePickerActivation(setting)
	}

	@IBAction func notificationsSwitched(_ sender: Any) {
		reflectNotificationSwitchInNotificationButtons()
		viewModel?.sdk?.settings.setNotifications(to: notificationsSwitch.isOn)
	}

	// MARK: - Picker Delegate Functions

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		DefaultNumberOfPickerComponents
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		guard let settingsPicker = pickerView as? SettingsPickerView else { return 0 }
		return settingsPicker.options?.count ?? 0
	}

	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let settingsPicker = pickerView as? SettingsPickerView
		let title = settingsPicker?.options?.tryGet(at: row) ?? ""
		let textColor = PDColors[.Text]
		return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: textColor])
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		guard let settingsPicker = pickerView as? SettingsPickerView else { return }
		let title = settingsPicker.options?.tryGet(at: row) ?? ""
		settingsPicker.activator.setTitle(title)
	}

	private func loadViewModelIfNil() {
		guard viewModel == nil else { return }
		let saver = SettingsSavePoint(controlsStruct)
		let reflector = SettingsReflector(controlsStruct)
		self.viewModel = SettingsViewModel(reflector, saver)
	}

	private func handlePickerActivation(_ setting: PDSetting) {
		guard let viewModel = viewModel else { return }
		guard let picker = selectPicker(setting: setting) else { return }
		viewModel.activatePicker(picker)
	}

	// MARK: - View loading and altering

	private func reflectNotificationSwitchInNotificationButtons() {
		notificationsSwitch.isOn ? enableNotificationButtons() : disableNotificationButtons()
	}

	private func enableNotificationButtons() {
		notificationsMinutesBeforeSlider.isEnabled = true
		notificationsMinutesBeforeValueLabel.textColor = UIColor.black
	}

	private func disableNotificationButtons() {
		let disabledValue = 0
		viewModel?.sdk?.settings.setNotificationsMinutesBefore(to: disabledValue)
		notificationsMinutesBeforeSlider.isEnabled = false
		notificationsMinutesBeforeValueLabel.textColor = UIColor.lightGray
		notificationsMinutesBeforeValueLabel.text = String(disabledValue)
		notificationsMinutesBeforeSlider.value = Float(disabledValue)
	}

	private func loadButtonDisabledStates() {
		quantityButton.setTitleColor(UIColor.lightGray, for: .disabled)
	}

	private func setTopConstraint() {
		guard AppDelegate.isPad else { return }
		topConstraint.constant = 100
	}

	private func applyTheme() {
		let textColor = PDColors[.Text]
		let bgColor = UIColor.systemBackground

		// Labels
		deliveryMethodLabel.textColor = textColor
		expirationIntervalLabel.textColor = textColor
		quantityLabel.textColor = textColor
		notificationsLabel.textColor = textColor
		notificationsMinutesBeforeLabel.textColor = textColor
		notificationsMinutesBeforeValueLabel.textColor = textColor

		// Containers
		settingsView.backgroundColor = bgColor
		view.backgroundColor = bgColor
		settingsStack.backgroundColor = bgColor
		notificationsSwitchContainer.backgroundColor = bgColor
		expirationMinutesSliderContainer.backgroundColor = bgColor

		// Buttons
		deliveryMethodButton.setTitleColor(textColor)
		quantityButton.setTitleColor(textColor)
		expirationIntervalButton.setTitleColor(textColor)

		// Side views
		deliveryMethodSideView.backgroundColor = bgColor
		expirationIntervalSideView.backgroundColor = bgColor
		quantitySideView.backgroundColor = bgColor

		// Icons
		deliveryMethodIcon.image = deliveryMethodIcon.image?.withTintColor(textColor)
		expirationIntervalIcon.image = expirationIntervalIcon.image?.withTintColor(textColor)
		quantityIcon.image = quantityIcon.image?.withTintColor(textColor)
		notificationsIcon.image = notificationsIcon.image?.withTintColor(textColor)
		notificationsMinutesBeforeIcon.image = notificationsMinutesBeforeIcon.image?.withTintColor(textColor)

		// Misc
		notificationsSwitch.backgroundColor = bgColor
		notificationsSideView.backgroundColor = bgColor
		notificationsMinutesBeforeSlider.backgroundColor = bgColor
		notificationsMinutesBeforeSideView.backgroundColor = bgColor
		view.setNeedsDisplay()
	}

	private func assignSelfAsDelegateForPickers() {
		deliveryMethodPicker.delegate = self
		deliveryMethodPicker.dataSource = self
		expirationIntervalPicker.delegate = self
		expirationIntervalPicker.dataSource = self
		quantityPicker.delegate = self
		quantityPicker.dataSource = self
	}

	private func selectPicker(setting: PDSetting) -> SettingsPickerView? {
		switch setting {
			case.Quantity: return quantityPicker
			case .DeliveryMethod: return deliveryMethodPicker
			case .ExpirationInterval: return expirationIntervalPicker
			default:
				log.error("No picker for given setting \(setting)")
				return nil
		}
	}

	private func setPickers() {
		guard let viewModel = self.viewModel else { return }
		setPicker(
			deliveryMethodPicker,
			.DeliveryMethod,
			deliveryMethodButton, { viewModel.deliveryMethodStartIndex }
		)
		setPicker(
			expirationIntervalPicker,
			.ExpirationInterval,
			expirationIntervalButton, { viewModel.expirationIntervalStartIndex }
		)
		setPicker(
			quantityPicker,
			.Quantity,
			quantityButton, { viewModel.quantityStartIndex }
		)
	}

	private func setPicker(
		_ picker: SettingsPickerView,
		_ setting: PDSetting,
		_ button: UIButton,
		_ getStartRow: @escaping () -> (Index)
	) {
		picker.setting = setting
		picker.activator = button
		picker.getStartRow = getStartRow
		picker.options = SettingsOptions[setting]
	}
}

extension SettingsViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? { settingsStack }
}
