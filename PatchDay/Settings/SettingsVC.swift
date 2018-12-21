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
typealias SettingsKey = PDStrings.SettingsKey

class SettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Description: This is the view controller for the Settings View.  The Settings View is where the user may select their defaults, which are saved and used during future PatchDay use.  The defaults can alMOEstrogenst be broken up into two topics:  the Schedule Outlets and the Notification Outlets.  The Schedule Outlets include the interval that the patches expire, and the number of patches in the schedule.  The Notification Outlets include the Bool for whether the user wants to receive a reminder, and the time before patch expiration when the user wants to receive the reminder.  There is also a Bool for whether the user wishes to use the "Autofill Site Functionality". UserDefaultsController is the object responsible saving and loading the settings that the user chooses here.
    
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    // Pickers
    @IBOutlet weak var deliveryMethodPicker: UIPickerView!
    @IBOutlet private weak var expirationIntervalPicker: UIPickerView!
    @IBOutlet private weak var countPicker: UIPickerView!
    @IBOutlet fileprivate weak var settingsStack: UIStackView!

    // trackers
    private var whichTapped: SettingsKey?
    private var selectedRow: Int?
    
    // Schedule outlets (in order of appearance
    @IBOutlet private weak var settingsView: UIView!
    @IBOutlet private weak var intervalButton: UIButton!
    @IBOutlet weak var deliveryMethodButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet private weak var countButton: UIButton!
    @IBOutlet weak var countButtonArrow: UIButton!
    @IBOutlet private weak var suggestSiteLabel: UILabel!
    @IBOutlet private weak var suggestSiteFunctionality_switched: UISwitch!
    
    // Notification outlets (in order of appearance)
    @IBOutlet private weak var receiveReminder_switch: UISwitch!
    @IBOutlet private weak var reminderTimeLabel: UILabel!
    @IBOutlet weak var reminderTimeSettingsLabel: UILabel!
    @IBOutlet weak var reminderTimeSlider: UISlider!
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let estroController = ScheduleController.estrogenController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = PDStrings.VCTitles.settings
        countLabel.text = PDStrings.ColonedStrings.count
        
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.phone) {
            topConstraint.constant = 100
        }
        
        // Button selected states
        deliveryMethodButton.setTitle(PDStrings.ActionStrings.save, for: .selected)
        intervalButton.setTitle(PDStrings.ActionStrings.save, for: .selected)
        countButton.setTitle(PDStrings.ActionStrings.save, for: .selected)
        
        // Disabled states
        countButton.setTitleColor(UIColor.lightGray, for: .disabled)
        
        countButton.tag = 10
        settingsView.backgroundColor = UIColor.white
        delegatePickers()
        
        // Load data into titles
        loadDeliveryMethod()
        loadReminder_bool()
        loadInterval()
        loadCount()
        loadRemindMinutes()
        
 }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ScheduleController.estrogenController.getEffectManager().oldDeliveryCount = UserDefaultsController.getQuantityInt()
    }
      
    // MARK: - Data loaders
    
    private func loadDeliveryMethod() {
        deliveryMethodButton.setTitle(UserDefaultsController.getDeliveryMethod(), for: .normal)
    }
    
    private func loadInterval() {
        intervalButton.setTitle(UserDefaultsController.getTimeIntervalString(), for: .normal)
    }
    
    private func loadCount() {
        countButton.setTitle(UserDefaultsController.getQuantityString(), for: .normal)
        if UserDefaultsController.getDeliveryMethod() == "Injection" {
            countButton.isEnabled = false
            countButtonArrow.isEnabled = false
            if UserDefaultsController.getQuantityInt() != 1 {
                UserDefaultsController.setQuantityWithoutWarning(to: "1")
            }
        }
    }

    private func loadReminder_bool() {
        receiveReminder_switch.setOn(UserDefaultsController.getRemindMeUpon(), animated: false)
    }
    
    private func loadRemindMinutes() {
        if receiveReminder_switch.isOn {
            let v = UserDefaultsController.getNotificationMinutesBefore()
            reminderTimeSlider.value = Float(v)
            reminderTimeSettingsLabel.text = String(v)
            reminderTimeSettingsLabel.textColor = UIColor.black
        }
        else {
            reminderTimeSettingsLabel.textColor = UIColor.lightGray
        }
    }

    // MARK: - Picker Functions
    
    private func delegatePickers() {
        deliveryMethodPicker.delegate = self
        expirationIntervalPicker.delegate = self
        countPicker.delegate = self
    }
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /// Row count.
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0;
        
        if let key = getWhichTapped() {
            switch key {
            case PDStrings.SettingsKey.deliv:                            // DELIVERY METHOD
                numberOfRows = PDStrings.PickerData.deliveryMethods.count
            case PDStrings.SettingsKey.count:                                     // COUNT
                numberOfRows = PDStrings.PickerData.counts.count
            case PDStrings.SettingsKey.interval:                                  // INTERVAL
                numberOfRows = PDStrings.PickerData.expirationIntervals.count
            default:
                print("Error:  Improper context when selecting picker selections count")
            }
        }
        return numberOfRows
        
    }
    
    /// Row titles.
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title = " "
        if let key = getWhichTapped(){
            switch key {
            case PDStrings.SettingsKey.deliv:
                if row < PDStrings.PickerData.deliveryMethods.count && row >= 0 {
                    title = PDStrings.PickerData.deliveryMethods[row]
                }
            case PDStrings.SettingsKey.interval:
                if row < PDStrings.PickerData.expirationIntervals.count && row >= 0 {
                    title = PDStrings.PickerData.expirationIntervals[row]
                }
            case PDStrings.SettingsKey.count:
                if row < PDStrings.PickerData.counts.count && row >= 0 {
                    title = PDStrings.PickerData.counts[row]
                }
            default:
                print("Error:  Improper context for loading PickerView")
            }
        }
        return title
    }
    
    // while picker changes
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
    
    /** Selector method for openOrClose(picker, buttonTapped, selections)
     // -- loads proper UI elements specific to each picker
     // -- hides everything that is not that picker
     
     // key is either "interval" , "count" , "notifications" */
    private func openOrClosePicker(key: SettingsKey) {
        
        // Change member variable for determining correct picker
        setWhichTapped(to: key)
        switch key {
        case PDStrings.SettingsKey.deliv:                // DELIVERY METHOD
            deliveryMethodPicker.reloadAllComponents()
            deselectEverything(except: "dm")
            openOrClose(picker: deliveryMethodPicker, buttonTapped: deliveryMethodButton, selections: PDStrings.PickerData.deliveryMethods, key: key)
        case PDStrings.SettingsKey.interval:                      // INTERVAL
            expirationIntervalPicker.reloadAllComponents()
            deselectEverything(except: "i")
            openOrClose(picker: expirationIntervalPicker, buttonTapped: intervalButton, selections: PDStrings.PickerData.expirationIntervals, key: key)
        case PDStrings.SettingsKey.count:                         // COUNT
            countPicker.reloadAllComponents()
            deselectEverything(except: "c")
            openOrClose(picker: countPicker, buttonTapped: countButton, selections: PDStrings.PickerData.counts, key: key)
        default:
            print("Error: Improper context for loading UIPicker.")
        }
    }
    
    /** Select the button,
       And for count, set global variable necessary for animation,
       And close the picker,
       Then, save newly set User Defaults */
    private func closePicker(_ buttonTapped: UIButton,_ picker: UIPickerView,_ key: SettingsKey) {
        buttonTapped.isSelected = false
        picker.isHidden = true
        switch key {
        case PDStrings.SettingsKey.count :
            ScheduleController.estrogenController.getEffectManager().oldDeliveryCount = UserDefaultsController.getQuantityInt()
        default :
            break
        }
        self.saveFromPicker(key)
    }
    
    private func openPicker(_ buttonTapped: UIButton,_ selections: [String],_ picker: UIPickerView) {
        // Picker starting row
        if let title = buttonTapped.titleLabel, let readText = title.text {
            guard let selectedRowIndex = selections.index(of: readText) else {
                picker.selectRow(0, inComponent: 0, animated: false)
                UIView.transition(with: picker as UIView, duration: 0.4, options: .transitionCrossDissolve, animations: { picker.isHidden = false
                }, completion: nil)
                return
            }
            picker.selectRow(selectedRowIndex, inComponent: 0, animated: true)
        }
        
        UIView.transition(with: picker as UIView, duration: 0.4, options: .transitionFlipFromTop, animations: { picker.isHidden = false
        }, completion: nil)
    }
    
    // For regular pickers
    private func openOrClose(picker: UIPickerView, buttonTapped: UIButton, selections: [String], key: SettingsKey) {
        if picker.isHidden == false {
            closePicker(buttonTapped, picker, key)
        }
        else {
            buttonTapped.isSelected = true
            openPicker(buttonTapped, selections, picker)
        }
    }
    
    // MARK: - Saving
    
    private func saveDeliveryMethodChange(_ row: Int) {
        if row < PDStrings.PickerData.deliveryMethods.count && row >= 0 {
            let choice = PDStrings.PickerData.deliveryMethods[row]
            // Set injection Button
            if choice == PDStrings.PickerData.deliveryMethods[1] {
                countButton.setTitle(PDStrings.PickerData.counts[0], for: .disabled)
                countButton.setTitle(PDStrings.PickerData.counts[0], for: .normal)
                countButton.isEnabled = false
                countButtonArrow.isEnabled = false
            }
            // Set patch Buttons
            else {
                countButton.setTitle(PDStrings.PickerData.counts[2], for: .disabled)
                countButton.setTitle(PDStrings.PickerData.counts[2], for: .normal)
                countButton.isEnabled = true
                countButtonArrow.isEnabled = true
            }
            deliveryMethodButton.setTitle(choice, for: .normal)
            
            // Check to see if there are changes to the site schedule
            if PDEstrogenHelper.isEmpty(ScheduleController.estrogenController.estrogenArray) && ScheduleController.siteController.isDefault() {
                UserDefaultsController.setDeliveryMethod(to: choice)
                UserDefaultsController.setSiteIndex(to: 0)
                resetEstrogensVCTabBarItem()
                ScheduleController.setEstrogenDataForToday()
            }
                // Alert the user their current site schedule will be erased
            else {
                PDAlertController.alertForChangingDeliveryMethod(newMethod: choice, oldMethod: UserDefaultsController.getDeliveryMethod(), oldCount: UserDefaultsController.getQuantityInt(), deliveryButton: deliveryMethodButton, countButton: countButton, settingsVC: self)
            }
        } else {
            print("Error: saving delivery method for index for row  + \(row)")
        }
    }
    
    private func saveCountChange(_ row: Int) {
        let oldCount = ScheduleController.estrogenController.getEffectManager().oldDeliveryCount
        if row < PDStrings.PickerData.counts.count && row >= 0, let newCount = Int(PDStrings.PickerData.counts[row]) {
            UserDefaultsController.setQuantityWithWarning(to: newCount, oldCount: oldCount, countButton: countButton, navController: self.navigationController) {
                newCount in
                let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                for i in (newCount-1)..<oldCount {
                    appDelegate.notificationsController.cancelEstrogenNotification(at: i)
                }
            }
            countButton.setTitle("\(newCount)", for: .normal)
        } else {
            print("Error: saving count for index for row \(row)")
        }
    }
    
    private func saveIntervalChange(_ row: Int) {
        if row < PDStrings.PickerData.expirationIntervals.count && row >= 0 {
            let choice = PDStrings.PickerData.expirationIntervals[row]
            UserDefaultsController.setTimeInterval(to: choice)
            intervalButton.setTitle(choice, for: .normal)
            appDelegate.notificationsController.resendAllEstrogenNotifications()
        }
        else {
            print("Error: saving expiration interval for row \(row)")
        }
    }
    
    private func saveNotificationChange(_ value: Float) {
        if value >= 0 {
            
        }
    }
 
    /// Saves values from pickers (NOT a function for TimePickers though).
    private func saveFromPicker(_ key: SettingsKey) {
        if let row = selectedRow {
            
            let oldHighest = UserDefaultsController.getQuantityInt() - 1
            
            switch key {
            case PDStrings.SettingsKey.deliv:
                saveDeliveryMethodChange(row)
            case PDStrings.SettingsKey.count:
                saveCountChange(row)
            case PDStrings.SettingsKey.interval:
                saveIntervalChange(row)
            default:
                print("Error: Improper context when saving details from picker")
            }

            // Resend notifications
            let newHighest = UserDefaultsController.getQuantityInt() - 1
            appDelegate.notificationsController.resendEstrogenNotifications(upToRemove: oldHighest, upToAdd: newHighest)
        }
    }
 
    // MARK: - Actions
    
    @IBAction func reminderTimeValueChanged(_ sender: Any) {
        let v = Int(reminderTimeSlider.value.rounded())
        reminderTimeSettingsLabel.text = String(v)
        UserDefaultsController.setNotificationMinutesBefore(to: v)
        self.appDelegate.notificationsController.resendAllEstrogenNotifications()
       
    }
    
    @IBAction private func reminderTimeTapped(_ sender: Any) {
       openOrClosePicker(key: PDStrings.SettingsKey.notif)
    }
    
    @IBAction func deliveryMethodButtonTapped(_ sender: Any) {
        openOrClosePicker(key: PDStrings.SettingsKey.deliv)
    }
    
    @IBAction private func intervalButtonTapped(_ sender: Any) {
        openOrClosePicker(key: PDStrings.SettingsKey.interval)
    }
    
    @IBAction private func countButtonTapped(_ sender: Any) {
        openOrClosePicker(key: PDStrings.SettingsKey.count)
    }
    
    // MARK: - Actions switches
    
    @IBAction func receiveReminder_switched(_ sender: Any) {
        let shouldReceive = receiveReminder_switch.isOn
        // fix buttons
        if shouldReceive {
            enableNotificationButtons()
        }
        else {
            disableNotificationButtons()
        }
        UserDefaultsController.setNotify(to: shouldReceive)       // save
    }
    
    // MARK: - Setters and getters
    
    private func setWhichTapped(to: SettingsKey?) {
        whichTapped = to
    }
    
    private func getWhichTapped() -> SettingsKey? {
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
        UserDefaultsController.setNotificationMinutesBefore(to: 0)
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
    }
    
    /// Resets the title of the Estrogens tab bar item to either "Patches" or "Injections".
    public func resetEstrogensVCTabBarItem() {
        let v = ScheduleController.totalEstrogenDue(intervalStr: UserDefaultsController.getTimeIntervalString())
        // Estrogen icon
        if let vcs = navigationController?.tabBarController?.viewControllers, vcs.count > 0 {
            vcs[0].tabBarItem.badgeValue = v > 0 ? String(v) : nil
            if UserDefaultsController.usingPatches() {
                vcs[0].tabBarItem.image = #imageLiteral(resourceName: "Patch Icon")
                vcs[0].tabBarItem.selectedImage = #imageLiteral(resourceName: "Patch Icon")
                vcs[0].tabBarItem.title = PDStrings.VCTitles.patches
            }
            else {
                vcs[0].tabBarItem.image = #imageLiteral(resourceName: "Injection Icon")
                vcs[0].tabBarItem.selectedImage = #imageLiteral(resourceName: "Injection Icon")
                vcs[0].tabBarItem.title = PDStrings.VCTitles.injections
            }
            vcs[0].awakeFromNib()
        }
    }
    
}

extension SettingsVC: UIScrollViewDelegate {
    
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return settingsStack
    }
}
