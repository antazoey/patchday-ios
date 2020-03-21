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
    private lazy var log = PDLog<SettingsViewController>()

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
    @IBOutlet weak var quantityPicker: SettingsPickerView!
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
        title = ViewTitleStrings.SettingsTitle
        setTopConstraint()
        loadButtonDisabledStates()
        viewModel?.reflector.reflectStoredSettings()
        setPickers()
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
            notificationsMinutesBeforeValueLabel: self.notificationsMinutesBeforeValueLabel,
            themeButton: self.themeButton
        )
    }
    
    static func create() -> UIViewController {
        let storyboard = UIStoryboard.createSettingsStoryboard()
        return storyboard.instantiateViewController(
            withIdentifier: ViewControllerIds.Settings
        )
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let settingsPicker = pickerView as? SettingsPickerView else { return nil }
        return settingsPicker.options?.tryGet(at: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let settingsPicker = pickerView as? SettingsPickerView else { return }
        let title = settingsPicker.options?.tryGet(at: row) ?? ""
        settingsPicker.activator.setTitle(title)
    }
    
    private func loadViewModelIfNil() {
        guard viewModel == nil else { return }
        let saver = SettingsSavePoint(controls: controlsStruct, themeChangeHook: { self.applyTheme() })
        self.viewModel = SettingsViewModel(reflector: SettingsReflector(controlsStruct), saver: saver)
    }

    private func handlePickerActivation(_ setting: PDSetting) {
        guard let viewModel = viewModel else { return }
        guard let picker = selectPicker(setting: setting) else { return }
        handleBottomPickerViewRequirements(for: setting)
        viewModel.activatePicker(picker)
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
        settingsStack.backgroundColor = styles.theme[.bg]
        
        deliveryMethodButton.setTitleColor(styles.theme[.text])
        deliveryMethodSideView.backgroundColor = styles.theme[.bg]
        
        expirationIntervalButton.setTitleColor(styles.theme[.text])
        
        quantityButton.setTitleColor(styles.theme[.text])
        quantitySideView.backgroundColor = styles.theme[.bg]
        
        notificationsSwitch.backgroundColor = styles.theme[.bg]
        notificationsSideView.backgroundColor = styles.theme[.bg]
        
        notificationsMinutesBeforeSlider.backgroundColor = styles.theme[.bg]
        notificationsMinutesBeforeSideView.backgroundColor = styles.theme[.bg]
        
        themeSideView.backgroundColor = styles.theme[.bg]
        themeButton.setTitleColor(styles.theme[.text])
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
        setPicker(
            deliveryMethodPicker,
            .DeliveryMethod,
            deliveryMethodButton,
            { viewModel.deliveryMethodStartIndex }
        )
        setPicker(
            expirationIntervalPicker,
            .ExpirationInterval,
            expirationIntervalButton,
            { viewModel.expirationIntervalStartIndex }
        )
        setPicker(
            quantityPicker, .Quantity, quantityButton, { viewModel.quantityStartIndex }
        )
        setPicker(themePicker, .Theme, themeButton, { viewModel.themeStartIndex })
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
        picker.options = PickerOptions.get(for: setting)
    }
}

extension SettingsViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { settingsStack }
}
