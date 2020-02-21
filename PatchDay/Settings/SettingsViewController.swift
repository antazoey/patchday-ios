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
        "Settings View Controllers - a place to configure Application settings"
    }
    
    private var viewModel: SettingsViewModel? = nil

    // Containers
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var settingsStack: UIStackView!
    @IBOutlet private weak var settingsView: UIView!
    
    // Labels
    @IBOutlet private weak var deliveryMethodLabel: UILabel!
    @IBOutlet private weak var expirationIntervalLabel: UILabel!
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var notificationsLabel: UILabel!
    @IBOutlet private weak var notificationsMinutesBeforeLabel: UILabel!
    @IBOutlet private weak var notificationsMinutesBeforeValueLabel: UILabel!
    
    // Pickers
    @IBOutlet private weak var deliveryMethodPicker: UIPickerView!
    @IBOutlet private weak var expirationIntervalPicker: UIPickerView!
    @IBOutlet private weak var quantityPicker: UIPickerView!
    @IBOutlet private weak var themePicker: UIPickerView!

    // Buttons
    @IBOutlet private weak var deliveryMethodButton: UIButton!
    @IBOutlet private weak var expirationIntervalButton: UIButton!
    @IBOutlet private weak var quantityButton: UIButton!
    @IBOutlet private weak var quantityArrowButton: UIButton!
    @IBOutlet private weak var themeButton: UIButton!
    
    // Other Controls
    @IBOutlet private weak var notificationsSwitch: UISwitch!
    @IBOutlet private weak var notificationsMinutesBeforeSlider: UISlider!
    
    // Views
    @IBOutlet private weak var deliveryMethodSideView: UIView!
    @IBOutlet private weak var quantitySideView: UIView!
    @IBOutlet private weak var notificationsSideView: UIView!
    @IBOutlet private weak var notificationsMinutesBeforeSideView: UIView!
    @IBOutlet private weak var themeSideView: UIView!
    
    // Trackers
    private var selectedDefault: PDSetting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewModelIfNil()
        title = VCTitleStrings.SettingsTitle
        quantityLabel.text = ColonStrings.Count
        quantityButton.tag = 10
        setTopConstraint()
        loadButtonSelectedStates()
        loadButtonDisabledStates()
        assignSelfAsDelegateForPickers()
        viewModel?.reflector.reflectStoredSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadViewModelIfNil()
        super.viewWillAppear(animated)
        viewModel?.sdk?.stateManager.markQuantityAsOld()
        applyTheme()
    }
    
    static func createSettingsVC() -> UIViewController {
        let sb = UIStoryboard.createSettingsStoryboard()
        return sb.instantiateViewController(withIdentifier: ViewControllerIds.Settings)
    }
    
    // MARK: - Actions
    
    @IBAction func notificationsMinutesBeforeValueChanged(_ sender: Any) {
        guard let viewModel = viewModel else { return }
        viewModel.notifications?.cancelAllExpiredHormoneNotifications()
        let newMinutesBeforeValue = Int(notificationsMinutesBeforeSlider.value.rounded())
        notificationsMinutesBeforeValueLabel.text = String(newMinutesBeforeValue)
        viewModel.sdk?.settings.setNotificationsMinutesBefore(to: newMinutesBeforeValue)
        viewModel.notifications?.requestAllExpiredHormoneNotifications()
    }
    
    /// Opens UIPickerView
    @IBAction func selectDefaultButtonTapped(_ sender: UIButton) {
        if let setting = viewModel?.getSettingFromButton(sender) {
            handlePickerActivation(setting, activator: sender)
        }
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
        PickerOptions.getOptionsCount(for: selectedDefault)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let key = selectedDefault else { return nil }
        return PickerOptions.getStrings(for: key).tryGet(at: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let key = selectedDefault,
           let chosenItem = self.pickerView(pickerView, titleForRow: row, forComponent: component) {
            viewModel?.reflector.reflectNewButtonTitle(key: key, newTitle: chosenItem)
        }
    }
    
    private func loadViewModelIfNil() {
        guard viewModel == nil else { return }
        let controls = createControlsStruct()
        let reflector = SettingsReflector(controls: controls)
        let saver = SettingsStateSaver(controls: controls, themeChangeHook: { self.applyTheme() })
        self.viewModel = SettingsViewModel(reflector: reflector, saver: saver)
    }

    private func handlePickerActivation(_ key: PDSetting, activator: UIButton) {
        guard let viewModel = viewModel else { return }
        viewModel.selectedSettings = key
        let pickers = SettingsPickers(
            quantityPicker: quantityPicker,
            deliveryMethodPicker: deliveryMethodPicker,
            expirationIntervalPicker: expirationIntervalPicker,
            themePicker: themePicker
        )
        viewModel.activatePicker(pickers: pickers, activator: activator) {
            deselectEverything(except: key)
            handleBottomPickerViewRequirements(for: key)
        }
    }

    private func handleBottomPickerViewRequirements(for pickerKey: PDSetting) {
        if pickerKey == .Theme {
            let y = themePicker!.frame.origin.y / 2.0
            scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }
    }
    
    // MARK: - View loading and altering
    
    private func reflectNotificationSwitchInNotificationButtons() {
        if notificationsSwitch.isOn {
            enableNotificationButtons()
        } else {
            disableNotificationButtons()
        }
    }
    
    private func enableNotificationButtons() {
        notificationsMinutesBeforeSlider.isEnabled = true
        notificationsMinutesBeforeValueLabel.textColor = UIColor.black
    }
    
    private func disableNotificationButtons() {
        viewModel?.sdk?.settings.setNotificationsMinutesBefore(to: 0)
        notificationsMinutesBeforeSlider.isEnabled = false
        notificationsMinutesBeforeValueLabel.textColor = UIColor.lightGray
        notificationsMinutesBeforeValueLabel.text = "0"
        notificationsMinutesBeforeSlider.value = 0
    }
    
    private func deselectEverything(except: PDSetting) {
        switch except {
        case let def where def != .DeliveryMethod:
            deliveryMethodPicker.isHidden = true
            deliveryMethodButton.isSelected = false
            fallthrough
        case let def where def != .ExpirationInterval:
            expirationIntervalPicker.isHidden = true
            expirationIntervalButton.isSelected = false
            fallthrough
        case let def where def != .Quantity:
            quantityPicker.isHidden = true
            quantityButton.isSelected = false
            fallthrough
        case let def where def != .Theme:
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
        // Add more disabled states here as they arise
        quantityButton.setTitleColor(UIColor.lightGray, for: .disabled)
    }
    
    private func setTopConstraint() {
        if AppDelegate.isPad {
            topConstraint.constant = 100
        }
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
}

extension SettingsViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { settingsStack }
}
