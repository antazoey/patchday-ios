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
        return """
        The view controller for the Settings View.
        The Settings View is where the user may select their defaults,
        which are saved and used for PatchDay scheduling.
        See PatchData's PDDefaults object for info on the types of defaults.
        """
    }
    
    // Dependencies
    private let sdk = app.sdk
    private let notifications = app.notifications
    private let alerts = app.alerts
    
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
        title = PDVCTitleStrings.settingsTitle
        quantityLabel.text = PDColonedStrings.count
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
        sdk.stampQuantity()
        applyTheme()
    }
    
    // MARK: - Actions
    
    @IBAction func notificationsMinutesBeforeValueChanged(_ sender: Any) {
        notifications.cancelAllHormoneExpiredNotifications()
        let v = Int(notificationsMinutesBeforeSlider.value.rounded())
        notificationsMinutesBeforeValueLabel.text = String(v)
        sdk.defaults.setNotificationsMinutesBefore(to: v)
        notifications.resendAllHormoneExpiredNotifications()
    }
    
    /// For any default who's UI opens a UIPickerView
    @IBAction func selectDefaultButtonTapped(_ sender: UIButton) {
        if let id = sender.restorationIdentifier?.dropLast() {
            let key = String(id)
            if let def = PDDefault(rawValue: key) {
                activatePicker(def, sender: sender)
            }
        }
    }
    
    @IBAction func notificationsSwitched(_ sender: Any) {
        let n = notificationsSwitch.isOn
        n ? enableNotificationButtons() : disableNotificationButtons()
        sdk.defaults.setNotifications(to: n)
    }

    // MARK: - Picker Functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PDPickerStrings.getCount(for: selectedDefault)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title: String? = nil
        if let key = selectedDefault {
            let data = PDPickerStrings.getStrings(for: key)
            if row < data.count && row >= 0 {
                title = data[row]
            }
        }
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let d = selectedDefault,
            let chosenItem = self.pickerView(pickerView, titleForRow: row, forComponent: component) {
            switch d {
            case .DeliveryMethod:
                deliveryMethodButton.setTitle(chosenItem, for: .normal)
            case .ExpirationInterval:
                expirationIntervalButton.setTitle(chosenItem, for: .normal)
            case .Quantity:
                quantityButton.setTitle(chosenItem, for: .normal)
            case .Theme:
                themeButton.setTitle(chosenItem, for: .normal)
            default:
                break
            }
        }
    }
    
    /** Selector method for openOrClose(picker, buttonTapped, selections)
     // -- loads proper UI elements specific to each picker
     // -- hides everything that is not that picker
     
     // key is either "interval" , "count" , "notifications" */
    private func activatePicker(_ key: PDDefault, sender: UIButton) {
        var picker: UIPickerView?
        let selections = PDPickerStrings.getStrings(for: key)
        let choice = sender.titleLabel?.text
        let start: Int = { () in
            if let c = choice, let i = selections.firstIndex(of: c) {
                return i
            }
            return 0
        }()
        
        selectedDefault = key
        switch key {
        case .DeliveryMethod:
            picker = deliveryMethodPicker
        case .ExpirationInterval:
            picker = expirationIntervalPicker
            expirationIntervalPicker.reloadAllComponents()
        case .Quantity:
            picker = quantityPicker
        case .Theme:
            picker = themePicker
            let y = themePicker!.frame.origin.y / 2.0
            scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        default:
            print("Error: Improper context for loading UIPicker.")
            return
        }
        
        let p = picker!
        p.reloadAllComponents()
        deselectEverything(except: key)
        if p.isHidden == false {
            closePicker(sender, p, key, row: start)
        } else {
            sender.isSelected = true
            openPicker(sender, selections, p, selectedRow: start)
        }
    }
    
    private func openPicker(_ buttonTapped: UIButton,_ selections: [String],_ picker: UIPickerView, selectedRow: Int) {
        picker.selectRow(selectedRow, inComponent: 0, animated: false)
        UIView.transition(with: picker as UIView,
                          duration: 0.4,
                          options: .transitionFlipFromTop,
                          animations: { picker.isHidden = false },
                          completion: nil)
    }
    
    /** Select the button,
       And for count, set global variable necessary for animation,
       And close the picker,
       Then, save newly set User Defaults */
    private func closePicker(_ buttonTapped: UIButton,_ picker: UIPickerView, _ key: PDDefault, row: Int) {
        buttonTapped.isSelected = false
        picker.isHidden = true
        self.saveFromPicker(key, for: row)
    }
    
    // MARK: - Saving
    
    /// Saves values from pickers (NOT a function for TimePickers though).
    private func saveFromPicker(_ key: PDDefault, for row: Int) {
        app.notifications.cancelAllHormoneExpiredNotifications()
        switch key {
        case .DeliveryMethod :
            deliveryMethodPicker.selectRow(row)
            saveDeliveryMethodChange()
        case .Quantity :
            quantityPicker.selectRow(row)
            saveQuantityChange()
        case .ExpirationInterval :
            expirationIntervalPicker.selectRow(row)
            saveIntervalChange()
        case .Theme :
            themePicker.selectRow(0)
            saveThemeChange()
        default:
            print("Error: Improper context when saving details from picker")
        }
        app.notifications.resendAllHormoneExpiredNotifications()
    }
    
    private func saveDeliveryMethodChange() {
        
        let newMethod = deliveryMethodPicker.select deliveryMethodPicker.getSelectedRow()
        setButtonsFromDeliveryMethodChange(choice: newMethod)
        if sdk.isFresh {
            sdk.deliveryMethod = newMethod
        } else {
            presentDeliveryMethodMutationAlert(choice: newMethod)
        }
    }
    
    private func saveQuantityChange() {
        let old = state.oldQuantity
        let reset = makeResetClosure(oldCount: old)
        let cancel = makeCancelClosure(oldCount: old)
        let newQuantity = quantityPicker.getSelectedRow()
        pdShell.setQuantity(to: newQuantity, oldQuantityRaw: old, reset: reset, cancel: cancel)
    }
    
    private func saveIntervalChange() {
        let newInterval = expirationIntervalPicker.getSelectedRow()
        let result = pdShell.setExpirationIntervalIfSafe(at: newInterval)
        if result.didSet {
        } else {
            print("Error: no expiration interval for row \(row)")
        }
    }
    
    private func saveThemeChange() {
        let newTheme = themePicker.getSelectedRow()
        let theme = pdShell.setThemeIfSafe(toMethodAt: row)
        if theme != "" {
            app.resetTheme()
        } else {
            print("Error: no theme for row \(row)")
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
    
    private func enableNotificationButtons() {
        notificationsMinutesBeforeSlider.isEnabled = true
        notificationsMinutesBeforeValueLabel.textColor = UIColor.black
    }
    
    private func disableNotificationButtons() {
        notificationsMinutesBeforeSlider.isEnabled = false
        notificationsMinutesBeforeValueLabel.textColor = UIColor.lightGray
        notificationsMinutesBeforeValueLabel.text = "0"
        sdk.defaults.setNotificationsMinutesBefore(to: 0)
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
        let save = PDActionStrings.save
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
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.phone) {
            topConstraint.constant = 100
        }
    }
    
    private func presentDeliveryMethodMutationAlert(choice: DeliveryMethod) {
        alerts.presentDeliveryMethodMutationAlert(newMethod: choice) {
            void in
            let quantityTitle = PDPickerStrings.getDeliveryMethod(for: choice)
            switch choice {
            case .Patches:
                self.quantityButton.setTitle(quantityTitle, for: .disabled)
                self.quantityButton.setTitle(quantityTitle, for: .normal)
                self.quantityButton.isEnabled = true
                self.quantityArrowButton.isEnabled = true
            case .Injections:
                self.quantityButton.setTitle(quantityTitle, for: .disabled)
                self.quantityButton.setTitle(quantityTitle, for: .normal)
                self.quantityButton.isEnabled = false
                self.quantityArrowButton.isEnabled = false
            }
        }
    }
    
    private func makeResetClosure(oldCount: Int) -> ((Int) -> ()) {
        let reset: (Int) -> () = {
            newCount in
            app.tabs?.reflectExpirationCountAsBadgeValue()
            app.notifications.cancelHormoneNotifications(from: newCount, to: oldCount)
        }
        return reset
    }

    private func makeCancelClosure(oldCount: Int) -> ((Int) -> ()) {
        let cancel: (Int) -> () = {
            oldCount in
            self.quantityButton.setTitle(String(oldCount), for: .normal)
        }
        return cancel
    }
    
    private func applyTheme() {
        settingsView.backgroundColor = UIColor.white
        view.backgroundColor = app.styles.theme[.bg]
        settingsView.backgroundColor = app.styles.theme[.bg]
        settingsStack.backgroundColor = app.styles.theme[.bg]
        deliveryMethodButton.setTitleColor(app.styles.theme[.text], for: .normal)
        expirationIntervalButton.setTitleColor(app.styles.theme[.text], for: .normal)
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
        deliveryMethodButton.setTitle(sdk.deliveryMethodName, for: .normal)
    }
    
    private func loadExpirationInterval() {
        let interval = sdk.defaults.expirationInterval.humanPresentableValue
        expirationIntervalButton.setTitle(interval, for: .normal)
    }
    
    private func loadQuantity() {
        let q = sdk.defaults.quantity.value.rawValue
        quantityButton.setTitle("\(q)", for: .normal)
        if sdk.deliveryMethod != .Patches {
            quantityButton.isEnabled = false
            quantityArrowButton.isEnabled = false
            if q != 1 {
                sdk.defaults.setQuantity(to: 1)
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
        let title = PDPickerStrings.getTheme(for: theme)
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
