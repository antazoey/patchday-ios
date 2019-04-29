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
    
    // Top level
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var settingsStack: UIStackView!
    @IBOutlet private weak var settingsView: UIView!
    
    // Labels
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet private weak var reminderTimeLabel: UILabel!
    @IBOutlet weak var reminderTimeSettingsLabel: UILabel!

    // Pickers
    @IBOutlet weak var deliveryMethodPicker: UIPickerView!
    @IBOutlet private weak var expirationIntervalPicker: UIPickerView!
    @IBOutlet private weak var countPicker: UIPickerView!
    @IBOutlet weak var themePicker: UIPickerView!

    // Buttons
    @IBOutlet private weak var intervalButton: UIButton!
    @IBOutlet weak var deliveryMethodButton: UIButton!
    @IBOutlet private weak var countButton: UIButton!
    @IBOutlet weak var countArrowButton: UIButton!
    @IBOutlet weak var themeButton: UIButton!
    
    // Other
    @IBOutlet private weak var receiveReminderSwitch: UISwitch!
    @IBOutlet weak var reminderTimeSlider: UISlider!
    
    // Trackers
    private var whichTapped: PDDefault?
    private var selectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = PDStrings.VCTitles.settings
        countLabel.text = PDStrings.ColonedStrings.count
        countButton.tag = 10
        settingsView.backgroundColor = UIColor.white
        setTopConstraint()
        loadButtonSelectedStates()
        loadButtonDisabledStates()
        delegatePickers()
        loadDeliveryMethod()
        loadReminder_bool()
        loadInterval()
        loadCount()
        loadRemindMinutes()
        loadTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        patchData.state.oldDeliveryCount = patchData.defaults.quantity.value.rawValue
    }
    
    // MARK: - Actions
    
    @IBAction func reminderTimeValueChanged(_ sender: Any) {
        let v = Int(reminderTimeSlider.value.rounded())
        reminderTimeSettingsLabel.text = String(v)
        patchData.defaults.set(&patchData.defaults.notificationsMinutesBefore, to: v)
        appDelegate.notificationsController.resendAllEstrogenNotifications()
    }
    
    @IBAction private func reminderTimeTapped(_ sender: Any) {
        preparePicker(.Notifications)
    }
    
    @IBAction func deliveryMethodButtonTapped(_ sender: Any) {
        preparePicker(.DeliveryMethod)
    }
    
    @IBAction private func intervalButtonTapped(_ sender: Any) {
        preparePicker(.ExpirationInterval)
    }
    
    @IBAction private func countButtonTapped(_ sender: Any) {
        preparePicker(.Quantity)
    }
    
    @IBAction private func themeButtonTapped(_ sender: Any) {
        preparePicker(.Theme)
    }
    
    @IBAction func receiveReminder_switched(_ sender: Any) {
        let shouldReceive = receiveReminderSwitch.isOn
        if shouldReceive {
            enableNotificationButtons()
        } else {
            disableNotificationButtons()
        }
        patchData.defaults.set(&patchData.defaults.notifications, to: shouldReceive)
    }
    
    // MARK: - Public
    
    /// Resets the title of the Estrogens tab bar item to either "Patches" or "Injections".
    public func resetEstrogensVCTabBarItem() {
        let interval = patchData.defaults.expirationInterval
        let v = patchData.schedule.totalDue(interval: interval)
        // Estrogen icon
        if let vcs = navigationController?.tabBarController?.viewControllers, vcs.count > 0 {
            vcs[0].tabBarItem.badgeValue = v > 0 ? String(v) : nil
            let deliv = patchData.defaults.deliveryMethod.value
            switch deliv {
            case .Patches:
                vcs[0].tabBarItem.image = #imageLiteral(resourceName: "Patch Icon")
                vcs[0].tabBarItem.selectedImage = #imageLiteral(resourceName: "Patch Icon")
                vcs[0].tabBarItem.title = PDStrings.VCTitles.patches
            case .Injections:
                vcs[0].tabBarItem.image = #imageLiteral(resourceName: "Injection Icon")
                vcs[0].tabBarItem.selectedImage = #imageLiteral(resourceName: "Injection Icon")
                vcs[0].tabBarItem.title = PDStrings.VCTitles.injections
            }
            vcs[0].awakeFromNib()
        }
    }
      
    // MARK: - Data loaders
    
    private func loadDeliveryMethod() {
        let deliv = patchData.defaults.deliveryMethod.value.rawValue
        deliveryMethodButton.setTitle(deliv, for: .normal)
    }
    
    private func loadInterval() {
        let interval = patchData.defaults.expirationInterval.value.rawValue
        intervalButton.setTitle(interval, for: .normal)
    }
    
    private func loadCount() {
        let q = patchData.defaults.quantity.value.rawValue
        countButton.setTitle("\(q)", for: .normal)
        if patchData.defaults.deliveryMethod.value != .Patches {
            countButton.isEnabled = false
            countArrowButton.isEnabled = false
            if q != 1 {
                patchData.defaults.setQuantityWithoutWarning(to: 1)
            }
        }
    }

    private func loadReminder_bool() {
        receiveReminderSwitch.setOn(patchData.defaults.notifications.value, animated: false)
    }
    
    private func loadRemindMinutes() {
        if receiveReminderSwitch.isOn {
            let min = patchData.defaults.notificationsMinutesBefore.value
            reminderTimeSlider.value = Float(min)
            reminderTimeSettingsLabel.text = String(min)
            reminderTimeSettingsLabel.textColor = UIColor.black
        } else {
            reminderTimeSettingsLabel.textColor = UIColor.lightGray
        }
    }
    
    private func loadTheme() {
        themeButton.setTitle(patchData.defaults.theme.value.rawValue, for: .normal)
    }

    // MARK: - Picker Functions
    
    private func delegatePickers() {
        deliveryMethodPicker.delegate = self
        expirationIntervalPicker.delegate = self
        countPicker.delegate = self
        themePicker.delegate = self
    }
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    internal func pickerView(_ pickerView: UIPickerView,
                             numberOfRowsInComponent component: Int) -> Int {
        if let key = getWhichTapped() {
            return getPickerCount(from: key)
        }
        return 0
    }
    
    internal func pickerView(_ pickerView: UIPickerView,
                             titleForRow row: Int,
                             forComponent component: Int) -> String? {
        var title = " "
        if let key = getWhichTapped() {
            let count = getPickerCount(from: key)
            if row < count && row >= 0 {
                switch key {
                case .DeliveryMethod :
                    title = PDStrings.PickerData.deliveryMethods[row]
                case .ExpirationInterval :
                    title = PDStrings.PickerData.expirationIntervals[row]
                case .Quantity :
                    title = PDStrings.PickerData.counts[row]
                case .Theme :
                    title = PDStrings.PickerData.themes[row]
                default:
                    print("Error:  Improper context for loading PickerView")
                }
            }
        }
        return title
    }
    
    internal func pickerView(_ pickerView: UIPickerView,
                             didSelectRow row: Int,
                             inComponent component: Int) {
        selectedRow = row
    }
    
    /** Selector method for openOrClose(picker, buttonTapped, selections)
     // -- loads proper UI elements specific to each picker
     // -- hides everything that is not that picker
     
     // key is either "interval" , "count" , "notifications" */
    private func preparePicker(_ key: PDDefault) {
        var picker: UIPickerView?
        var deselectException: String?
        var button: UIButton?
        var selections: [String]?
        
        setWhichTapped(to: key)
        switch key {
        case .DeliveryMethod:
            picker = deliveryMethodPicker
            deselectException = "dm"
            button = deliveryMethodButton
            selections = PDStrings.PickerData.deliveryMethods
        case .ExpirationInterval:
            picker = expirationIntervalPicker
            deselectException = "i"
            button = intervalButton
            selections = PDStrings.PickerData.expirationIntervals
            expirationIntervalPicker.reloadAllComponents()
            deselectEverything(except: "i")
        case .Quantity:
            picker = countPicker
            deselectException = "c"
            button = countButton
            selections = PDStrings.PickerData.counts
        case .Theme:
            picker = themePicker
            deselectException = "t"
            button = themeButton
            selections = PDStrings.PickerData.themes
        default:
            print("Error: Improper context for loading UIPicker.")
            return
        }
        
        let p = picker!
        p.reloadAllComponents()
        deselectEverything(except: deselectException!)
        openOrClose(picker: p, buttonTapped: button!, selections: selections!, key: key)
    }
    
    private func openPicker(_ buttonTapped: UIButton,_ selections: [String],_ picker: UIPickerView) {
        // Picker starting row
        if let title = buttonTapped.titleLabel,
            let readText = title.text,
            let selectedRowIndex = selections.firstIndex(of: readText) {
            picker.selectRow(selectedRowIndex, inComponent: 0, animated: true)
        }
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
    private func closePicker(_ buttonTapped: UIButton,_ picker: UIPickerView, _ key: PDDefault) {
        buttonTapped.isSelected = false
        picker.isHidden = true
        switch key {
        case .Quantity :
            patchData.state.oldDeliveryCount = patchData.defaults.quantity.value.rawValue
        default :
            break
        }
        self.saveFromPicker(key)
    }
    
    // For regular pickers
    private func openOrClose(picker: UIPickerView,
                             buttonTapped: UIButton,
                             selections: [String],
                             key: PDDefault) {
        if picker.isHidden == false {
            closePicker(buttonTapped, picker, key)
        } else {
            buttonTapped.isSelected = true
            openPicker(buttonTapped, selections, picker)
        }
    }
    
    // MARK: - Saving
    
    /// Saves values from pickers (NOT a function for TimePickers though).
    private func saveFromPicker(_ key: PDDefault) {
        if let row = selectedRow {
            let oldHighest = patchData.defaults.quantity.value.rawValue - 1
            switch key {
            case .DeliveryMethod :
                saveDeliveryMethodChange(row)
            case .Quantity :
                saveCountChange(row)
            case .ExpirationInterval :
                saveIntervalChange(row)
            case .Theme :
                saveThemeChange(row)
            default:
                print("Error: Improper context when saving details from picker")
            }
            resendNotifications(oldHighest: oldHighest)
        }
    }
    
    private func saveDeliveryMethodChange(_ row: Int) {
        if row < PDStrings.PickerData.deliveryMethods.count && row >= 0 {
            let choice = PDStrings.PickerData.deliveryMethods[row]
            if let deliv = DeliveryMethod(rawValue: choice) {
                setButtonsFromDeliveryMethodChange(choice:  deliv)
                deliveryMethodButton.setTitle(choice, for: .normal)
                if patchData.estrogenSchedule.isEmpty() &&
                    patchData.siteSchedule.isDefault(deliveryMethod: deliv) {
                    
                    patchData.defaults.setDeliveryMethod(to: deliv)
                    patchData.defaults.setSiteIndex(to: 0)
                    resetEstrogensVCTabBarItem()
                    patchData.schedule.setEstrogenDataForToday()
                } else {
                    alertForChangingDeliveryMethod(choice: deliv)
                }
            }
        } else {
            print("Error: no delivery method for row  + \(row)")
        }
    }
    
    private func saveCountChange(_ row: Int) {
        let oldC = patchData.state.oldDeliveryCount
        if row < PDStrings.PickerData.counts.count && row >= 0,
            let oldCount = Quantity(rawValue: oldC),
            let newC = Int(PDStrings.PickerData.counts[row]),
            let newCount = Quantity(rawValue: newC) {
            let reset = makeResetClosure(oldCount: oldC)
            let cancel = makeCancelClosure(oldCount: oldC)
            patchData.defaults.setQuantityWithWarning(to: newCount,
                                                      oldQ: oldCount,
                                                      reset: reset,
                                                      cancel: cancel)
            countButton.setTitle("\(newCount)", for: .normal)
        } else {
            print("Error: no index for row \(row)")
        }
    }
    
    private func saveIntervalChange(_ row: Int) {
        let choice = PDStrings.PickerData.expirationIntervals[row]
        if row < PDStrings.PickerData.expirationIntervals.count && row >= 0,
            let i = ExpirationInterval(rawValue: choice) {
            
            patchData.defaults.set(&patchData.defaults.expirationInterval, to: i)
            intervalButton.setTitle(choice, for: .normal)
            appDelegate.notificationsController.resendAllEstrogenNotifications()
        } else {
            print("Error: no expiration interval for row \(row)")
        }
    }
    
    private func saveThemeChange(_ row: Int) {
            let choice = PDStrings.PickerData.themes[row]
        if row < PDStrings.PickerData.themes.count && row >= 0,
            let theme = PDTheme(rawValue: choice) {
            
            patchData.defaults.set(&patchData.defaults.theme, to: theme)
            appDelegate.resetTheme()
            navigationController?.navigationBar.barTintColor = appDelegate.themeManager.navbar_c
            navigationController?.navigationBar.tintColor = appDelegate.themeManager.button_c
            tabBarController?.tabBar.barTintColor = appDelegate.themeManager.navbar_c
            tabBarController?.tabBar.tintColor = appDelegate.themeManager.button_c
            themeButton.setTitle(choice, for: .normal)
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
        reminderTimeSlider.isEnabled = true
        reminderTimeSettingsLabel.textColor = UIColor.black
    }
    
    private func disableNotificationButtons() {
        reminderTimeSlider.isEnabled = false
        reminderTimeSettingsLabel.textColor = UIColor.lightGray
        reminderTimeSettingsLabel.text = "0"
        patchData.defaults.set(&patchData.defaults.notificationsMinutesBefore, to: 0)
        reminderTimeSlider.value = 0
    }
    
    private func deselectEverything(except: String) {
        if except != "dm" {
            deliveryMethodPicker.isHidden = true
            deliveryMethodButton.isSelected = false
        }
        if except != "i" {
            expirationIntervalPicker.isHidden = true
            intervalButton.isSelected = false
        }
        if except != "c" {
            countPicker.isHidden = true
            countButton.isSelected = false
        }
        if except != "t" {
            themePicker.isHidden = true
            themeButton.isSelected = false
        }
    }
    
    private func loadButtonSelectedStates() {
        let save = PDStrings.ActionStrings.save
        deliveryMethodButton.setTitle(save, for: .selected)
        intervalButton.setTitle(save, for: .selected)
        countButton.setTitle(save, for: .selected)
        themeButton.setTitle(save, for: .selected)
    }
    
    private func loadButtonDisabledStates() {
        countButton.setTitleColor(UIColor.lightGray, for: .disabled)
    }
    
    private func setTopConstraint() {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.phone) {
            topConstraint.constant = 100
        }
    }
    
    private func getPickerCount(from key: PDDefault) -> Int {
        switch (key) {
        case .DeliveryMethod:
            return PDStrings.PickerData.deliveryMethods.count
        case .ExpirationInterval:
            return PDStrings.PickerData.expirationIntervals.count
        case .Quantity:
            return PDStrings.PickerData.counts.count
        case .Theme:
            return PDStrings.PickerData.themes.count
        default:
            return 0
        }
    }
    
    private func setButtonsFromDeliveryMethodChange(choice: DeliveryMethod) {
        switch choice {
        case .Patches:
            countButton.setTitle(PDStrings.PickerData.counts[2], for: .disabled)
            countButton.setTitle(PDStrings.PickerData.counts[2], for: .normal)
            countButton.isEnabled = true
            countArrowButton.isEnabled = true
        case .Injections:
            countButton.setTitle(PDStrings.PickerData.counts[0], for: .disabled)
            countButton.setTitle(PDStrings.PickerData.counts[0], for: .normal)
            countButton.isEnabled = false
            countArrowButton.isEnabled = false
        }
    }
    
    private func alertForChangingDeliveryMethod(choice: DeliveryMethod) {
        PDAlertController.alertForChangingDeliveryMethod(newMethod: choice,
                                                         oldMethod: patchData.defaults.deliveryMethod.value,
                                                         oldCount: patchData.defaults.quantity.value,
                                                         deliveryButton: deliveryMethodButton,
                                                         countButton: countButton,
                                                         settingsVC: self)
    }
    
    private func setTabBadge() {
        let tabController = self.navigationController?.tabBarController
        if let vcs = tabController?.viewControllers, vcs.count > 0 {
            let interval = patchData.defaults.expirationInterval
            let c = patchData.estrogenSchedule.totalDue(interval)
            let item = vcs[0].navigationController?.tabBarItem
            item?.badgeValue = (c > 0) ? "\(c)" : nil
        }
    }
    
    private func makeResetClosure(oldCount: Int) -> ((Int) -> ()) {
        let reset: (Int) -> () = {
            newCount in
            self.setTabBadge()
            self.cancelNotifications(newCount: newCount, oldCount: oldCount)
        }
        return reset
    }
    
    private func makeCancelClosure(oldCount: Int) -> ((Int) -> ()) {
        let cancel: (Int) -> () = {
            oldCount in
            self.countButton.setTitle(String(oldCount), for: .normal)
        }
        return cancel
    }
    
    private func resendNotifications(oldHighest: Int) {
        let q = patchData.defaults.quantity.value.rawValue
        let newHighest = q - 1
        let notCon = appDelegate.notificationsController
        notCon.resendEstrogenNotifications(upToRemove: oldHighest, upToAdd: newHighest)
    }
    
    private func cancelNotifications(newCount: Int, oldCount: Int) {
        for i in (newCount-1)..<oldCount {
            appDelegate.notificationsController.cancelEstrogenNotification(at: i)
        }
    }
}

extension SettingsVC: UIScrollViewDelegate {
    
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return settingsStack
    }
}
