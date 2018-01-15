//
//  SettingsVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/20/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

typealias UITimePicker = UIDatePicker

class SettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Description: This is the view controller for the Settings View.  The Settings View is where the user may select their defaults, which are saved and used during future PatchDay use.  The defaults can alMOEstrogenDeliveryst be broken up into two topics:  the Schedule Outlets and the Notification Outlets.  The Schedule Outlets include the interval that the patches expire, and the number of patches in the schedule.  The Notification Outlets include the Bool for whether the user wants to receive a reminder, and the time before patch expiration when the user wants to receive the reminder.  There is also a Bool for whether the user wishes to use the "Suggest Location Functionality". UserDefaultsController is the object responsible saving and loading the settings that the user chooses here.
    
    // Pickers
    @IBOutlet private weak var expirationIntervalPicker: UIPickerView!
    @IBOutlet private weak var countPicker: UIPickerView!
    @IBOutlet private weak var reminderTimePicker: UIPickerView!
    @IBOutlet fileprivate weak var settingsStack: UIStackView!
    @IBOutlet weak var tb1_time_picker_view: UIView!
    @IBOutlet weak var tb1_time_picker: UIDatePicker!
    @IBOutlet weak var tb2_time_picker_view: UIView!
    @IBOutlet weak var tb2_time_picker: UIDatePicker!
    @IBOutlet weak var pg1_time_picker_view: UIView!
    @IBOutlet weak var pg1_time_picker: UIDatePicker!
    @IBOutlet weak var pg2_time_picker_view: UIView!
    @IBOutlet weak var pg2_time_picker: UIDatePicker!

    // trackers
    private var whichTapped: String?
    private var selectedRow: Int?
    
    // Schedule outlets (in order of appearance
    @IBOutlet private weak var settingsView: UIView!
    @IBOutlet private weak var intervalButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet private weak var countButton: UIButton!
    @IBOutlet private weak var suggestLocationLabel: UILabel!
    @IBOutlet private weak var suggestLocationFunctionality_switched: UISwitch!
    
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
        
        self.countLabel.text = PDStrings.count_label
        
        // set button selected states
        self.intervalButton.setTitle(PDStrings.save, for: .selected)
        self.intervalButton.setTitleColor(UIColor.blue, for: .selected)
        self.countButton.setTitle(PDStrings.save, for: .selected)
        self.countButton.setTitleColor(UIColor.blue, for: .selected)
        self.tb_daily_big.setTitle(PDStrings.save, for: .selected)
        self.tb_daily_big.setTitleColor(UIColor.blue, for: .selected)
        self.tb1_time_big.setTitle(PDStrings.save, for: .selected)
        self.tb1_time_big.setTitleColor(UIColor.blue, for: .selected)
        self.tb2_time_big.setTitle(PDStrings.save, for: .selected)
        self.tb2_time_big.setTitleColor(UIColor.blue, for: .selected)
        self.pg_daily_big.setTitle(PDStrings.save, for: .selected)
        self.pg_daily_big.setTitleColor(UIColor.blue, for: .selected)
        self.pg1_time_big.setTitle(PDStrings.save, for: .selected)
        self.pg1_time_big.setTitleColor(UIColor.blue, for: .selected)
        self.pg2_time_big.setTitle(PDStrings.save, for: .selected)
        self.pg2_time_big.setTitleColor(UIColor.blue, for: .selected)
        self.reminderTimeButton.setTitle(PDStrings.save, for: .selected)
        self.reminderTimeButton.setTitleColor(UIColor.blue, for: .selected)
        
        // set disabled states
        self.tb1_time_big.setTitleColor(UIColor.lightGray, for: .disabled)
        self.tb2_time_big.setTitleColor(UIColor.lightGray, for: .disabled)
        self.tb_daily_big.setTitleColor(UIColor.lightGray, for: .disabled)
        self.pg1_time_big.setTitleColor(UIColor.lightGray, for: .disabled)
        self.pg2_time_big.setTitleColor(UIColor.lightGray, for: .disabled)
        self.pg_daily_big.setTitleColor(UIColor.lightGray, for: .disabled)

        // other
        self.countButton.tag = 10
        self.settingsView.backgroundColor = UIColor.white
        self.delegatePickers()
        
        // load titles
        self.loadReminder_bool()
        self.loadInterval()
        self.loadIncludeTB()
        self.loadTBDaily()
        self.loadTB1Time()
        self.loadTB2Time()
        self.loadTBRemind()
        if PillDataController.getTBDailyInt() == 1 {
            self.disableTBTime2()
        }
        self.loadIncludePG()
        self.loadPGDaily()
        self.loadPG1Time()
        self.loadPG2Time()
        self.loadPGRemind()
        if PillDataController.getPGDailyInt() == 1 {
            self.disablePGTime2()
        }
        self.loadCount()
        self.loadNotificationOption()
        self.loadSuggestLocationFunctionality()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Set animation related Var
        ScheduleController.oldDeliveryCount = UserDefaultsController.getQuantityInt()
    }
      
    // MARK: - Data loaders
    
    private func loadInterval() {
        self.intervalButton.setTitle(UserDefaultsController.getTimeInterval(), for: .normal)
    }
    
    private func loadCount() {
        self.countButton.setTitle(UserDefaultsController.getQuantityString(), for: .normal)
    }
    
    private func loadIncludeTB() {
        self.tb_switch.setOn(PillDataController.includingTB(), animated: false)
    }
    
    private func loadTBDaily() {
        self.tb_daily_big.setTitle(String(PillDataController.getTBDailyString()), for: .normal)
    }
    
    private func loadTB1Time() {
        if PillDataController.includingTB() {
            self.tb1_time_big.setTitle(PillDataController.format(time: PillDataController.getTB1Time()), for: .normal)
        }
        // disable tb buttons
        else {
            self.tb1_time_big.isEnabled = false
            self.tb2_time_big.isEnabled = false
            self.tb1_time_small.isEnabled = false
            self.tb2_time_small.isEnabled = false
            self.tb_daily_big.isEnabled = false
            self.tb_daily_small.isEnabled = false
            self.tb_remind_switch.isEnabled = false
        }
    }
    
    // loads safely - doesn't load improper tb2
    private func loadTB2Time() {
        var tb2 = PillDataController.getTB2Time()
        if PillDataController.includingTB() {
            // if TB2 is improperly smaller than TB1, set it as TB1
            loadCautiously(time1: PillDataController.getTB1Time(), time2: &tb2, mode: 0)
            }
            self.tb2_time_big.setTitle(PillDataController.format(time: tb2), for: .normal)
    }
    
    private func loadTBRemind() {
        self.tb_remind_switch.setOn(PillDataController.getRemindTB(), animated: false)
    }
    
    private func loadIncludePG() {
        self.pg_switch.setOn(PillDataController.includingPG(), animated: false)
    }
    
    private func loadPGDaily() {
        self.pg_daily_big.setTitle(String(PillDataController.getPGDailyString()), for: .normal)
    }
    
    private func loadPG1Time() {
        if PillDataController.includingPG() {
            self.pg1_time_big.setTitle(PillDataController.format(time: PillDataController.getPG1Time()), for: .normal)
        }
        // disable pg buttons
        else {
            self.pg1_time_big.isEnabled = false
            self.pg1_time_small.isEnabled = false
            self.pg2_time_big.isEnabled = false
            self.pg2_time_small.isEnabled = false
            self.pg_daily_big.isEnabled = false
            self.pg_daily_small.isEnabled = false
            self.pg_remind_switch.isEnabled = false
        }
    }
    
    // load safely - doesn't load improper pg2
    private func loadPG2Time() {
        var pg2 = PillDataController.getPG2Time()
        if PillDataController.includingPG() {
            // if PG2 is improperly smaller than PG1, set it as PG1
            loadCautiously(time1: PillDataController.getPG1Time(), time2: &pg2, mode: 0)
        }
        self.pg2_time_big.setTitle(PillDataController.format(time: pg2), for: .normal)
    }
    
    private func loadPGRemind() {
        self.pg_remind_switch.setOn(PillDataController.getRemindPG(), animated: false)
    }
    
    private func loadReminder_bool() {
        self.receiveReminder_switch.setOn(UserDefaultsController.getRemindMeUpon(), animated: false)
    }
    
    private func loadNotificationOption() {
        if self.receiveReminder_switch.isOn {
            self.enableNotificationButtons()
        }
        else {
            self.disableNotificationButtons()
        }
        let title = UserDefaultsController.getNotificationTimeString()
        self.reminderTimeButton.setTitle(title, for: .normal)
    }
    
    private func loadSuggestLocationFunctionality() {
        self.suggestLocationFunctionality_switched.setOn(UserDefaultsController.getSLF(), animated: false)
    }

    // MARK: - Picker Functions
    
    private func delegatePickers() {
        self.expirationIntervalPicker.delegate = self
        self.countPicker.delegate = self
        self.reminderTimePicker.delegate = self
        self.tb_daily_picker.delegate = self
        self.pg_daily_picker.delegate = self
    }
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // NUM OF ROWS...
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0;
        if let context = self.getWhichTapped() {
            switch context {
            case PDStrings.count_key():                                     // COUNT
                numberOfRows = PDStrings.counts.count
                break
            case PDStrings.interval_key():                                  // INTERVAL
                numberOfRows = PDStrings.expirationIntervals.count
                break
            case PDStrings.tb_daily_key(), PDStrings.pg_daily_key():        // TIMESADAY
                numberOfRows = PDStrings.dailyCounts.count
                break
            case PDStrings.notif_key():                                     // NOTIF
                numberOfRows = PDStrings.notificationSettings.count
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
        if let context = self.getWhichTapped() {
            switch context {
            case PDStrings.interval_key():                                  // INTERVAL
                if row < PDStrings.expirationIntervals.count && row >= 0 {
                    title = PDStrings.expirationIntervals[row]
                }
                break
            case PDStrings.count_key():                                     // COUNT
                if row < PDStrings.counts.count && row >= 0 {
                    title = PDStrings.counts[row]
                }
                break
            case PDStrings.tb_daily_key(), PDStrings.pg_daily_key():        // TIMESADAY
                if row < PDStrings.dailyCounts.count && row >= 0 {
                    title = PDStrings.dailyCounts[row]
                }
                break
            case PDStrings.notif_key():                                     // NOTIF
                if row < PDStrings.notificationSettings.count && row >= 0 {
                    title = PDStrings.notificationSettings[row]
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
        self.selectedRow = row
    }
    
    private func openOrClosePicker(key: String) {
        
        // Selector method for openOrClose(picker, buttonTapped, selections)
        // -- loads proper UI elements specific to each picker
        // -- hides everything that is not that picker
        
        // key is either "interval" , "count" , "notifications"
        
        // change member variable for determining correct picker
        self.setWhichTapped(to: key)
        switch key {
        case PDStrings.interval_key():                      // INTERVAL
            self.expirationIntervalPicker.reloadAllComponents()
            self.deselectEverything(except: "i")
            self.openOrClose(picker: self.expirationIntervalPicker, buttonTapped: self.intervalButton, selections: PDStrings.expirationIntervals, key: key)
            break
        case PDStrings.count_key():                         // COUNT
            self.countPicker.reloadAllComponents()
            self.deselectEverything(except: "c")
            self.openOrClose(picker: self.countPicker, buttonTapped: self.countButton, selections: PDStrings.counts, key: key)
            break
        case PDStrings.tb_daily_key():                      // TB TIMESADAY
            self.tb_daily_picker.reloadAllComponents()
            self.deselectEverything(except: "tb")
            self.openOrClose(picker: self.tb_daily_picker, buttonTapped: self.tb_daily_big, selections: PDStrings.dailyCounts, key: key)
            break
        case PDStrings.pg_daily_key():                      // PG TIMESADAY
            self.pg_daily_picker.reloadAllComponents()
            self.deselectEverything(except: "pg")
            self.openOrClose(picker: self.pg_daily_picker, buttonTapped: self.pg_daily_big, selections: PDStrings.dailyCounts, key: key)
            break
        case PDStrings.notif_key():                         // NOTIFICATION TIME BEFORE
            self.reminderTimePicker.reloadAllComponents()
            // close other pickers / deselect
            self.deselectEverything(except: "r")
            self.openOrClose(picker: self.reminderTimePicker, buttonTapped: self.reminderTimeButton, selections: PDStrings.notificationSettings, key: key)
            break
        default:
            print("ERROR: Improper context for loading UIPicker.")
        }
    }
    
    // openOrClose(picker, buttonTapped, selections) : Refers to pickers that are NOT UITimePickers.
    private func openOrClose(picker: UIPickerView, buttonTapped: UIButton, selections: [String], key: String) {
        
        // ******************************
        // WHEN PICKER IS OPEN, CLOSE IT.
        // ******************************
        // In this case, select the button,
        // And for count, set global variable necessary for animation,
        // And close the picker,
        // Then, save newly set User Defaults
        
        if picker.isHidden == false {
            buttonTapped.isSelected = false
            UIView.transition(with: picker as UIView, duration: 0.4, options: .transitionFlipFromTop, animations: { picker.isHidden = true
            }) {
                (void) in
                // Global var necessary for animation (only when using count picker):
                if key == PDStrings.count_key() {
                    ScheduleController.oldDeliveryCount = UserDefaultsController.getQuantityInt()
                }
                else if key == PDStrings.tb_daily_key() {
                    self.tb2_time_big.setTitle(PillDataController.format(time: PillDataController.getTB2Time()), for: .normal)
                }
                else if key == PDStrings.pg_daily_key() {
                    self.pg2_time_big.setTitle(PillDataController.format(time: PillDataController.getPG2Time()), for: .normal)
                }
                self.saveFromPicker(key: key)
            }
            return
        }
        
        // ******************************
        // WHEN PICKER IS CLOSED, OPEN IT.
        // ******************************
        // In this case, open the picker with the correct info,
        // And try to select current row.
        
        buttonTapped.isSelected = true  // select
        // set starting row to current button title label's text
        if let title = buttonTapped.titleLabel, let readText = title.text {

            guard let selectedRowIndex = selections.index(of: readText) else {
                // Selected Row Index = 0
                picker.selectRow(0, inComponent: 0, animated: false)
                UIView.transition(with: picker as UIView, duration: 0.4, options: .transitionFlipFromTop, animations: { picker.isHidden = false
                }, completion: nil)
                return
            }
            // Selected Row Index = current value
            picker.selectRow(selectedRowIndex, inComponent: 0, animated: true)
        }
        // Always animates
        UIView.transition(with: picker as UIView, duration: 0.4, options: .transitionFlipFromTop, animations: { picker.isHidden = false
        }, completion: nil)
    }
    
    // saveFromPicker() : Saves values from pickers (NOT a function for TimePickers though).
    private func saveFromPicker(key: String) {
        /*****************************************
         -- SAVING USER DEFAULTS --
         *****************************************/
        if let row = self.selectedRow {
            switch key {
                
                // COUNT
            case PDStrings.count_key():
                let oldCount = ScheduleController.oldDeliveryCount
                if row < PDStrings.counts.count && row >= 0 {
                    let choice = PDStrings.counts[row]
                    UserDefaultsController.setQuantityWithWarning(to: choice, oldCount: oldCount, countButton: self.countButton)        // save
                    self.countButton.setTitle(choice, for: .normal)
                }
                else {
                    print("Error saving count for index for row " + String(row))
                }
                self.resendScheduleNotifications()
                break
                
                // INTERVAL
            case PDStrings.interval_key():
                if row < PDStrings.expirationIntervals.count && row >= 0 {
                    let choice = PDStrings.expirationIntervals[row]
                    UserDefaultsController.setTimeInterval(to: choice)
                    // configure button title
                    self.intervalButton.setTitle(choice, for: .normal)
                }
                else {
                    print("Error saving expiration interval for row " + String(row))
                }
                self.resendScheduleNotifications()
                break
                
                // TB DAILY
            case PDStrings.tb_daily_key():
                if row < PDStrings.dailyCounts.count && row >= 0, let c = Int(PDStrings.dailyCounts[row]) {
                    PillDataController.setTBDaily(to: c)
                    (c == 1) ? self.disableTBTime2() : self.enableTBTime2()
                    // configure button title
                    self.tb_daily_big.setTitle(String(c), for: .normal)
                    self.disableExtraTB()
                    if PillDataController.getRemindTB() {
                        appDelegate.notificationsController.requestNotifyTakePill(mode: 0)
                    }
                }
                else {
                    print("Error saving TB timesday for row " + String(row))
                }
                break
                
                // PG DAILY
            case PDStrings.pg_daily_key():
                if row < PDStrings.dailyCounts.count && row >= 0, let c = Int(PDStrings.dailyCounts[row]) {
                    PillDataController.setPGDaily(to: c)
                    (c == 1) ? self.disablePGTime2() : self.enablePGTime2()
                    // configure button title
                    self.pg_daily_big.setTitle(String(c), for: .normal)
                    self.disableExtraPG()
                    if PillDataController.getRemindPG() {
                        appDelegate.notificationsController.requestNotifyTakePill(mode: 1)
                    }
                }
                else {
                    print("Error saving PG timesday for row " + String(row))
                }
                break
                
                // NOTIFICATION TIME
            case PDStrings.notif_key():
                if row < PDStrings.notificationSettings.count && row >= 0 {
                    let choice = PDStrings.notificationSettings[row]
                    UserDefaultsController.setNotificationOption(to: choice)
                    // configure button title
                    let title = choice
                    self.reminderTimeButton.setTitle(title, for: .normal)
                }
                else {
                    print("Error saving notification time for row " + String(row))
                }
                self.resendScheduleNotifications()
                break
            default:
                print("ERROR: Improper context when saving details from picker")
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
        
        self.deselectEverything(except: mode)
        timeButton.isSelected = true
    
        switch mode {
        case "t":   // TBLOCK TIME 1 PICKER
            self.tb1_time_picker = timePicker
            self.tb1_time_picker.date = startTime
            self.tb1_time_picker.maximumDate = (timesaday == 2) ? maxOrMin : nil
            break
        case "u":   // TBLOCK TIME 2 PICKER
            self.tb2_time_picker = timePicker
            self.tb2_time_picker.date = startTime
            self.tb2_time_picker.minimumDate = maxOrMin
            break
        case "p":   // PG TIME 1 PICKER
            self.pg1_time_picker = timePicker
            self.pg1_time_picker.date = startTime
            self.pg1_time_picker.maximumDate = (timesaday == 2) ? maxOrMin : nil
            break
        case "q":   // PG TIME 2 PICKER
            self.pg2_time_picker = timePicker
            self.pg2_time_picker.date = startTime
            self.pg2_time_picker.minimumDate = maxOrMin
            break
        default:
            print("ERROR: Improper mode for choosing time picker.")
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
        timeButton.setTitle(PillDataController.format(time: time), for: .normal)
        
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
            print("ERROR: Improper buttonID when closing and saving date picker")
        }
    }

    // MARK: - IBActions Picker loads

    @IBAction private func reminderTimeArrowTapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.notif_key())
    }
    
    @IBAction private func reminderTimeTapped(_ sender: Any) {
       self.openOrClosePicker(key: PDStrings.notif_key())
    }
    
    @IBAction func tb_switched(_ sender: Any) {
        PillDataController.setIncludeTB(to: self.tb_switch.isOn)
        self.disableExtraTB()
        // USER JUST TURNED IT ON
        if self.tb_switch.isOn {
            self.tb1_time_big.setTitle(PillDataController.format(time: PillDataController.getTB1Time()), for: .normal)
            self.tb2_time_big.setTitle(PillDataController.format(time: PillDataController.getTB2Time()), for: .normal)
            self.tb1_time_big.isEnabled = true
            self.tb1_time_small.isEnabled = true
            self.tb_daily_big.isEnabled = true
            self.tb_daily_small.isEnabled = true
            self.tb_remind_switch.isEnabled = true
            if PillDataController.getTBDailyInt() == 2 {
                self.tb2_time_big.isEnabled = true
                self.tb2_time_small.isEnabled = true
            }
            if PillDataController.getRemindTB() {
                appDelegate.notificationsController.requestNotifyTakePill(mode: 0)
            }
        }
        // USER JUST TURNED IT OFF
        else {
            self.tb1_time_big.isEnabled = false
            self.tb1_time_small.isEnabled = false
            self.tb2_time_big.isEnabled = false
            self.tb2_time_small.isEnabled = false
            self.tb_daily_big.isEnabled = false
            self.tb_daily_small.isEnabled = false
            self.tb_remind_switch.isEnabled = false
            PillDataController.setTBDaily(to: 1)
            self.loadTBDaily()
            self.disableTBTime2()
            PillDataController.resetTB()
            appDelegate.notificationsController.cancelPills(identifiers: [PDStrings.pillIDs[0]])
        }
    }
    
    @IBAction func tb_daily_tapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.tb_daily_key())
    }
    
    @IBAction func tb1_tapped(_ sender: Any) {
        (self.tb1_time_picker_view.isHidden == false) ? self.closeTimePicker(timePicker: self.tb1_time_picker, timePickerView: self.tb1_time_picker_view, timeButton: self.tb1_time_big, remind: PillDataController.getRemindTB()) :  self.chooseTime(mode: "t", timeButton: self.tb1_time_big, timePickerView: self.tb1_time_picker_view, timesaday: PillDataController.getTBDailyInt(), startTime: PillDataController.getTB1Time(), maxOrMin: PillDataController.getTB2Time())
    }
    
    @IBAction func tb2_tapped(_ sender: Any) {
        (self.tb2_time_picker_view.isHidden == false) ? self.closeTimePicker(timePicker: self.tb2_time_picker, timePickerView: self.tb2_time_picker_view, timeButton: self.tb2_time_big, remind: PillDataController.getRemindTB()) :  self.chooseTime(mode: "u", timeButton: self.tb2_time_big, timePickerView: self.tb2_time_picker_view, timesaday: PillDataController.getTBDailyInt(), startTime: PillDataController.getTB2Time(), maxOrMin: PillDataController.getTB1Time())
    }
    
    @IBAction func tb_remind_switched(_ sender: Any) {
        let isOn = self.tb_switch.isOn
        if isOn {
            appDelegate.notificationsController.requestNotifyTakePill(mode: 0)
        }
        else {
            appDelegate.notificationsController.cancelPills(identifiers: [PDStrings.pillIDs[0]])
        }
        PillDataController.setRemindTB(to: isOn)
    }
    
    @IBAction func pg_switched(_ sender: Any) {
        PillDataController.setIncludePG(to: self.pg_switch.isOn)
        self.disableExtraPG()
        // USER JUST TURNED IT ON
        if self.pg_switch.isOn {
            self.pg1_time_big.setTitle(PillDataController.format(time: PillDataController.getPG1Time()), for: .normal)
            self.pg2_time_big.setTitle(PillDataController.format(time: PillDataController.getPG2Time()), for: .normal)
            self.pg1_time_big.isEnabled = true
            self.pg1_time_small.isEnabled = true
            self.pg_daily_big.isEnabled = true
            self.pg_daily_small.isEnabled = true
            self.pg_daily_big.isSelected = false
            self.pg_remind_switch.isEnabled = true
            if PillDataController.getPGDailyInt() == 2 {
                self.pg2_time_big.isEnabled = true
                self.pg2_time_small.isEnabled = true
            }
            if PillDataController.getRemindPG() {
                appDelegate.notificationsController.requestNotifyTakePill(mode: 1)
            }
        }
        // USER JUST TURNED IT OFF
        else {
            self.pg1_time_big.isEnabled = false
            self.pg1_time_small.isEnabled = false
            self.pg2_time_big.isEnabled = false
            self.pg2_time_small.isEnabled = false
            self.pg_daily_big.isEnabled = false
            self.pg_daily_small.isEnabled = false
            self.pg_remind_switch.isEnabled = false
            self.disablePGTime2()
            PillDataController.setPGDaily(to: 1)
            self.loadPGDaily()
            PillDataController.resetPG()
            (UIApplication.shared.delegate as! AppDelegate).notificationsController.cancelPills(identifiers: [PDStrings.pillIDs[1]])
            
        }
    }
    
    @IBAction func pg_daily_tapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.pg_daily_key())
    }
    
    @IBAction func pg1_tapped(_ sender: Any) {
        (self.pg1_time_picker_view.isHidden == false) ? self.closeTimePicker(timePicker: self.pg1_time_picker, timePickerView: self.pg1_time_picker_view, timeButton: self.pg1_time_big, remind: PillDataController.getRemindPG()) :  self.chooseTime(mode: "p", timeButton: self.pg1_time_big, timePickerView: self.pg1_time_picker_view, timesaday: PillDataController.getPGDailyInt(), startTime: PillDataController.getPG1Time(), maxOrMin: PillDataController.getPG2Time())
    }
    
    @IBAction func pg2_tapped(_ sender: Any) {
        (self.pg2_time_picker_view.isHidden == false) ? self.closeTimePicker(timePicker: self.pg2_time_picker, timePickerView: self.pg2_time_picker_view, timeButton: self.pg2_time_big, remind: PillDataController.getRemindPG()) :  self.chooseTime(mode: "q", timeButton: self.pg2_time_big, timePickerView: self.pg2_time_picker_view, timesaday: PillDataController.getPGDailyInt(), startTime: PillDataController.getPG2Time(), maxOrMin: PillDataController.getPG1Time())
    }
    
    @IBAction func pg_remind_switched(_ sender: Any) {
        let isOn = self.pg_switch.isOn
        if isOn {
            appDelegate.notificationsController.requestNotifyTakePill(mode: 1)
        }
        else {
            appDelegate.notificationsController.cancelPills(identifiers: [PDStrings.pillIDs[1]])
        }
        PillDataController.setRemindPG(to: isOn)
    }
    
    @IBAction private func intervalButtonArrowButtonTapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.interval_key())
    }
    
    @IBAction private func numberOfPatchesArrowButtonTapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.count_key())
    }
    
    @IBAction private func intervalButtonTapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.interval_key())
    }
    
    @IBAction private func countButtonTapped(_ sender: Any) {
        // change member variable for determining correct picker
        self.openOrClosePicker(key: PDStrings.count_key())
    }
    
    // MARK: - IBActions switches
    
    @IBAction func receiveReminder_switched(_ sender: Any) {
        let shouldReceive = self.receiveReminder_switch.isOn
        // fix buttons
        if shouldReceive {
            self.enableNotificationButtons()
        }
        else {
            self.disableNotificationButtons()
        }
        UserDefaultsController.setRemindMeUpon(to: shouldReceive)       // save
    }
    
    @IBAction private func suggestLocationFunctionality_switched(_ sender: Any) {
        let state = self.suggestLocationFunctionality_switched.isOn
        PDAlertController.alertSLF(changingTo: state)
    }
    
    // MARK: - set-and-getters
    
    private func setWhichTapped(to: String?) {
        self.whichTapped = to
    }
    
    private func getWhichTapped() -> String? {
        return self.whichTapped
    }
    
    private func getBackgroundColor() -> UIColor {
        if let color = settingsView.backgroundColor {
            return color
        }
        return UIColor.white
    }
    
    internal func requestScheduleNotifications(forIndex: Int) {
        // request notification iff exists Patch.date
        if let _ = ScheduleController.coreData.getMO(forIndex: forIndex) {
            appDelegate.notificationsController.requestNotifyExpired(scheduleIndex: forIndex)
        }
    }
    
    // MARK: - private
    
    private func resendScheduleNotifications() {
        let last_i = UserDefaultsController.getQuantityInt() - 1
        for i in 0...last_i {
            self.requestScheduleNotifications(forIndex: i)
        }
        var dead_i = last_i + 1
        while dead_i < 3 {
            appDelegate.notificationsController.cancelSchedule(index: last_i)
            dead_i += 1
        }
    }
    
    // MARK: - View loading and altering
    
    private func enableNotificationButtons() {
        self.reminderTimeButton.setTitleColor(UIColor.blue, for: .normal)
        self.reminderTimeLabel.textColor = UIColor.black
        self.reminderTimeButton.isEnabled = true
        self.reminderTimeArrow.isEnabled = true
    }
    
    private func disableNotificationButtons() {
        self.reminderTimeLabel.textColor = UIColor.gray
        self.reminderTimeButton.setTitleColor(UIColor.gray, for: .normal)
        self.reminderTimeButton.isEnabled = false
        self.reminderTimeArrow.isEnabled = false
    }
    
    private func disableTBTime2() {
        self.tb1_time_label.text = PDStrings.time
        self.tb2_time_stack.isHidden = true
        self.tb2_time_big.isEnabled = false
        self.tb2_time_small.isEnabled = false
    }
    
    private func enableTBTime2() {
        // Start TB2 Time = TB1 Time
        PillDataController.setTB2Time(to: PillDataController.getTB1Time())
        self.tb2_time_big.setTitle(PillDataController.format(time: PillDataController.getTB1Time()), for: .normal)
        
        self.tb1_time_label.text = PDStrings.first_time
        self.tb2_time_stack.isHidden = false
        self.tb2_time_big.isEnabled = true
        self.tb2_time_small.isEnabled = true
    }
    
    private func disablePGTime2() {
        self.pg1_time_label.text = PDStrings.time
        self.pg2_time_stack.isHidden = true
        self.pg2_time_big.isEnabled = false
        self.pg2_time_small.isEnabled = false
    }
    
    private func enablePGTime2() {
        // Reset PG2 Time = PG1 Time
        PillDataController.setPG2Time(to: PillDataController.getPG1Time())
        self.pg2_time_big.setTitle(PillDataController.format(time: PillDataController.getPG1Time()), for: .normal)
        
        self.pg1_time_label.text = PDStrings.first_time
        self.pg2_time_stack.isHidden = false
        self.pg2_time_big.isEnabled = true
        self.pg2_time_small.isEnabled = true
    }
    
    private func disableExtraTB() {
        self.tb1_time_picker_view.isHidden = true
        self.tb1_time_picker.isHidden = true
        self.tb2_time_picker.isHidden = true
        self.tb2_time_picker_view.isHidden = true
        self.tb_daily_picker.isHidden = true
        self.tb1_time_big.isSelected = false
        self.tb_daily_big.isSelected = false
        self.tb2_time_big.isSelected = false
    }
    
    private func disableExtraPG() {
        self.pg1_time_picker_view.isHidden = true
        self.pg2_time_picker_view.isHidden = true
        self.pg_daily_picker.isHidden = true
        self.pg1_time_picker.isHidden = true
        self.pg2_time_picker.isHidden = true
        self.pg1_time_big.isSelected = false
        self.pg2_time_big.isSelected = false
        self.pg_daily_big.isSelected = false
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
        if except != "i" {
            self.expirationIntervalPicker.isHidden = true
            self.intervalButton.isSelected = false
        }
        if except != "c" {
            self.countPicker.isHidden = true
            self.countButton.isSelected = false
        }
        if except != "r" {
            self.reminderTimePicker.isHidden = true
            self.reminderTimeButton.isSelected = false
        }
        if except != "tb" {
            self.tb_daily_picker.isHidden = true
            self.tb_daily_big.isSelected = false
        }
        if except != "pg" {
            self.pg_daily_picker.isHidden = true
            self.pg_daily_big.isSelected = false
        }
        if except != "t" {
            self.tb1_time_picker.isHidden = true
            self.tb1_time_picker_view.isHidden = true
            self.tb1_time_big.isSelected = false
        }
        if except != "u" {
            self.tb2_time_picker.isHidden = true
            self.tb2_time_picker_view.isHidden = true
            self.tb2_time_big.isSelected = false
        }
        if except != "p" {
            self.pg1_time_picker.isHidden = true
            self.pg1_time_picker_view.isHidden = true
            self.pg1_time_big.isSelected = false
        }
        if except != "q" {
            self.pg2_time_picker.isHidden = true
            self.pg2_time_picker_view.isHidden = true
            self.pg2_time_big.isSelected = false
        }
    }
    
    private func loadCautiously(time1: Time, time2: inout Time, mode: Int) {
        if let t1 = PillDataController.getTodayDate(at: time1), let t2 = PillDataController.getTodayDate(at: time2), t2 < t1 {
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
