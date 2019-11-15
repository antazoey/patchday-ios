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
    
    let codeBehind = SettingsCodeBehind()

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
        loadDeliveryMethod()
        loadExpirationInterval()
        loadQuantity()
        loadNotifications()
        loadNotificationsMinutesBefore()
        loadTheme()
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
        codeBehind.notifications?.resendAllExpiredExpiredNotifications()
    }
    
    /// For any default who's UI opens a UIPickerView
    @IBAction func selectDefaultButtonTapped(_ sender: UIButton) {
        if let id = sender.restorationIdentifier?.dropLast() {
            let key = String(id)
            if let def = PDDefault(rawValue: key) {
                selectedDefault = def
                handlePickerActivation(def, sender: sender)
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
        self.saveFromPicker(props.propertyKey, for: props.startRow)
    }
    
    // MARK: - Saving
    
    /// Saves values from pickers (NOT a function for TimePickers though).
    private func saveFromPicker(_ key: PDDefault, for row: Int) {
        app.notifications.cancelAllExpiredHormoneNotifications()
        switch key {
        case .DeliveryMethod :
            saveDeliveryMethodChange(row)
        case .Quantity :
            saveQuantityChange(row)
        case .ExpirationInterval :
            saveIntervalChange(row)
        case .Theme :
            saveThemeChange(row)
        default:
            print("Error: No picker for key \(key)")
        }
        app.notifications.resendAllExpiredExpiredNotifications()
    }
    
    private func saveDeliveryMethodChange(_ row: Int) {
        let newMethod = PickerOptions.getDeliveryMethod(at: row)
        if sdk.isFresh {
            sdk.setDeliveryMethod(to: newMethod)
        } else {
            presentDeliveryMethodMutationAlert(choice: newMethod)
        }
    }
    
    private func saveQuantityChange(_ row: Int) {
        let cancel = makeCancelClosure()
        let newQuantity = PickerOptions.getQuantity(at: row).rawValue
        PDQuantityMutator(
            sdk: self.sdk,
            alerts: self.alerts,
            tabs: self.tabs,
            cancel: cancel
        ).setQuantity(to: newQuantity)
    }
    
    private func saveIntervalChange(_ row: Int) {
        let newInterval = PickerOptions.expirationIntervals[row]
        sdk.setExpirationInterval(to: newInterval)
    }
    
    private func saveThemeChange(_ row: Int) {
        if let theme = PickerOptions.getTheme(at: row) {
            sdk.setTheme(to: theme)
            app.resetTheme()
        }
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
    
    private func presentDeliveryMethodMutationAlert(choice: DeliveryMethod) {
        alerts.presentDeliveryMethodMutationAlert(newMethod: choice) {
            void in
            let methodTitle = PickerOptions.getDeliveryMethodString(for: choice)
            switch choice {
            case .Patches:
                self.deliveryMethodButton.setTitleForNormalAndDisabled(methodTitle)
                self.quantityButton.isEnabled = true
                self.quantityArrowButton.isEnabled = true
            case .Injections:
                self.deliveryMethodButton.setTitleForNormalAndDisabled(methodTitle)
                self.quantityButton.isEnabled = false
                self.quantityArrowButton.isEnabled = false
            }
        }
    }

    private func makeCancelClosure() -> ((Int) -> ()) {
        let cancel: (Int) -> () = {
            oldQuantity in
            self.quantityButton.setTitle("\(oldQuantity)", for: .normal)
        }
        return cancel
    }
    
    private func applyTheme() {
        settingsView.backgroundColor = UIColor.white
        view.backgroundColor = app.styles.theme[.bg]
        settingsView.backgroundColor = app.styles.theme[.bg]
        settingsStack.backgroundColor = app.styles.theme[.bg]
        deliveryMethodButton.setTitleColor(app.styles.theme[.text]!)
        expirationIntervalButton.setTitleColor(app.styles.theme[.text]!)
        quantityButton.setTitleColor(app.styles.theme[.text], for: .normal)
        notificationsSwitch.backgroundColor = app.styles.theme[.bg]
        notificationsMinutesBeforeSlider.backgroundColor = app.styles.theme[.bg]
        deliveryMethodSideView.backgroundColor = app.styles.theme[.bg]
        deliveryMethodSideView.backgroundColor = app.styles.theme[.bg]
        quantitySideView.backgroundColor = app.styles.theme[.bg]
        notificationsSideView.backgroundColor = app.styles.theme[.bg]
        notificationsMinutesBeforeSideView.backgroundColor = app.styles.theme[.bg]
        themeSideView.backgroundColor = app.styles.theme[.bg]
    }

    private func loadDeliveryMethod() {
        let method = sdk.defaults.deliveryMethod.rawValue
        deliveryMethodButton.setTitle(method)
    }
    
    private func loadExpirationInterval() {
        let interval = sdk.defaults.expirationInterval.humanPresentableValue
        expirationIntervalButton.setTitle(interval)
    }
    
    private func loadQuantity() {
        let q = sdk.defaults.quantity.rawValue
        quantityButton.setTitle("\(q)")
        if sdk.defaults.deliveryMethod.value == .Injections {
            quantityButton.isEnabled = false
            quantityArrowButton.isEnabled = false
            if q != 1 {
                sdk.setQuantity(to: 1)
            }
        }
    }
    
    private func loadNotifications() {
        notificationsSwitch.setOn(sdk.defaults.notifications.value)
    }
    
    private func loadNotificationsMinutesBefore() {
        if notificationsSwitch.isOn {
            let min = sdk.defaults.notificationsMinutesBefore.value
            notificationsMinutesBeforeSlider.value = Float(min)
            notificationsMinutesBeforeValueLabel.text = String(min)
            notificationsMinutesBeforeValueLabel.textColor = UIColor.black
        } else {
            notificationsMinutesBeforeValueLabel.textColor = UIColor.lightGray
        }
    }
    
    private func loadTheme() {
        let theme = sdk.defaults.theme.value
        let title = PickerOptions.getTheme(for: theme)
        themeButton.setTitle(title, for: .normal)
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

class PDPickerView: UIPickerView {
    
}
