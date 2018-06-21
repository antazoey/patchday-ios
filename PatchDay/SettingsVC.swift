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
typealias SettingsKey = PDStrings.SettingsKey

class SettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Description: This is the view controller for the Settings View.  The Settings View is where the user may select their defaults, which are saved and used during future PatchDay use.  The defaults can alMOEstrogenst be broken up into two topics:  the Schedule Outlets and the Notification Outlets.  The Schedule Outlets include the interval that the patches expire, and the number of patches in the schedule.  The Notification Outlets include the Bool for whether the user wants to receive a reminder, and the time before patch expiration when the user wants to receive the reminder.  There is also a Bool for whether the user wishes to use the "Autofill Site Functionality". UserDefaultsController is the object responsible saving and loading the settings that the user chooses here.
    
    // Pickers
    @IBOutlet weak var deliveryMethodPicker: UIPickerView!
    @IBOutlet private weak var expirationIntervalPicker: UIPickerView!
    @IBOutlet private weak var countPicker: UIPickerView!
    @IBOutlet private weak var reminderTimePicker: UIPickerView!
    @IBOutlet fileprivate weak var settingsStack: UIStackView!
    @IBOutlet var tb1_time_picker_view: UIView!
    @IBOutlet var tb1_time_picker: UIDatePicker!
    @IBOutlet var tb2_time_picker_view: UIView!
    @IBOutlet var tb2_time_picker: UIDatePicker!
    @IBOutlet var pg1_time_picker_view: UIView!
    @IBOutlet var pg1_time_picker: UIDatePicker!
    @IBOutlet var pg2_time_picker_view: UIView!
    @IBOutlet var pg2_time_picker: UIDatePicker!

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
    
    // Pill outlets (in order of appearance)
    @IBOutlet weak var tb_stack: UIStackView!
    @IBOutlet weak var tb_daily_big: UIButton!
    @IBOutlet weak var tb_daily_small: UIButton!
    @IBOutlet weak var tb_daily_picker: UIPickerView!
    @IBOutlet weak var tb_switch: UISwitch!
    @IBOutlet weak var tb1_time_big: UIButton!
    @IBOutlet weak var tb1_time_label: UILabel!
    @IBOutlet weak var tb1_time_small: UIButton!
    @IBOutlet weak var tb2_time_stack: UIStackView!
    @IBOutlet weak var tb2_time_big: UIButton!
    @IBOutlet weak var tb2_time_small: UIButton!
    @IBOutlet weak var tb_remind_switch: UISwitch!
    @IBOutlet weak var pg_stack: UIStackView!
    @IBOutlet weak var pg_daily_big: UIButton!
    @IBOutlet weak var pg_daily_small: UIButton!
    @IBOutlet weak var pg_daily_picker: UIPickerView!
    @IBOutlet weak var pg_switch: UISwitch!
    @IBOutlet weak var pg1_time_label: UILabel!
    @IBOutlet weak var pg1_time_big: UIButton!
    @IBOutlet weak var pg1_time_small: UIButton!
    @IBOutlet weak var pg2_time_stack: UIStackView!
    @IBOutlet weak var pg2_time_big: UIButton!
    @IBOutlet weak var pg2_time_small: UIButton!
    @IBOutlet weak var pg_remind_switch: UISwitch!
    
    // Notification outlets (in order of appearance)
    @IBOutlet private weak var receiveReminder_switch: UISwitch!
    @IBOutlet private weak var reminderTimeLabel: UILabel!
    @IBOutlet private weak var reminderTimeButton: UIButton!
    @IBOutlet private weak var reminderTimeArrow: UIButton!
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // sites nav button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: PDStrings.titleStrings.sites, style: .plain, target: self, action: #selector(segueToSites))
        
        countLabel.text = PDStrings.colonedStrings.count
        
        // set button selected states
        deliveryMethodButton.setTitle(PDStrings.actionStrings.save, for: .selected)
        intervalButton.setTitle(PDStrings.actionStrings.save, for: .selected)
        countButton.setTitle(PDStrings.actionStrings.save, for: .selected)
        tb_daily_big.setTitle(PDStrings.actionStrings.save, for: .selected)
        tb1_time_big.setTitle(PDStrings.actionStrings.save, for: .selected)
        tb2_time_big.setTitle(PDStrings.actionStrings.save, for: .selected)
        pg_daily_big.setTitle(PDStrings.actionStrings.save, for: .selected)
        pg1_time_big.setTitle(PDStrings.actionStrings.save, for: .selected)
        pg2_time_big.setTitle(PDStrings.actionStrings.save, for: .selected)
        reminderTimeButton.setTitle(PDStrings.actionStrings.save, for: .selected)
        
        // set disabled states
        countButton.setTitleColor(UIColor.lightGray, for: .disabled)
        tb1_time_big.setTitleColor(UIColor.lightGray, for: .disabled)
        tb2_time_big.setTitleColor(UIColor.lightGray, for: .disabled)
        tb_daily_big.setTitleColor(UIColor.lightGray, for: .disabled)
        pg1_time_big.setTitleColor(UIColor.lightGray, for: .disabled)
        pg2_time_big.setTitleColor(UIColor.lightGray, for: .disabled)
        pg_daily_big.setTitleColor(UIColor.lightGray, for: .disabled)
 
        // other
        countButton.tag = 10
        settingsView.backgroundColor = UIColor.white
        delegatePickers()
        
        // load titles
        loadDeliveryMethod()
        loadReminder_bool()
        loadInterval()
        loadIncludeTB()
        loadTBDaily()
        loadTB1Time()
        loadTB2Time()
        loadTBRemind()
        if PillDataController.getTBDailyInt() == 1 {
            disableTBTime2()
        }
        loadIncludePG()
        loadPGDaily()
        loadPG1Time()
        loadPG2Time()
        loadPGRemind()
        if PillDataController.getPGDailyInt() == 1 {
            disablePGTime2()
        }
        loadCount()
        loadNotificationOption()

 }
    
    override func viewWillAppear(_ animated: Bool) {
        // Set animation related Var
        ScheduleController.oldDeliveryCount = UserDefaultsController.getQuantityInt()
    }
      
    // MARK: - Data loaders
    
    private func loadDeliveryMethod() {
        deliveryMethodButton.setTitle(UserDefaultsController.getDeliveryMethod(), for: .normal)
    }
    
    private func loadInterval() {
        intervalButton.setTitle(UserDefaultsController.getTimeInterval(), for: .normal)
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
    
    private func loadIncludeTB() {
        tb_switch.setOn(PillDataController.includingTB(), animated: false)
    }
    
    private func loadTBDaily() {
        tb_daily_big.setTitle(String(PillDataController.getTBDailyString()), for: .normal)
    }
    
    private func loadTB1Time() {
        if PillDataController.includingTB() {
            tb1_time_big.setTitle(PDDateHelper.format(time: PillDataController.getTB1Time()), for: .normal)
        }
        // disable tb buttons
        else {
            tb1_time_big.isEnabled = false
            tb2_time_big.isEnabled = false
            tb1_time_small.isEnabled = false
            tb2_time_small.isEnabled = false
            tb_daily_big.isEnabled = false
            tb_daily_small.isEnabled = false
            tb_remind_switch.isEnabled = false
        }
    }
    
    // loads safely - doesn't load improper tb2
    private func loadTB2Time() {
        var tb2 = PillDataController.getTB2Time()
        if PillDataController.includingTB() {
            // if TB2 is improperly smaller than TB1, set it as TB1
            loadCautiously(time1: PillDataController.getTB1Time(), time2: &tb2, mode: 0)
            }
            tb2_time_big.setTitle(PDDateHelper.format(time: tb2), for: .normal)
    }
    
    private func loadTBRemind() {
        tb_remind_switch.setOn(PillDataController.getRemindTB(), animated: false)
    }
    
    private func loadIncludePG() {
        pg_switch.setOn(PillDataController.includingPG(), animated: false)
    }
    
    private func loadPGDaily() {
        pg_daily_big.setTitle(String(PillDataController.getPGDailyString()), for: .normal)
    }
    
    private func loadPG1Time() {
        if PillDataController.includingPG() {
            pg1_time_big.setTitle(PDDateHelper.format(time: PillDataController.getPG1Time()), for: .normal)
        }
        // disable pg buttons
        else {
            pg1_time_big.isEnabled = false
            pg1_time_small.isEnabled = false
            pg2_time_big.isEnabled = false
            pg2_time_small.isEnabled = false
            pg_daily_big.isEnabled = false
            pg_daily_small.isEnabled = false
            pg_remind_switch.isEnabled = false
        }
    }
    
    // load safely - doesn't load improper pg2
    private func loadPG2Time() {
        var pg2 = PillDataController.getPG2Time()
        if PillDataController.includingPG() {
            // if PG2 is improperly smaller than PG1, set it as PG1
            loadCautiously(time1: PillDataController.getPG1Time(), time2: &pg2, mode: 0)
        }
        pg2_time_big.setTitle(PDDateHelper.format(time: pg2), for: .normal)
    }
    
    private func loadPGRemind() {
        pg_remind_switch.setOn(PillDataController.getRemindPG(), animated: false)
    }

    private func loadReminder_bool() {
        receiveReminder_switch.setOn(UserDefaultsController.getRemindMeUpon(), animated: false)
    }
    
    private func loadNotificationOption() {
        if receiveReminder_switch.isOn {
            enableNotificationButtons()
        }
        else {
            disableNotificationButtons()
        }
        let title = UserDefaultsController.getNotificationTimeString()
        reminderTimeButton.setTitle(title, for: .normal)
    }

    // MARK: - Picker Functions
    
    private func delegatePickers() {
        deliveryMethodPicker.delegate = self
        expirationIntervalPicker.delegate = self
        countPicker.delegate = self
        reminderTimePicker.delegate = self
        tb_daily_picker.delegate = self
        pg_daily_picker.delegate = self
    }
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // NUM OF ROWS...
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0;
        
        if let key = getWhichTapped() {
            switch key {
            case PDStrings.SettingsKey.deliv:                            // DELIVERY METHOD
                numberOfRows = PDStrings.pickerData.deliveryMethods.count
                break
            case PDStrings.SettingsKey.count:                                     // COUNT
                numberOfRows = PDStrings.pickerData.counts.count
                break
            case PDStrings.SettingsKey.interval:                                  // INTERVAL
                numberOfRows = PDStrings.pickerData.expirationIntervals.count
                break
            case PDStrings.SettingsKey.tbDaily, PDStrings.SettingsKey.pgDaily:        // TIMESADAY
                numberOfRows = PDStrings.pickerData.pillCounts.count
                break
            case PDStrings.SettingsKey.notif:                                     // NOTIF
                numberOfRows = PDStrings.pickerData.notificationTimes.count
                break
            default:
                print("Error:  Improper context when selecting picker selections count")
            }
        }
        return numberOfRows
        
    }
    
    // ROW TITLES...
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title = " "
        if let key = getWhichTapped(){
            switch key {
            case PDStrings.SettingsKey.deliv:
                if row < PDStrings.pickerData.deliveryMethods.count && row >= 0 {
                    title = PDStrings.pickerData.deliveryMethods[row]
                }
            case PDStrings.SettingsKey.interval:
                if row < PDStrings.pickerData.expirationIntervals.count && row >= 0 {
                    title = PDStrings.pickerData.expirationIntervals[row]
                }
                break
            case PDStrings.SettingsKey.count:
                if row < PDStrings.pickerData.counts.count && row >= 0 {
                    title = PDStrings.pickerData.counts[row]
                }
                break
            case PDStrings.SettingsKey.tbDaily, PDStrings.SettingsKey.pgDaily:
                if row < PDStrings.pickerData.pillCounts.count && row >= 0 {
                    title = PDStrings.pickerData.pillCounts[row]
                }
                break
            case PDStrings.SettingsKey.notif:
                if row < PDStrings.pickerData.notificationTimes.count && row >= 0 {
                    title = PDStrings.pickerData.notificationTimes[row]
                }
                break
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
    
    private func openOrClosePicker(key: SettingsKey) {
        
        // Selector method for openOrClose(picker, buttonTapped, selections)
        // -- loads proper UI elements specific to each picker
        // -- hides everything that is not that picker
        
        // key is either "interval" , "count" , "notifications"
        
        // change member variable for determining correct picker
        setWhichTapped(to: key)
        switch key {
        case PDStrings.SettingsKey.deliv:                // DELIVERY METHOD
            deliveryMethodPicker.reloadAllComponents()
            deselectEverything(except: "dm")
            openOrClose(picker: deliveryMethodPicker, buttonTapped: deliveryMethodButton, selections: PDStrings.pickerData.deliveryMethods, key: key)
        case PDStrings.SettingsKey.interval:                      // INTERVAL
            expirationIntervalPicker.reloadAllComponents()
            deselectEverything(except: "i")
            openOrClose(picker: expirationIntervalPicker, buttonTapped: intervalButton, selections: PDStrings.pickerData.expirationIntervals, key: key)
            break
        case PDStrings.SettingsKey.count:                         // COUNT
            countPicker.reloadAllComponents()
            deselectEverything(except: "c")
            openOrClose(picker: countPicker, buttonTapped: countButton, selections: PDStrings.pickerData.counts, key: key)
            break
        case PDStrings.SettingsKey.tbDaily:                      // TB TIMESADAY
            tb_daily_picker.reloadAllComponents()
            deselectEverything(except: "tb")
            openOrClose(picker: tb_daily_picker, buttonTapped: tb_daily_big, selections: PDStrings.pickerData.pillCounts, key: key)
            break
        case PDStrings.SettingsKey.pgDaily:                      // PG TIMESADAY
            pg_daily_picker.reloadAllComponents()
            deselectEverything(except: "pg")
            openOrClose(picker: pg_daily_picker, buttonTapped: pg_daily_big, selections: PDStrings.pickerData.pillCounts, key: key)
            break
        case PDStrings.SettingsKey.notif:                         // NOTIFICATION TIME BEFORE
            reminderTimePicker.reloadAllComponents()
            // close other pickers / deselect
            deselectEverything(except: "r")
            openOrClose(picker: reminderTimePicker, buttonTapped: reminderTimeButton, selections: PDStrings.pickerData.notificationTimes, key: key)
            break
        default:
            print("Error: Improper context for loading UIPicker.")
        }
    }
    
    // Select the button,
    // And for count, set global variable necessary for animation,
    // And close the picker,
    // Then, save newly set User Defaults
    private func closePicker(_ buttonTapped: UIButton,_ picker: UIPickerView,_ key: SettingsKey) {
        buttonTapped.isSelected = false
        UIView.transition(with: picker as UIView, duration: 0.4, options: .transitionFlipFromTop, animations: { picker.isHidden = true
        }) {
            (void) in
            // Global var necessary for animation:
            switch key {
            case PDStrings.SettingsKey.count :
                ScheduleController.oldDeliveryCount = UserDefaultsController.getQuantityInt()
                break
            case PDStrings.SettingsKey.tbDaily :
                self.tb2_time_big.setTitle(PDDateHelper.format(time: PillDataController.getTB2Time()), for: .normal)
            case PDStrings.SettingsKey.pgDaily :
                self.pg2_time_big.setTitle(PDDateHelper.format(time: PillDataController.getPG2Time()), for: .normal)
            default :
                break
            }
            self.saveFromPicker(key)
        }
    }
    
    private func openPicker(_ buttonTapped: UIButton,_ selections: [String],_ picker: UIPickerView) {
        // Picker starting row
        if let title = buttonTapped.titleLabel, let readText = title.text {
            guard let selectedRowIndex = selections.index(of: readText) else {
                picker.selectRow(0, inComponent: 0, animated: false)
                UIView.transition(with: picker as UIView, duration: 0.4, options: .transitionFlipFromTop, animations: { picker.isHidden = false
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
        if row < PDStrings.pickerData.deliveryMethods.count && row >= 0 {
            let choice = PDStrings.pickerData.deliveryMethods[row]
            // Injections
            if choice == PDStrings.pickerData.deliveryMethods[1] {
                countButton.setTitle(PDStrings.pickerData.counts[0], for: .disabled)
                countButton.setTitle(PDStrings.pickerData.counts[0], for: .normal)
                countButton.isEnabled = false
                countButtonArrow.isEnabled = false
            }
                // Patches
            else {
                countButton.setTitle(PDStrings.pickerData.counts[2], for: .disabled)
                countButton.setTitle(PDStrings.pickerData.counts[2], for: .normal)
                countButton.isEnabled = true
                countButtonArrow.isEnabled = true
            }
            deliveryMethodButton.setTitle(choice, for: .normal)
            
            // No Warning
            if ScheduleController.estrogenSchedule().isEmpty() && ScheduleController.siteSchedule().isDefault() {
                UserDefaultsController.setDeliveryMethod(to: choice)
            }
                // Alert if there is some data that should be erased
            else {
                PDAlertController.alertForChangingDeliveryMethod(newMethod: choice, oldMethod: UserDefaultsController.getDeliveryMethod(), oldCount: UserDefaultsController.getQuantityInt(), deliveryButton: deliveryMethodButton, countButton: countButton)
            }
        }
        else {
            print("Error: saving delivery method for index for row " + String(row))
        }
    }
    
    private func saveCountChange(_ row: Int) {
        let oldCount = ScheduleController.oldDeliveryCount
        if row < PDStrings.pickerData.counts.count && row >= 0 {
            let choice = PDStrings.pickerData.counts[row]
            UserDefaultsController.setQuantityWithWarning(to: choice, oldCount: oldCount, countButton: countButton)
            countButton.setTitle(choice, for: .normal)
        }
        else {
            print("Error: saving count for index for row " + String(row))
        }
    }
    
    private func saveIntervalChange(_ row: Int) {
        if row < PDStrings.pickerData.expirationIntervals.count && row >= 0 {
            let choice = PDStrings.pickerData.expirationIntervals[row]
            UserDefaultsController.setTimeInterval(to: choice)
            intervalButton.setTitle(choice, for: .normal)
        }
        else {
            print("Error: saving expiration interval for row " + String(row))
        }
    }
    
    private func saveTBDaily(_ row: Int) {
        if row < PDStrings.pickerData.pillCounts.count && row >= 0, let c = Int(PDStrings.pickerData.pillCounts[row]) {
            PillDataController.setTBDaily(to: c)
            (c == 1) ? disableTBTime2() : enableTBTime2()
            tb_daily_big.setTitle(String(c), for: .normal)
            disableExtraTB()
            if PillDataController.getRemindTB() {
                appDelegate.notificationsController.requestNotifyTakePill(mode: 0)
            }
        }
        else {
            print("Error: saving TB timesday for row " + String(row))
        }
    }
    
    private func savePGDaily(_ row: Int) {
        if row < PDStrings.pickerData.pillCounts.count && row >= 0, let c = Int(PDStrings.pickerData.pillCounts[row]) {
            PillDataController.setPGDaily(to: c)
            (c == 1) ? disablePGTime2() : enablePGTime2()
            pg_daily_big.setTitle(String(c), for: .normal)
            disableExtraPG()
            if PillDataController.getRemindPG() {
                appDelegate.notificationsController.requestNotifyTakePill(mode: 1)
            }
        }
        else {
            print("Error: saving PG timesday for row " + String(row))
        }
    }
    
    private func saveNotificationChange(_ row: Int) {
        if row < PDStrings.pickerData.notificationTimes.count && row >= 0 {
            let choice = PDStrings.pickerData.notificationTimes[row]
            UserDefaultsController.setNotificationOption(to: choice)
            let title = choice
            reminderTimeButton.setTitle(title, for: .normal)
        }
        else {
            print("Error: saving notification time for row " + String(row))
        }
    }
 
    // Saves values from pickers (NOT a function for TimePickers though).
    private func saveFromPicker(_ key: SettingsKey) {
        if let row = selectedRow {
            
            let oldHighest = UserDefaultsController.getQuantityInt() - 1
            var shouldResend = true
            
            switch key {
            case PDStrings.SettingsKey.deliv:
                saveDeliveryMethodChange(row)
                break
            case PDStrings.SettingsKey.count:
                saveCountChange(row)
                break
            case PDStrings.SettingsKey.interval:
                saveIntervalChange(row)
                break
            case PDStrings.SettingsKey.tbDaily:
                saveTBDaily(row)
                shouldResend = false
                break
            case PDStrings.SettingsKey.pgDaily:
                savePGDaily(row)
                shouldResend = false
                break
            case PDStrings.SettingsKey.notif:
                saveNotificationChange(row)
                break
            default:
                print("Error: Improper context when saving details from picker")
            }
            // if should resend notifications...
            if shouldResend {
                let newHighest = UserDefaultsController.getQuantityInt() - 1
                resendScheduleNotifications(upToRemove: oldHighest, upToAdd: newHighest)
            }
        }
    }
    
    // MARK: - Date Picker funcs
    
    // chooseTime(mode, timeButton, timePickerView, timesaday, startTime, maxOrMin) :
    // 1.) Creates the correct time picker
    // 2.) deselects other pickers
    // 3.) opens the selected picker.
    // 4.) Sets max or min (based on other Time) and start time.
    func chooseTime(mode: String, timeButton: UIButton, timePickerView: UIView, timesaday: Int, startTime: Time, maxOrMin: Time) {
        // create picker view
        let timePickerPoint = CGPoint(x: 0, y: 40)
        let timePickerSize = CGSize(width: 0, height: 0)
        let timePickerRect = CGRect(origin: timePickerPoint, size: timePickerSize)
        let timePicker: UITimePicker = UITimePicker(frame: timePickerRect)
        timePicker.datePickerMode = UIDatePickerMode.time
        
        deselectEverything(except: mode)
        timeButton.isSelected = true
    
        switch mode {
        case "t":   // TBLOCK TIME 1 PICKER
            tb1_time_picker = timePicker
            tb1_time_picker.date = startTime
            tb1_time_picker.maximumDate = (timesaday == 2) ? maxOrMin : nil
            break
        case "u":   // TBLOCK TIME 2 PICKER
            tb2_time_picker = timePicker
            tb2_time_picker.date = startTime
            tb2_time_picker.minimumDate = maxOrMin
            break
        case "p":   // PG TIME 1 PICKER
            pg1_time_picker = timePicker
            pg1_time_picker.date = startTime
            pg1_time_picker.maximumDate = (timesaday == 2) ? maxOrMin : nil
            break
        case "q":   // PG TIME 2 PICKER
            pg2_time_picker = timePicker
            pg2_time_picker.date = startTime
            pg2_time_picker.minimumDate = maxOrMin
            break
        default:
            print("Error: Improper mode for choosing time picker.")
        }
        timePickerView.addSubview(timePicker)
        UIView.transition(with: timePickerView as UIView, duration: 0.4, options: .transitionCrossDissolve, animations: { timePickerView.isHidden = false
        }, completion: nil)
    }
    
    /* datePickerDone(sender) : Function that
     1.) sets button title
     2.) saves the newly assigned times.
     3.) resends the notification for the correct time
    */
    internal func datePickerDone(id: String, time: Time, timeButton: UIButton, remind: Bool) {
        
        // ** THIS IS WHERE THE TIME BUTTON TITLE IS SET **
        timeButton.setTitle(PDDateHelper.format(time: time), for: .normal)
        
        switch id {
            // TB1 TIME
        case "bigT":
            PillDataController.setTB1Time(to: time)
            if remind {
                appDelegate.notificationsController.requestNotifyTakePill(mode: 0)
            }
            break
            // TB2 TIME
        case "bigT2":
            PillDataController.setTB2Time(to: time)
            if remind {
                appDelegate.notificationsController.requestNotifyTakePill(mode: 0)
            }
            break
            // PG1 TIME
        case "bigP":
            PillDataController.setPG1Time(to: time)
            if remind {
                appDelegate.notificationsController.requestNotifyTakePill(mode: 1)
            }
            break
            // PG2 TIME
        case "bigP2":
            PillDataController.setPG2Time(to: time)
            if remind {
                appDelegate.notificationsController.requestNotifyTakePill(mode: 1)
            }
            break
        default:
            print("Error: Improper buttonID when closing and saving date picker")
        }
    }
    
    @objc private func segueToSites() {
        if let sb = storyboard, let navCon = navigationController, let sitesVC: SitesVC = sb.instantiateViewController(withIdentifier: "SitesVC_id") as? SitesVC {
            sitesVC.title = PDStrings.titleStrings.sites
            navCon.pushViewController(sitesVC, animated: true)
        }
    }

    // MARK: - IBActions Picker loads

    @IBAction private func reminderTimeTapped(_ sender: Any) {
       openOrClosePicker(key: PDStrings.SettingsKey.notif)
    }
    
    @IBAction func tb_switched(_ sender: Any) {
        PillDataController.setIncludeTB(to: tb_switch.isOn)
        disableExtraTB()
        // USER JUST TURNED IT ON
        if tb_switch.isOn {
            tb1_time_big.setTitle(PDDateHelper.format(time: PillDataController.getTB1Time()), for: .normal)
            tb2_time_big.setTitle(PDDateHelper.format(time: PillDataController.getTB2Time()), for: .normal)
            tb1_time_big.isEnabled = true
            tb1_time_small.isEnabled = true
            tb_daily_big.isEnabled = true
            tb_daily_small.isEnabled = true
            tb_remind_switch.isEnabled = true
            if PillDataController.getTBDailyInt() == 2 {
                tb2_time_big.isEnabled = true
                tb2_time_small.isEnabled = true
            }
            if PillDataController.getRemindTB() {
                appDelegate.notificationsController.requestNotifyTakePill(mode: 0)
            }
        }
        // USER JUST TURNED IT OFF
        else {
            tb1_time_big.isEnabled = false
            tb1_time_small.isEnabled = false
            tb2_time_big.isEnabled = false
            tb2_time_small.isEnabled = false
            tb_daily_big.isEnabled = false
            tb_daily_small.isEnabled = false
            tb_remind_switch.isEnabled = false
            PillDataController.setTBDaily(to: 1)
            loadTBDaily()
            disableTBTime2()
            PillDataController.resetTB()
            appDelegate.notificationsController.cancelPills(identifiers: [PDStrings.notificationIDs.pillIDs[0]])
        }
    }
    
    @IBAction func tb_daily_tapped(_ sender: Any) {
        openOrClosePicker(key: PDStrings.SettingsKey.tbDaily)
    }
    
    @IBAction func tb1_tapped(_ sender: Any) {
        (tb1_time_picker_view.isHidden == false) ? closeTimePicker(timePicker: tb1_time_picker, timePickerView: tb1_time_picker_view, timeButton: tb1_time_big, remind: PillDataController.getRemindTB()) :  chooseTime(mode: "t", timeButton: tb1_time_big, timePickerView: tb1_time_picker_view, timesaday: PillDataController.getTBDailyInt(), startTime: PillDataController.getTB1Time(), maxOrMin: PillDataController.getTB2Time())
    }
    
    @IBAction func tb2_tapped(_ sender: Any) {
        (tb2_time_picker_view.isHidden == false) ? closeTimePicker(timePicker: tb2_time_picker, timePickerView: tb2_time_picker_view, timeButton: tb2_time_big, remind: PillDataController.getRemindTB()) :  chooseTime(mode: "u", timeButton: tb2_time_big, timePickerView: tb2_time_picker_view, timesaday: PillDataController.getTBDailyInt(), startTime: PillDataController.getTB2Time(), maxOrMin: PillDataController.getTB1Time())
    }
    
    @IBAction func tb_remind_switched(_ sender: Any) {
        let isOn = tb_switch.isOn
        if isOn {
            appDelegate.notificationsController.requestNotifyTakePill(mode: 0)
        }
        else {
            appDelegate.notificationsController.cancelPills(identifiers: [PDStrings.notificationIDs.pillIDs[0]])
        }
        PillDataController.setRemindTB(to: isOn)
    }
    
    @IBAction func pg_switched(_ sender: Any) {
        PillDataController.setIncludePG(to: pg_switch.isOn)
        disableExtraPG()
        // USER JUST TURNED IT ON
        if pg_switch.isOn {
            pg1_time_big.setTitle(PDDateHelper.format(time: PillDataController.getPG1Time()), for: .normal)
            pg2_time_big.setTitle(PDDateHelper.format(time: PillDataController.getPG2Time()), for: .normal)
            pg1_time_big.isEnabled = true
            pg1_time_small.isEnabled = true
            pg_daily_big.isEnabled = true
            pg_daily_small.isEnabled = true
            pg_daily_big.isSelected = false
            pg_remind_switch.isEnabled = true
            if PillDataController.getPGDailyInt() == 2 {
                pg2_time_big.isEnabled = true
                pg2_time_small.isEnabled = true
            }
            if PillDataController.getRemindPG() {
                appDelegate.notificationsController.requestNotifyTakePill(mode: 1)
            }
        }
        // USER JUST TURNED IT OFF
        else {
            pg1_time_big.isEnabled = false
            pg1_time_small.isEnabled = false
            pg2_time_big.isEnabled = false
            pg2_time_small.isEnabled = false
            pg_daily_big.isEnabled = false
            pg_daily_small.isEnabled = false
            pg_remind_switch.isEnabled = false
            disablePGTime2()
            PillDataController.setPGDaily(to: 1)
            loadPGDaily()
            PillDataController.resetPG()
            (UIApplication.shared.delegate as! AppDelegate).notificationsController.cancelPills(identifiers: [PDStrings.notificationIDs.pillIDs[1]])
            
        }
    }
    
    @IBAction func pg_daily_tapped(_ sender: Any) {
        openOrClosePicker(key: PDStrings.SettingsKey.pgDaily)
    }
    
    @IBAction func pg1_tapped(_ sender: Any) {
        (pg1_time_picker_view.isHidden == false) ? closeTimePicker(timePicker: pg1_time_picker, timePickerView: pg1_time_picker_view, timeButton: pg1_time_big, remind: PillDataController.getRemindPG()) :  chooseTime(mode: "p", timeButton: pg1_time_big, timePickerView: pg1_time_picker_view, timesaday: PillDataController.getPGDailyInt(), startTime: PillDataController.getPG1Time(), maxOrMin: PillDataController.getPG2Time())
    }
    
    @IBAction func pg2_tapped(_ sender: Any) {
        (pg2_time_picker_view.isHidden == false) ? closeTimePicker(timePicker: pg2_time_picker, timePickerView: pg2_time_picker_view, timeButton: pg2_time_big, remind: PillDataController.getRemindPG()) :  chooseTime(mode: "q", timeButton: pg2_time_big, timePickerView: pg2_time_picker_view, timesaday: PillDataController.getPGDailyInt(), startTime: PillDataController.getPG2Time(), maxOrMin: PillDataController.getPG1Time())
    }
    
    @IBAction func pg_remind_switched(_ sender: Any) {
        let isOn = pg_switch.isOn
        if isOn {
            appDelegate.notificationsController.requestNotifyTakePill(mode: 1)
        }
        else {
            appDelegate.notificationsController.cancelPills(identifiers: [PDStrings.notificationIDs.pillIDs[1]])
        }
        PillDataController.setRemindPG(to: isOn)
    }
    
    @IBAction func deliveryMethodButtonTapped(_ sender: Any) {
        openOrClosePicker(key: PDStrings.SettingsKey.deliv)
    }
    
    @IBAction private func intervalButtonTapped(_ sender: Any) {
        openOrClosePicker(key: PDStrings.SettingsKey.interval)
    }
    
    @IBAction private func countButtonTapped(_ sender: Any) {
        // change member variable for determining correct picker
        openOrClosePicker(key: PDStrings.SettingsKey.count)
    }
    
    // MARK: - IBActions switches
    
    @IBAction func receiveReminder_switched(_ sender: Any) {
        let shouldReceive = receiveReminder_switch.isOn
        // fix buttons
        if shouldReceive {
            enableNotificationButtons()
        }
        else {
            disableNotificationButtons()
        }
        UserDefaultsController.setRemindMeUpon(to: shouldReceive)       // save
    }
    
    // MARK: - set-and-getters
    
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
    
    // MARK: - private
    
    /* resendScheduleNotifications(upToRemove, upToAdd) :
       1.) upToRemove is highest old index, ones to delete.
       2.) upToAdd is the highest new index */
    private func resendScheduleNotifications(upToRemove: Int, upToAdd: Int) {
        for i in 0...upToRemove {
            appDelegate.notificationsController.cancelSchedule(index: i)
        }
        for j in 0...upToAdd {
            appDelegate.notificationsController.requestNotifyExpired(scheduleIndex: j)
        }
    }
    
    private func removeAllNotifications(last_i: Int) {
        for i in 0...last_i {
            appDelegate.notificationsController.cancelSchedule(index: i)
        }
    }
    
    // MARK: - View loading and altering
    
    private func enableNotificationButtons() {
        reminderTimeButton.setTitleColor(UIColor.blue, for: .normal)
        reminderTimeLabel.textColor = UIColor.black
        reminderTimeButton.isEnabled = true
        reminderTimeArrow.isEnabled = true
    }
    
    private func disableNotificationButtons() {
        reminderTimeLabel.textColor = UIColor.gray
        reminderTimeButton.setTitleColor(UIColor.gray, for: .normal)
        reminderTimeButton.isEnabled = false
        reminderTimeArrow.isEnabled = false
    }
    
    private func disableTBTime2() {
        tb1_time_label.text = PDStrings.colonedStrings.time
        tb2_time_stack.isHidden = true
        tb2_time_big.isEnabled = false
        tb2_time_small.isEnabled = false
    }
    
    private func enableTBTime2() {
        // Start TB2 Time = TB1 Time
        PillDataController.setTB2Time(to: PillDataController.getTB1Time())
        tb2_time_big.setTitle(PDDateHelper.format(time: PillDataController.getTB1Time()), for: .normal)
        
        tb1_time_label.text = PDStrings.colonedStrings.first_time
        tb2_time_stack.isHidden = false
        tb2_time_big.isEnabled = true
        tb2_time_small.isEnabled = true
    }
    
    private func disablePGTime2() {
        pg1_time_label.text = PDStrings.colonedStrings.time
        pg2_time_stack.isHidden = true
        pg2_time_big.isEnabled = false
        pg2_time_small.isEnabled = false
    }
    
    private func enablePGTime2() {
        // Reset PG2 Time = PG1 Time
        PillDataController.setPG2Time(to: PillDataController.getPG1Time())
        pg2_time_big.setTitle(PDDateHelper.format(time: PillDataController.getPG1Time()), for: .normal)
        
        pg1_time_label.text = PDStrings.colonedStrings.first_time
        pg2_time_stack.isHidden = false
        pg2_time_big.isEnabled = true
        pg2_time_small.isEnabled = true
    }
    
    private func disableExtraTB() {
        tb1_time_picker_view.isHidden = true
        tb1_time_picker.isHidden = true
        tb2_time_picker.isHidden = true
        tb2_time_picker_view.isHidden = true
        tb_daily_picker.isHidden = true
        tb1_time_big.isSelected = false
        tb_daily_big.isSelected = false
        tb2_time_big.isSelected = false
    }
    
    private func disableExtraPG() {
        pg1_time_picker_view.isHidden = true
        pg2_time_picker_view.isHidden = true
        pg_daily_picker.isHidden = true
        pg1_time_picker.isHidden = true
        pg2_time_picker.isHidden = true
        pg1_time_big.isSelected = false
        pg2_time_big.isSelected = false
        pg_daily_big.isSelected = false
    }
    
    // closeTimePicker(timePicker, timePickerView, timeButton) : Will close the picker.
    private func closeTimePicker(timePicker: UITimePicker, timePickerView: UIView, timeButton: UIButton, remind: Bool) {
        let time: Time = timePicker.date
        timePicker.isHidden = true
        
        timeButton.isSelected = false
        UIView.transition(with: timePickerView, duration: 0.4, options: .transitionCrossDissolve, animations: { timePickerView.isHidden = true
        }) { (void) in
            if let id = timeButton.accessibilityIdentifier {
                // Call datePickerDone - the function the sets the pill data with warning.
                self.datePickerDone(id: id, time: time, timeButton: timeButton, remind: remind)
            }
        }
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
        if except != "r" {
            reminderTimePicker.isHidden = true
            reminderTimeButton.isSelected = false
        }
        if except != "tb" {
            tb_daily_picker.isHidden = true
            tb_daily_big.isSelected = false
        }
        if except != "pg" {
            pg_daily_picker.isHidden = true
            pg_daily_big.isSelected = false
        }
        if except != "t" {
            tb1_time_picker.isHidden = true
            tb1_time_picker_view.isHidden = true
            tb1_time_big.isSelected = false
        }
        if except != "u" {
            tb2_time_picker.isHidden = true
            tb2_time_picker_view.isHidden = true
            tb2_time_big.isSelected = false
        }
        if except != "p" {
            pg1_time_picker.isHidden = true
            pg1_time_picker_view.isHidden = true
            pg1_time_big.isSelected = false
        }
        if except != "q" {
            pg2_time_picker.isHidden = true
            pg2_time_picker_view.isHidden = true
            pg2_time_big.isSelected = false
        }
    }
    
    private func loadCautiously(time1: Time, time2: inout Time, mode: Int) {
        if let t1 = PDDateHelper.getTodayDate(at: time1), let t2 = PDDateHelper.getTodayDate(at: time2), t2 < t1 {
            (mode == 0) ? PillDataController.setTB2Time(to: t1) : PillDataController.setPG2Time(to: t1)
            time2 = t1
        }
    }
}

extension SettingsVC: UIScrollViewDelegate {
    
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return settingsStack
    }
}
