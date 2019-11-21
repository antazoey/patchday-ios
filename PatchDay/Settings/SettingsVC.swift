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

class SettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    override public var description: String {
        """
        The view controller for the Settings View.
        The Settings View is where the user may select their defaults,
        which are saved and used for Hormone scheduling.
        See PatchData.KeyStorables and PDKit.KeyStorables.
        """
    }
    
    private let codeBehind = SettingsCodeBehind()
    private var loader: SettingsLoadController!
    private var saver: SettingsSaveController!

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
        title = VCTitleStrings.settingsTitle
        quantityLabel.text = ColonedStrings.count
        quantityButton.tag = 10
        setTopConstraint()
        loadButtonSelectedStates()
        loadButtonDisabledStates()
        delegatePickers()
        
        let controlsStruct = createControlsStruct()
        loadLoadController(controls: controlsStruct)
        loadSaveController(controls: controlsStruct)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        codeBehind.sdk?.stateManager.stampQuantity()
        applyTheme()
    }
    
    static func createSettingsVC(source: UIViewController) -> SettingsVC? {
        let sb = UIStoryboard.createSettingsStoryboard()
        let id = "SettingsVC_id"
        return sb.instantiateViewController(withIdentifier: id) as? SettingsVC
    }
    
    // MARK: - Actions
    
    @IBAction func notificationsMinutesBeforeValueChanged(_ sender: Any) {
        codeBehind.notifications?.cancelAllExpiredHormoneNotifications()
        let newMinutesBeforeValue = Int(notificationsMinutesBeforeSlider.value.rounded())
        notificationsMinutesBeforeValueLabel.text = String(newMinutesBeforeValue)
        codeBehind.sdk?.defaults.setNotificationsMinutesBefore(to: newMinutesBeforeValue)
        codeBehind.notifications?.resendAllExpiredHormoneNotifications()
    }
    
    /// For any default who's UI opens a UIPickerView
    @IBAction func selectDefaultButtonTapped(_ sender: UIButton) {
        if let id = sender.restorationIdentifier?.dropLast() {
            let key = String(id)
            if let def = PDDefault(rawValue: key) {
                selectedDefault = def
                handlePickerActivation(def, activator: sender)
            }
        }
    }
    
    @IBAction func notificationsSwitched(_ sender: Any) {
        reflectNotificationSwitchInNotificationButtons()
        codeBehind.sdk?.defaults.setNotifications(to: notificationsSwitch.isOn)
    }

    // MARK: - Picker Functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PickerOptions.getOptionsCount(for: selectedDefault)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let key = selectedDefault {
            return PickerOptions.getStrings(for: key).tryGet(at: row)
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let d = selectedDefault,
            let chosenItem = self.pickerView(
                pickerView,
                titleForRow: row,
                forComponent: component
            ) {
            switch d {
            case .DeliveryMethod:
                deliveryMethodButton.setTitle(chosenItem)
            case .ExpirationInterval:
                expirationIntervalButton.setTitle(chosenItem)
            case .Quantity:
                quantityButton.setTitle(chosenItem)
            case .Theme:
                themeButton.setTitle(chosenItem)
            default:
                break
            }
        }
    }

    private func handlePickerActivation(_ key: PDDefault, activator: UIButton) {
        if let pickerActivationProps = createPickerActivationProps(for: key, activator: activator) {
            pickerActivationProps.picker.reloadAllComponents()
            deselectEverything(except: key)
            handleBottomPickerViewRequirements(for: key)
            activatePicker(props: pickerActivationProps)
        }
    }
    
    private func createPickerActivationProps(for key: PDDefault, activator: UIButton) -> PickerActivationProperties? {
        let choices = PickerOptions.getStrings(for: key)
        if let picker = getPicker(from: key) {
            let startRow = choices.tryGetIndex(item: activator.titleLabel?.text) ?? 0
            return PickerActivationProperties(
                picker: picker,
                activator: activator,
                choices: choices,
                startRow: startRow,
                propertyKey: key
            )
        }
        return nil
    }
    
    private func getSelectedRow(selections: [String], rowItemName: String?) -> Index {
        if let item = rowItemName, let i = selections.firstIndex(of: item) {
            return i
        }
        return 0
    }
    
    private func getPicker(from key: PDDefault) -> UIPickerView? {
        switch key {
        case .DeliveryMethod:
            return deliveryMethodPicker
        case .ExpirationInterval:
            return expirationIntervalPicker
        case .Quantity:
            return quantityPicker
        case .Theme:
            return themePicker
        default:
            print("Error: PDDefault \(key) does not have a UIPicker.")
            return nil
        }
    }
    
    private func handleBottomPickerViewRequirements(for pickerKey: PDDefault) {
        if pickerKey == .Theme {
            let y = themePicker!.frame.origin.y / 2.0
            scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }
    }

    private func activatePicker(props: PickerActivationProperties) {
        if !props.picker.isHidden {
            closePicker(props)
        } else {
            props.activator.isSelected = true
            openPicker(props)
        }
    }
    
    private func openPicker(_ props: PickerActivationProperties) {
        props.picker.selectRow(props.startRow, inComponent: 0, animated: false)
        UIView.transition(
            with: props.picker as UIView,
            duration: 0.4,
            options: .transitionFlipFromTop,
            animations: { props.picker.isHidden = false },
            completion: nil
        )
    }

    private func closePicker(_ props: PickerActivationProperties) {
        props.activator.isSelected = false
        props.picker.isHidden = true
        saver.save(props.propertyKey, for: props.startRow)
    }
    
    // MARK: - Setters and getters

    private func getBackgroundColor() -> UIColor {
        if let color = settingsView.backgroundColor {
            return color
        }
        return UIColor.white
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
        codeBehind.sdk?.defaults.setNotificationsMinutesBefore(to: 0)
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
        case let def where def != .Theme:
            themeButton.isHidden = true
            themeButton.isSelected = false
        default:
            break
        }
    }
    
    private func loadButtonSelectedStates() {
        let save = ActionStrings.save
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
        if let styles = codeBehind.styles {
            settingsView.backgroundColor = styles.theme[.bg]
            view.backgroundColor = styles.theme[.bg]
            settingsView.backgroundColor = styles.theme[.bg]
            settingsStack.backgroundColor = styles.theme[.bg]
            deliveryMethodButton.setTitleColor(styles.theme[.text]!)
            expirationIntervalButton.setTitleColor(styles.theme[.text]!)
            quantityButton.setTitleColor(styles.theme[.text], for: .normal)
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
        return SettingsControls(
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
    
    private func loadLoadController(controls: SettingsControls) {
        self.loader = SettingsLoadController(codeBehind: self.codeBehind, controls: controls)
    }
    
    private func loadSaveController(controls: SettingsControls) {
        self.saver = SettingsSaveController(codeBehind: self.codeBehind, controls: controls)
    }
    
    private func delegatePickers() {
        deliveryMethodPicker.delegate = self
        expirationIntervalPicker.delegate = self
        quantityPicker.delegate = self
        themePicker.delegate = self
    }
}

extension SettingsVC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return settingsStack
    }
}
