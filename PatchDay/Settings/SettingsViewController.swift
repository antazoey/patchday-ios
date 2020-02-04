//
//  SettingsVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/20/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


typealias UITimePicker = UIDatePicker

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    override public var description: String { "Settings View Controllers - a place to configure Application settings" }
    
    private let viewModel: SettingsViewModel = SettingsViewModel()
    var reflector: SettingsReflector?
    var saver: SettingsSaveController?

    // Containers
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var settingsStack: UIStackView!
    @IBOutlet private weak var settingsView: UIView!
    
    // Labels
    @IBOutlet weak var deliveryMethodLabel: UILabel!
    @IBOutlet weak var expirationIntervalLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var notificationsMinutesBeforeLabel: UILabel!
    @IBOutlet weak var notificationsMinutesBeforeValueLabel: UILabel!
    
    // Pickers
    @IBOutlet weak var deliveryMethodPicker: UIPickerView!
    @IBOutlet private weak var expirationIntervalPicker: UIPickerView!
    @IBOutlet private weak var quantityPicker: UIPickerView!
    @IBOutlet weak var themePicker: UIPickerView!

    // Buttons
    @IBOutlet weak var deliveryMethodButton: UIButton!
    @IBOutlet private weak var expirationIntervalButton: UIButton!
    @IBOutlet private weak var quantityButton: UIButton!
    @IBOutlet weak var quantityArrowButton: UIButton!
    @IBOutlet weak var themeButton: UIButton!
    
    // Other Controls
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var notificationsMinutesBeforeSlider: UISlider!
    
    // Views
    @IBOutlet weak var deliveryMethodSideView: UIView!
    @IBOutlet weak var quantitySideView: UIView!
    @IBOutlet weak var notificationsSideView: UIView!
    @IBOutlet weak var notificationsMinutesBeforeSideView: UIView!
    @IBOutlet weak var themeSideView: UIView!
    
    // Trackers
    private var selectedDefault: PDDefault?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = VCTitleStrings.SettingsTitle
        quantityLabel.text = ColonStrings.Count
        quantityButton.tag = 10
        setTopConstraint()
        loadButtonSelectedStates()
        loadButtonDisabledStates()
        delegatePickers()
        
        let controlsStruct = createControlsStruct()
        loadReflector(controls: controlsStruct)
        loadSaveController(controls: controlsStruct)
        reflector?.reflectStoredSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.sdk?.stateManager.stampQuantity()
        applyTheme()
    }
    
    static func createSettingsVC() -> UIViewController {
        let sb = UIStoryboard.createSettingsStoryboard()
        return sb.instantiateViewController(withIdentifier: ViewControllerIds.Settings)
    }
    
    // MARK: - Actions
    
    @IBAction func notificationsMinutesBeforeValueChanged(_ sender: Any) {
        viewModel.notifications?.cancelAllExpiredHormoneNotifications()
        let newMinutesBeforeValue = Int(notificationsMinutesBeforeSlider.value.rounded())
        notificationsMinutesBeforeValueLabel.text = String(newMinutesBeforeValue)
        viewModel.sdk?.defaults.setNotificationsMinutesBefore(to: newMinutesBeforeValue)
        viewModel.notifications?.requestAllExpiredHormoneNotifications()
    }
    
    /// For any default who's UI opens a UIPickerView
    @IBAction func selectDefaultButtonTapped(_ sender: UIButton) {
        if let def = viewModel.createDefaultFromButton(sender) {
            handlePickerActivation(def, activator: sender)
        }
    }
    
    @IBAction func notificationsSwitched(_ sender: Any) {
        reflectNotificationSwitchInNotificationButtons()
        viewModel.sdk?.defaults.setNotifications(to: notificationsSwitch.isOn)
    }

    // MARK: - Picker Delegate Functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        DefaultNumberOfPickerComponents
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        PickerOptions.getOptionsCount(for: selectedDefault)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let key = selectedDefault {
            return PickerOptions.getStrings(for: key).tryGet(at: row)
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let key = selectedDefault,
           let chosenItem = self.pickerView(pickerView, titleForRow: row, forComponent: component) {
            reflector?.reflectNewButtonTitle(key: key, newTitle: chosenItem)
        }
    }

    private func handlePickerActivation(_ key: PDDefault, activator: UIButton) {
        if let props = createPickerActivationProps(for: key, activator: activator), let saver = saver {
            props.picker.reloadAllComponents()
            deselectEverything(except: key)
            handleBottomPickerViewRequirements(for: key)
            selectedDefault = key  // Must set for use by picker delegate methods
            SettingsPickerController(pickerActivationProperties: props, saver: saver).activate()
        }
    }
    
    private func createPickerActivationProps(for key: PDDefault, activator: UIButton) -> PickerActivationProperties? {
        let options = PickerOptions.getStrings(for: key)
        let pickers = SettingsPickers(
            quantityPicker: quantityPicker,
            deliveryMethodPicker: deliveryMethodPicker,
            expirationIntervalPicker: expirationIntervalPicker,
            themePicker: themePicker
        )
        let pickerSelector = SettingsPickerSelector(pickers: pickers)
        if let picker = pickerSelector.selectPicker(key: key) {
            let startRow = options.tryGetIndex(item: activator.titleLabel?.text) ?? 0
            return PickerActivationProperties(
                picker: picker,
                activator: activator,
                options: options,
                startRow: startRow,
                propertyKey: key
            )
        }
        return nil
    }

    private func handleBottomPickerViewRequirements(for pickerKey: PDDefault) {
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
        viewModel.sdk?.defaults.setNotificationsMinutesBefore(to: 0)
        notificationsMinutesBeforeSlider.isEnabled = false
        notificationsMinutesBeforeValueLabel.textColor = UIColor.lightGray
        notificationsMinutesBeforeValueLabel.text = "0"
        notificationsMinutesBeforeSlider.value = 0
    }
    
    private func deselectEverything(except: PDDefault) {
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
        if let styles = viewModel.styles {
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
    
    private func loadReflector(controls: SettingsControls) {
        self.reflector = SettingsReflector(viewModel: self.viewModel, controls: controls)
    }
    
    private func loadSaveController(controls: SettingsControls) {
        self.saver = SettingsSaveController(
            viewModel: self.viewModel, controls: controls, themeChangeHandler: { () -> () in self.applyTheme() }
        )
    }
    
    private func delegatePickers() {
        deliveryMethodPicker.delegate = self
        expirationIntervalPicker.delegate = self
        quantityPicker.delegate = self
        themePicker.delegate = self
    }
}

extension SettingsViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { settingsStack }
}
