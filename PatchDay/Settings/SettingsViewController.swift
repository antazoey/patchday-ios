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
    
    private var viewModel: SettingsViewModel? = nil
    private let log = PDLog<SettingsViewController>()

    // Containers
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var settingsStack: UIStackView!
    @IBOutlet private weak var settingsView: UIView!
    
    // StackViews
    @IBOutlet private weak var deliveryMethodStack: UIStackView!
    @IBOutlet private weak var expirationIntervalStack: UIStackView!
    @IBOutlet private weak var quantityStack: UIStackView!
    @IBOutlet private weak var themeStack: UIStackView!
    @IBOutlet private weak var notificationsStack: UIStackView!
    @IBOutlet private weak var notificationsMinutesBeforeStack: UIStackView!
    
    // Labels
    @IBOutlet private weak var deliveryMethodLabel: UILabel!
    @IBOutlet private weak var expirationIntervalLabel: UILabel!
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var themeLabel: UILabel!
    @IBOutlet private weak var notificationsLabel: UILabel!
    @IBOutlet private weak var notificationsMinutesBeforeLabel: UILabel!
    @IBOutlet private weak var notificationsMinutesBeforeValueLabel: UILabel!
    
    // Pickers
    @IBOutlet private weak var deliveryMethodPicker: SettingsPickerView!
    @IBOutlet private weak var expirationIntervalPicker: SettingsPickerView!
    @IBOutlet private weak var quantityPicker: SettingsPickerView!
    @IBOutlet private weak var themePicker: SettingsPickerView!

    // Buttons
    @IBOutlet private weak var deliveryMethodButton: UIButton!
    @IBOutlet private weak var expirationIntervalButton: UIButton!
    @IBOutlet private weak var quantityButton: UIButton!
    @IBOutlet private weak var quantityArrowButton: UIButton!
    @IBOutlet private weak var themeButton: UIButton!
    @IBOutlet private weak var themeArrowButton: UIButton!
    
    // Other Controls
    @IBOutlet private weak var notificationsSwitch: UISwitch!
    @IBOutlet private weak var notificationsMinutesBeforeSlider: UISlider!
    
    // Views
    @IBOutlet private weak var deliveryMethodSideView: UIView!
    @IBOutlet private weak var quantitySideView: UIView!
    @IBOutlet private weak var notificationsSideView: UIView!
    @IBOutlet private weak var notificationsMinutesBeforeSideView: UIView!
    @IBOutlet private weak var themeSideView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewModelIfNil()
        title = VCTitleStrings.SettingsTitle
        setTopConstraint()
        loadButtonSelectedStates()
        loadButtonDisabledStates()
        viewModel?.reflector.reflectStoredSettings()
        setPickers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        assignSelfAsDelegateForPickers()
        loadViewModelIfNil()
        super.viewWillAppear(animated)
        viewModel?.sdk?.stateManager.markQuantityAsOld()
        applyTheme()
    }
    
    static func createSettingsVC() -> UIViewController {
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
        viewModel?.getCurrentPickerOptions().count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel?.getRowTitle(at: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel?.selectRow(row: row)
    }
    
    private func loadViewModelIfNil() {
        guard viewModel == nil else { return }
        let controls = createControlsStruct()
        let saver = SettingsStateSaver(controls: controls, themeChangeHook: { self.applyTheme() })
        self.viewModel = SettingsViewModel(reflector: SettingsReflector(controls), saver: saver)
    }

    private func handlePickerActivation(_ setting: PDSetting) {
        guard let viewModel = viewModel else { return }
        guard let picker = selectPicker(setting: setting) else { return }
        viewModel.selectedSetting = setting
        viewModel.activatePicker(picker) {
            deselectEverything(except: setting)
            handleBottomPickerViewRequirements(for: setting)
        }
    }

    private func handleBottomPickerViewRequirements(for pickerKey: PDSetting) {
        guard pickerKey == .Theme else { return }
        guard let themePicker = themePicker else { return }
        let y = themePicker.frame.origin.y / 2.0
        scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
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
    
    private func deselectEverything(except: PDSetting) {
        switch except {
        case let setting where setting != .DeliveryMethod:
            deliveryMethodPicker.isHidden = true
            deliveryMethodButton.isSelected = false
            fallthrough
        case let setting where setting != .ExpirationInterval:
            expirationIntervalPicker.isHidden = true
            expirationIntervalButton.isSelected = false
            fallthrough
        case let setting where setting != .Quantity:
            quantityPicker.isHidden = true
            quantityButton.isSelected = false
            fallthrough
        case let setting where setting != .Theme:
            themeButton.isHidden = true
            themeButton.isSelected = false
        default:
            break
        }
    }
    
    private func loadButtonSelectedStates() {
        let save = ActionStrings.Save
        deliveryMethodButton.setTitle(save, for: .selected)
        expirationIntervalButton.setTitle(save, for: .selected)
        quantityButton.setTitle(save, for: .selected)
        themeButton.setTitle(save, for: .selected)
    }
    
    private func loadButtonDisabledStates() {
        quantityButton.setTitleColor(UIColor.lightGray, for: .disabled)
    }
    
    private func setTopConstraint() {
        guard AppDelegate.isPad else { return }
        topConstraint.constant = 100
    }
    
    private func applyTheme() {
        guard let styles = viewModel?.styles else { return }
        settingsView.backgroundColor = styles.theme[.bg]
        view.backgroundColor = styles.theme[.bg]
        settingsView.backgroundColor = styles.theme[.bg]
        settingsStack.backgroundColor = styles.theme[.bg]
        deliveryMethodButton.setTitleColor(styles.theme[.text])
        expirationIntervalButton.setTitleColor(styles.theme[.text])
        quantityButton.setTitleColor(styles.theme[.text])
        notificationsSwitch.backgroundColor = styles.theme[.bg]
        notificationsMinutesBeforeSlider.backgroundColor = styles.theme[.bg]
        deliveryMethodSideView.backgroundColor = styles.theme[.bg]
        deliveryMethodSideView.backgroundColor = styles.theme[.bg]
        quantitySideView.backgroundColor = styles.theme[.bg]
        notificationsSideView.backgroundColor = styles.theme[.bg]
        notificationsMinutesBeforeSideView.backgroundColor = styles.theme[.bg]
        themeSideView.backgroundColor = styles.theme[.bg]
    }
    
    private func createControlsStruct() -> SettingsControls {
        SettingsControls(
            deliveryMethodButton: self.deliveryMethodButton,
            quantityButton: self.quantityButton,
            quantityArrowButton: self.quantityArrowButton,
            expirationIntervalButton: self.expirationIntervalButton,
            notificationsSwitch: self.notificationsSwitch,
            notificationsMinutesBeforeSlider: self.notificationsMinutesBeforeSlider,
            notificationsMinutesBeforeValueLabel: self.notificationsMinutesBeforeValueLabel,
            themeButton: self.themeButton
        )
    }
    
    private func assignSelfAsDelegateForPickers() {
        deliveryMethodPicker.delegate = self
        deliveryMethodPicker.dataSource = self
        expirationIntervalPicker.delegate = self
        expirationIntervalPicker.dataSource = self
        quantityPicker.delegate = self
        quantityPicker.dataSource = self
        themePicker.delegate = self
        themePicker.dataSource = self
    }
    
    
    private func selectPicker(setting: PDSetting) -> SettingsPickerView? {
        switch setting {
        case.Quantity: return quantityPicker
        case .DeliveryMethod: return deliveryMethodPicker
        case .ExpirationInterval: return expirationIntervalPicker
        case .Theme: return themePicker
        default:
            log.error("No picker for given setting \(setting)")
            return nil
        }
    }
    
    private func setPickers() {
        guard let viewModel = self.viewModel else { return }
        deliveryMethodPicker.setting = PDSetting.DeliveryMethod
        deliveryMethodPicker.activator = deliveryMethodButton
        deliveryMethodPicker.getStartRow = { viewModel.deliveryMethodStartIndex }
        quantityPicker.setting = PDSetting.Quantity
        quantityPicker.activator = quantityButton
        quantityPicker.getStartRow = { viewModel.quantityStartIndex }
        expirationIntervalPicker.setting = PDSetting.ExpirationInterval
        expirationIntervalPicker.activator = expirationIntervalButton
        expirationIntervalPicker.getStartRow = { viewModel.expirationIntervalStartIndex }
        themePicker.setting = PDSetting.Theme
        themePicker.activator = themeButton
        themePicker.getStartRow = { viewModel.themeStartIndex }
    }
}

extension SettingsViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { settingsStack }
}
