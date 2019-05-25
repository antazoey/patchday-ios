//
//  SettingsVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/20/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

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
    
    // Containers
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
    @IBOutlet private weak var intervalButton: UIButton!
    @IBOutlet private weak var quantityButton: UIButton!
    @IBOutlet weak var quantityArrowButton: UIButton!
    @IBOutlet weak var themeButton: UIButton!
    
    // Other Controls
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var notificationsMinutesBeforeSlider: UISlider!
    
    // Views
    @IBOutlet weak var dmSideView: UIView!
    @IBOutlet weak var deliveryMethodSideView: UIView!
    @IBOutlet weak var quantitySideView: UIView!
    @IBOutlet weak var notificationsSideView: UIView!
    @IBOutlet weak var notMinBeforeSideView: UIView!
    @IBOutlet weak var themeSideView: UIView!
    
    // Trackers
    private var whichTapped: PDDefault?
    //private var selectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = PDStrings.VCTitles.settings
        quantityLabel.text = PDStrings.ColonedStrings.count
        quantityButton.tag = 10
        settingsView.backgroundColor = UIColor.white
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
        patchData.state.oldQuantity = patchData.defaults.quantity.value.rawValue
        applyTheme()
    }
    
    // MARK: - Actions
    
    @IBAction func notificationsMinutesBeforeValueChanged(_ sender: Any) {
        let v = Int(notificationsMinutesBeforeSlider.value.rounded())
        notificationsMinutesBeforeValueLabel.text = String(v)
        patchData.defaults.set(&patchData.defaults.notificationsMinutesBefore, to: v)
        appDelegate.notificationsController.resendAllEstrogenNotifications()
    }
    
    @IBAction func selectDefaultButtonTapped(_ sender: UIButton) {
        if let id = sender.restorationIdentifier?.dropLast() {
            let key = String(id)
            if let def = PDDefault(rawValue: key) {
                preparePicker(def, sender: sender)
            }
        }
    }
    
    @IBAction func notificationsSwitched(_ sender: Any) {
        let shouldReceive = notificationsSwitch.isOn
        shouldReceive ? enableNotificationButtons() : disableNotificationButtons()
        patchData.defaults.set(&patchData.defaults.notifications, to: shouldReceive)
    }
    
    // MARK: - Public
    
    // MARK: - Data loaders
    
    private func loadDeliveryMethod() {
        deliveryMethodButton.setTitle(PatchDataShell.currentDeliveryMethod, for: .normal)
    }
    
    private func loadExpirationInterval() {
        let interval = patchData.defaults.expirationInterval.humanPresentableValue
        intervalButton.setTitle(interval, for: .normal)
    }
    
    private func loadQuantity() {
        let q = patchData.defaults.quantity.value.rawValue
        quantityButton.setTitle("\(q)", for: .normal)
        if patchData.defaults.deliveryMethod.value != .Patches {
            quantityButton.isEnabled = false
            quantityArrowButton.isEnabled = false
            if q != 1 {
                patchData.defaults.setQuantityWithoutWarning(to: 1)
            }
        }
    }

    private func loadNotifications() {
        notificationsSwitch.setOn(patchData.defaults.notifications.value, animated: false)
    }
    
    private func loadNotificationsMinutesBefore() {
        if notificationsSwitch.isOn {
            let min = patchData.defaults.notificationsMinutesBefore.value
            notificationsMinutesBeforeSlider.value = Float(min)
            notificationsMinutesBeforeValueLabel.text = String(min)
            notificationsMinutesBeforeValueLabel.textColor = UIColor.black
        } else {
            notificationsMinutesBeforeValueLabel.textColor = UIColor.lightGray
        }
    }
    
    private func loadTheme() {
        let theme = patchData.defaults.theme.value
        let title = PDPickerStrings.getTheme(for: theme)
        themeButton.setTitle(title, for: .normal)
    }

    // MARK: - Picker Functions
    
    private func delegatePickers() {
        deliveryMethodPicker.delegate = self
        expirationIntervalPicker.delegate = self
        quantityPicker.delegate = self
        themePicker.delegate = self
    }
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    internal func pickerView(_ pickerView: UIPickerView,
                             numberOfRowsInComponent component: Int) -> Int {
        return PatchDataShell.getDefaultOptionsCount(for: getWhichTapped())
    }
    
    internal func pickerView(_ pickerView: UIPickerView,
                             titleForRow row: Int,
                             forComponent component: Int) -> String? {
        var title = " "
        if let key = getWhichTapped() {
            let data = PatchDataShell.getPickerStrings(for: key)
            if row < data.count && row >= 0 {
                title = data[row]
            }
        }
        return title
    }
    
    /** Selector method for openOrClose(picker, buttonTapped, selections)
     // -- loads proper UI elements specific to each picker
     // -- hides everything that is not that picker
     
     // key is either "interval" , "count" , "notifications" */
    private func preparePicker(_ key: PDDefault, sender: UIButton) {
        var picker: UIPickerView?
        let selections = PatchDataShell.getPickerStrings(for: key)
        let choice = sender.titleLabel?.text
        let start = SettingsModel.getIndex(selections: selections, choice: choice)
        
        setWhichTapped(to: key)
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
        default:
            print("Error: Improper context for loading UIPicker.")
            return
        }
        
        let p = picker!
        p.reloadAllComponents()
        deselectEverything(except: key)
        openOrClose(picker: p, buttonTapped: sender, selections: selections, key: key, row: start)
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
        if key == PDDefault.Quantity {
            patchData.state.oldQuantity = patchData.defaults.quantity.value.rawValue
        }
        self.saveFromPicker(key, selectedRow: row)
    }
    
    // For regular pickers
    private func openOrClose(picker: UIPickerView,
                             buttonTapped: UIButton,
                             selections: [String],
                             key: PDDefault,
                             row: Int) {
        if picker.isHidden == false {
            closePicker(buttonTapped, picker, key, row: row)
        } else {
            buttonTapped.isSelected = true
            openPicker(buttonTapped, selections, picker, selectedRow: row)
        }
    }
    
    // MARK: - Saving
    
    /// Saves values from pickers (NOT a function for TimePickers though).
    private func saveFromPicker(_ key: PDDefault, selectedRow: Int?) {
        var resendBegin: Index = 0
        var resendEnd: Index = 0
        if let row = selectedRow {
            switch key {
            case .DeliveryMethod :
                resendBegin = patchData.defaults.quantity.rawValue - 1
                saveDeliveryMethodChange(row)
                resendEnd = row
            case .Quantity :
                resendBegin = patchData.defaults.quantity.rawValue - 1
                resendEnd = row
                saveQuantityChange(row)
            case .ExpirationInterval :
                resendBegin = 0
                resendEnd = patchData.defaults.quantity.rawValue - 1
                saveIntervalChange(row)
            case .Theme :
                saveThemeChange(row)
            default:
                print("Error: Improper context when saving details from picker")
            }
            let n = appDelegate.notificationsController
            n.resendEstrogenNotifications(begin: resendBegin, end: resendEnd)
        }
    }
    
    private func saveDeliveryMethodChange(_ row: Int) {
        let deliv = PatchDataShell.getDeliveryMethod(at: row)
        let title = PDPickerStrings.getDeliveryMethod(for: deliv)
        setButtonsFromDeliveryMethodChange(choice: deliv)
        deliveryMethodButton.setTitle(title, for: .normal)
        
        if !PatchDataShell.setDeliveryMethodIfSafe(to: deliv) {
            alertForChangingDeliveryMethod(choice: deliv)
        }
    }
    
    private func saveQuantityChange(_ row: Int) {
        let old = patchData.state.oldQuantity
        let reset = makeResetClosure(oldCount: old)
        let cancel = makeCancelClosure(oldCount: old)
        let res = PatchDataShell.setQuantity(to: row, oldQuantityRaw: old, reset: reset, cancel: cancel)
        if res.didSet {
            quantityButton.setTitle("\(res.newQuantityRaw)", for: .normal)
        } else {
            print("Error: no index for row \(row)")
        }
    }
    
    private func saveIntervalChange(_ row: Int) {
        let result = PatchDataShell.setExpirationIntervalIfSafe(at: row)
        if result.didSet {
            intervalButton.setTitle(result.chosenIntervalRaw, for: .normal)
            appDelegate.notificationsController.resendAllEstrogenNotifications()
        } else {
            print("Error: no expiration interval for row \(row)")
        }
    }
    
    private func saveThemeChange(_ row: Int) {
        let theme = PatchDataShell.setThemeIfSafe(toMethodAt: row)
        if theme != "" {
            appDelegate.resetTheme()
            themeButton.setTitle(theme, for: .normal)
        } else {
            print("Error: no theme for row \(row)")
        }
    }
    
    // MARK: - Setters and getters
    
    private func setWhichTapped(to tappedDef: PDDefault) {
        whichTapped = tappedDef
    }

    
    private func getWhichTapped() -> PDDefault? {
        return whichTapped
    }
    
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
        patchData.defaults.set(&patchData.defaults.notificationsMinutesBefore, to: 0)
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
            intervalButton.isSelected = false
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
        let save = PDStrings.ActionStrings.save
        deliveryMethodButton.setTitle(save, for: .selected)
        intervalButton.setTitle(save, for: .selected)
        quantityButton.setTitle(save, for: .selected)
        themeButton.setTitle(save, for: .selected)
    }
    
    private func loadButtonDisabledStates() {
            quantityButton.setTitleColor(UIColor.lightGray, for: .disabled)
    }
    
    private func setTopConstraint() {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.phone) {
            topConstraint.constant = 100
        }
    }
    
    private func setButtonsFromDeliveryMethodChange(choice: DeliveryMethod) {
        let quantityTitle = PDPickerStrings.getDeliveryMethod(for: choice)
        switch choice {
        case .Patches:
            quantityButton.setTitle(quantityTitle, for: .disabled)
            quantityButton.setTitle(quantityTitle, for: .normal)
            quantityButton.isEnabled = true
            quantityArrowButton.isEnabled = true
        case .Injections:
            quantityButton.setTitle(quantityTitle, for: .disabled)
            quantityButton.setTitle(quantityTitle, for: .normal)
            quantityButton.isEnabled = false
            quantityArrowButton.isEnabled = false
        }
    }
    
    private func alertForChangingDeliveryMethod(choice: DeliveryMethod) {
        PDAlertController.alertForChangingDeliveryMethod(newMethod: choice,
                                                         oldMethod: patchData.defaults.deliveryMethod.value,
                                                         oldCount: patchData.defaults.quantity.value,
                                                         deliveryButton: deliveryMethodButton,
                                                         countButton: quantityButton,
                                                         settingsVC: self)
    }
    
    private func makeResetClosure(oldCount: Int) -> ((Int) -> ()) {
        let reset: (Int) -> () = {
            newCount in
            appDelegate.tabs?.reflectExpirationCountAsBadgeValue()
            let n = appDelegate.notificationsController
            n.cancelEstrogenNotifications(from: newCount, to: oldCount)
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
        view.backgroundColor = appDelegate.themeManager.bg_c
        settingsView.backgroundColor = appDelegate.themeManager.bg_c
        settingsStack.backgroundColor = appDelegate.themeManager.bg_c
        deliveryMethodButton.setTitleColor(appDelegate.themeManager.text_c, for: .normal)
        intervalButton.setTitleColor(appDelegate.themeManager.text_c, for: .normal)
        quantityButton.setTitleColor(appDelegate.themeManager.text_c, for: .normal)
        notificationsSwitch.backgroundColor = appDelegate.themeManager.bg_c
        notificationsMinutesBeforeSlider.backgroundColor = appDelegate.themeManager.bg_c
        dmSideView.backgroundColor = appDelegate.themeManager.bg_c
        deliveryMethodSideView.backgroundColor = appDelegate.themeManager.bg_c
        quantitySideView.backgroundColor = appDelegate.themeManager.bg_c
        notificationsSideView.backgroundColor = appDelegate.themeManager.bg_c
        notMinBeforeSideView.backgroundColor = appDelegate.themeManager.bg_c
        themeSideView.backgroundColor = appDelegate.themeManager.bg_c
    }
}

extension SettingsVC: UIScrollViewDelegate {
    
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return settingsStack
    }
}
