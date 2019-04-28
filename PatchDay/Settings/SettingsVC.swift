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
    private var whichTapped: PDDefaults.PDDefault?
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
        State.oldDeliveryCount = Defaults.quantity
    }
    
    // MARK: - Actions
    
    @IBAction func reminderTimeValueChanged(_ sender: Any) {
        let v = Int(reminderTimeSlider.value.rounded())
        reminderTimeSettingsLabel.text = String(v)
        Defaults.set(&Defaults.notificationsMinutesBefore, to: v, for: .NotificationMinutesBefore)
        appDelegate.notificationsController.resendAllEstrogenNotifications()
        
    }
    
    @IBAction private func reminderTimeTapped(_ sender: Any) {
        preparePicker(key: .Notifications)
    }
    
    @IBAction func deliveryMethodButtonTapped(_ sender: Any) {
        preparePicker(key: .DeliveryMethod)
    }
    
    @IBAction private func intervalButtonTapped(_ sender: Any) {
        preparePicker(key: .TimeInterval)
    }
    
    @IBAction private func countButtonTapped(_ sender: Any) {
        preparePicker(key: .Quantity)
    }
    
    @IBAction private func themeButtonTapped(_ sender: Any) {
        preparePicker(key: .Theme)
    }
    
    @IBAction func receiveReminder_switched(_ sender: Any) {
        let shouldReceive = receiveReminderSwitch.isOn
        if shouldReceive {
            enableNotificationButtons()
        } else {
            disableNotificationButtons()
        }
        Defaults.set(&Defaults.notifications, to: shouldReceive, for: .Notifications)
    }
    
    // MARK: - Public
    
    /// Resets the title of the Estrogens tab bar item to either "Patches" or "Injections".
    public func resetEstrogensVCTabBarItem() {
        let interval = Defaults.timeInterval
        let v = Schedule.totalDue(interval: interval)
        // Estrogen icon
        if let vcs = navigationController?.tabBarController?.viewControllers, vcs.count > 0 {
            vcs[0].tabBarItem.badgeValue = v > 0 ? String(v) : nil
            let deliv = Defaults.getDeliveryMethod()
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
        let deliv = Defaults.deliveryMethod
        deliveryMethodButton.setTitle(deliv, for: .normal)
    }
    
    private func loadInterval() {
        let interval = Defaults.timeInterval
        intervalButton.setTitle(interval, for: .normal)
    }
    
    private func loadCount() {
        let q = Defaults.quantity
        countButton.setTitle("\(q)", for: .normal)
        if Defaults.getDeliveryMethod() != .Patches {
            countButton.isEnabled = false
            countArrowButton.isEnabled = false
            if q != 1 {
                Defaults.setQuantityWithoutWarning(to: 1)
            }
        }
    }

    private func loadReminder_bool() {
        receiveReminderSwitch.setOn(Defaults.notifications, animated: false)
    }
    
    private func loadRemindMinutes() {
        if receiveReminderSwitch.isOn {
            let min = Defaults.notificationsMinutesBefore
            reminderTimeSlider.value = Float(min)
            reminderTimeSettingsLabel.text = String(min)
            reminderTimeSettingsLabel.textColor = UIColor.black
        } else {
            reminderTimeSettingsLabel.textColor = UIColor.lightGray
        }
    }
    
    private func loadTheme() {
        themeButton.setTitle(Defaults.theme, for: .normal)
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
                case .TimeInterval :
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
    private func preparePicker(key: PDDefaults.PDDefault) {
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
        case .TimeInterval:
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
    private func closePicker(_ buttonTapped: UIButton,_ picker: UIPickerView,_ key: PDDefaults.PDDefault) {
        buttonTapped.isSelected = false
        picker.isHidden = true
        switch key {
        case .Quantity :
            State.oldDeliveryCount = Defaults.quantity
        default :
            break
        }
        self.saveFromPicker(key)
    }
    
    // For regular pickers
    private func openOrClose(picker: UIPickerView,
                             buttonTapped: UIButton,
                             selections: [String],
                             key: PDDefaults.PDDefault) {
        if picker.isHidden == false {
            closePicker(buttonTapped, picker, key)
        } else {
            buttonTapped.isSelected = true
            openPicker(buttonTapped, selections, picker)
        }
    }
    
    // MARK: - Saving
    
    /// Saves values from pickers (NOT a function for TimePickers though).
    private func saveFromPicker(_ key: PDDefaults.PDDefault) {
        if let row = selectedRow {
            let oldHighest = Defaults.quantity - 1
            switch key {
            case .DeliveryMethod :
                saveDeliveryMethodChange(row)
            case .Quantity :
                saveCountChange(row)
            case .TimeInterval :
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
            setButtonsFromDeliveryMethodChange(choice:  choice)
            deliveryMethodButton.setTitle(choice, for: .normal)
            handleSiteScheduleChanges(choice: choice)
        } else {
            print("Error: no delivery method for row  + \(row)")
        }
    }
    
    private func saveCountChange(_ row: Int) {
        let oldCount = State.oldDeliveryCount
        if row < PDStrings.PickerData.counts.count && row >= 0,
            let newCount = Int(PDStrings.PickerData.counts[row]) {
            let reset = makeResetClosure(oldCount: oldCount)
            let cancel = makeCancelClosure(oldCount: oldCount)
            Defaults.setQuantityWithWarning(to: newCount,
                                            oldCount: oldCount,
                                            reset: reset,
                                            cancel: cancel)
            countButton.setTitle("\(newCount)", for: .normal)
        } else {
            print("Error: no index for row \(row)")
        }
    }
    
    private func saveIntervalChange(_ row: Int) {
        if row < PDStrings.PickerData.expirationIntervals.count && row >= 0 {
            let choice = PDStrings.PickerData.expirationIntervals[row]
            Defaults.setTimeInterval(to: choice)
            intervalButton.setTitle(choice, for: .normal)
            appDelegate.notificationsController.resendAllEstrogenNotifications()
        } else {
            print("Error: no expiration interval for row \(row)")
        }
    }
    
    private func saveThemeChange(_ row: Int) {
        if row < PDStrings.PickerData.themes.count && row >= 0 {
            let choice = PDStrings.PickerData.themes[row]
            Defaults.set(&Defaults.theme, to: choice, for: .Theme)
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
    
    private func setWhichTapped(to: PDDefaults.PDDefault?) {
        whichTapped = to
    }
    
    private func getWhichTapped() -> PDDefaults.PDDefault? {
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
        Defaults.set(&Defaults.notificationsMinutesBefore, to: 0, for: .NotificationMinutesBefore)
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
    
    private func getPickerCount(from key: PDDefaults.PDDefault) -> Int {
        switch (key) {
        case .DeliveryMethod :
            return PDStrings.PickerData.deliveryMethods.count
        case .TimeInterval :
            return PDStrings.PickerData.expirationIntervals.count
        case .Quantity :
            return PDStrings.PickerData.counts.count
        case .Theme :
            return PDStrings.PickerData.themes.count
        default:
            return 0
        }
    }
    
    private func setButtonsFromDeliveryMethodChange(choice: String) {
        if choice == PDStrings.PickerData.deliveryMethods[1] {
            countButton.setTitle(PDStrings.PickerData.counts[0], for: .disabled)
            countButton.setTitle(PDStrings.PickerData.counts[0], for: .normal)
            countButton.isEnabled = false
            countArrowButton.isEnabled = false
        } else {
            countButton.setTitle(PDStrings.PickerData.counts[2], for: .disabled)
            countButton.setTitle(PDStrings.PickerData.counts[2], for: .normal)
            countButton.isEnabled = true
            countArrowButton.isEnabled = true
        }
    }
    
    private func handleSiteScheduleChanges(choice: String) {
        let deliv = Defaults.getDeliveryMethod()
        if EstrogenScheduleRef.isEmpty() &&
            SiteScheduleRef.isDefault(deliveryMethod: deliv) {
            Defaults.setDeliveryMethod(to: choice)
            Defaults.setSiteIndex(to: 0)
            resetEstrogensVCTabBarItem()
            Schedule.setEstrogenDataForToday()
        } else {
            alertForChangingDeliveryMethod(choice: choice)
        }
    }
    
    private func alertForChangingDeliveryMethod(choice: String) {
        PDAlertController.alertForChangingDeliveryMethod(newMethod: choice,
                                                         oldMethod: Defaults.deliveryMethod,
                                                         oldCount: Defaults.quantity,
                                                         deliveryButton: deliveryMethodButton,
                                                         countButton: countButton,
                                                         settingsVC: self)
    }
    
    private func setTabBadge() {
        let tabController = self.navigationController?.tabBarController
        if let vcs = tabController?.viewControllers, vcs.count > 0 {
            let interval = Defaults.timeInterval
            let c = EstrogenScheduleRef.totalDue(interval)
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
        let q = Defaults.quantity
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
