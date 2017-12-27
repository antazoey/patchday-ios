//
//  SettingsVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/20/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Description: This is the view controller for the Settings View.  The Settings View is where the user may select their defaults, which are saved and used during future PatchDay use.  The defaults can alMOEstrogenDeliveryst be broken up into two topics:  the Schedule Outlets and the Notification Outlets.  The Schedule Outlets include the interval that the patches expire, and the number of patches in the schedule.  The Notification Outlets include the Bool for whether the user wants to receive a reminder, and the time before patch expiration when the user wants to receive the reminder.  There is also a Bool for whether the user wishes to use the "Suggest Location Functionality". SettingsDefaultsController is the object responsible saving and loading the settings that the user chooses here.
    
    // Pickers
    @IBOutlet private weak var expirationIntervalPicker: UIPickerView!
    @IBOutlet private weak var numberOfPatchesPicker: UIPickerView!
    @IBOutlet private weak var reminderTimePicker: UIPickerView!
    @IBOutlet private weak var settingsView: UIView!
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
    private var numberOfPatchesWhenEnteredScene: Int?
    private var weAreHidingFromPicker: Bool = false
    
    // Schedule outlets (in order of appearance
    @IBOutlet private weak var changePatchEvery: UIButton!
    @IBOutlet private weak var numberOfPatches: UIButton!
    @IBOutlet private weak var suggestLocationLabel: UILabel!
    @IBOutlet private weak var suggestLocationFunctionalitySwitch: UISwitch!
    @IBOutlet private weak var lineUnderAutoSuggest: UIView!
    
    // Pill outlets (in order of appearance)
    @IBOutlet weak var tb_stack: UIStackView!
    @IBOutlet weak var tb_timesaday_big: UIButton!
    @IBOutlet weak var tb_timesaday_small: UIButton!
    @IBOutlet weak var tb_timesaday_picker: UIPickerView!
    @IBOutlet weak var tb_switch: UISwitch!
    @IBOutlet weak var tb1_time_big: UIButton!
    @IBOutlet weak var tb1_time_label: UILabel!
    @IBOutlet weak var tb1_time_small: UIButton!
    @IBOutlet weak var tb2_time_stack: UIStackView!
    @IBOutlet weak var tb2_time_big: UIButton!
    @IBOutlet weak var tb2_time_small: UIButton!
    @IBOutlet weak var pg_stack: UIStackView!
    @IBOutlet weak var pg_timesaday_big: UIButton!
    @IBOutlet weak var pg_timesaday_small: UIButton!
    @IBOutlet weak var pg_timesaday_picker: UIPickerView!
    @IBOutlet weak var pg_switch: UISwitch!
    @IBOutlet weak var pg1_time_label: UILabel!
    @IBOutlet weak var pg1_time_big: UIButton!
    @IBOutlet weak var pg1_time_small: UIButton!
    @IBOutlet weak var pg2_time_stack: UIStackView!
    @IBOutlet weak var pg2_time_big: UIButton!
    @IBOutlet weak var pg2_time_small: UIButton!
    
    // Notification outlets (in order of appearance)
    @IBOutlet private weak var notificationHeading: UILabel!
    @IBOutlet private weak var lineUnderNotificationHeading: UIView!
    @IBOutlet private weak var reminderExplanation: UILabel!
    @IBOutlet private weak var lineUnderReminderExplanation: UIView!
    @IBOutlet private weak var receiveReminderLabel: UILabel!
    @IBOutlet weak var receiveReminderUpon: UISwitch!
    @IBOutlet private weak var receiveReminderBefore: UISwitch!
    @IBOutlet private weak var lineUnderReceiveReminderSwitch: UIView!
    @IBOutlet private weak var minutesBeforeLabel: UILabel!
    @IBOutlet private weak var notificationOption: UIButton!
    @IBOutlet private weak var notificationArrow: UIButton!
    @IBOutlet private weak var lineUnderNotificationOption: UIView!
    @IBOutlet private weak var changePatchFunctionExplanation: UILabel!
    @IBOutlet private weak var lineUnderPatchFunctionExplanation: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // set button selected states
        self.changePatchEvery.setTitle(PDStrings.save, for: .selected)
        self.changePatchEvery.setTitleColor(UIColor.blue, for: .selected)
        self.numberOfPatches.setTitle(PDStrings.save, for: .selected)
        self.numberOfPatches.setTitleColor(UIColor.blue, for: .selected)
        self.tb_timesaday_big.setTitle(PDStrings.save, for: .selected)
        self.tb_timesaday_big.setTitleColor(UIColor.blue, for: .selected)
        self.tb1_time_big.setTitle(PDStrings.save, for: .selected)
        self.tb1_time_big.setTitleColor(UIColor.blue, for: .selected)
        self.tb2_time_big.setTitle(PDStrings.save, for: .selected)
        self.tb2_time_big.setTitleColor(UIColor.blue, for: .selected)
        self.pg_timesaday_big.setTitle(PDStrings.save, for: .selected)
        self.pg_timesaday_big.setTitleColor(UIColor.blue, for: .selected)
        self.pg1_time_big.setTitle(PDStrings.save, for: .selected)
        self.pg1_time_big.setTitleColor(UIColor.blue, for: .selected)
        self.pg2_time_big.setTitle(PDStrings.save, for: .selected)
        self.pg2_time_big.setTitleColor(UIColor.blue, for: .selected)
        self.notificationOption.setTitle(PDStrings.save, for: .selected)
        self.notificationOption.setTitleColor(UIColor.blue, for: .selected)
        
        // set disabled states
        self.tb1_time_big.setTitleColor(UIColor.lightGray, for: .disabled)
        self.tb2_time_big.setTitleColor(UIColor.lightGray, for: .disabled)
        self.tb_timesaday_big.setTitleColor(UIColor.lightGray, for: .disabled)
        self.pg1_time_big.setTitleColor(UIColor.lightGray, for: .disabled)
        self.pg2_time_big.setTitleColor(UIColor.lightGray, for: .disabled)
        self.pg_timesaday_big.setTitleColor(UIColor.lightGray, for: .disabled)

        // other
        PDAlertController.currentVC = self
        self.setNumberOfPatchesWhenEnteredScene()
        self.numberOfPatches.tag = 10
        self.settingsView.backgroundColor = UIColor.white
        self.loadSwipe()
        self.delegatePickers()
        
        // load titles
        self.loadRemindMeUpon()
        self.loadRemindMeBefore()
        self.loadChangePatchEvery()
        self.loadIncludeTB()
        self.loadTBtimesaday()
        self.loadTBTime()
        self.loadTBTime2()
        if SettingsDefaultsController.getTBtimesadayInt() == 1 {
            self.disableTBTime2()
        }
        self.loadIncludePG()
        self.loadPGtimesaday()
        self.loadPGTime()
        self.loadPGTime_2()
        if SettingsDefaultsController.getPGtimesadayInt() == 1 {
            self.disablePGTime2()
        }
        self.loadNumberOfPatches()
        self.loadNotificationOption()
        self.loadSuggestLocationFunctionality()
        
        // labels
        self.receiveReminderLabel.text = PDStrings.expiresSoon
        self.minutesBeforeLabel.text = PDStrings.timeBeforeExp
    }
    
    internal func setNumberOfPatchesWhenEnteredScene() {
        self.numberOfPatchesWhenEnteredScene = SettingsDefaultsController.getQuantityInt()
    }
      
    // MARK: - Data loaders
    
    private func loadChangePatchEvery() {
        self.changePatchEvery.setTitle(SettingsDefaultsController.getTimeInterval(), for: .normal)
    }
    
    private func loadNumberOfPatches() {
        self.numberOfPatches.setTitle(SettingsDefaultsController.getQuantityString(), for: .normal)
    }
    
    private func loadIncludeTB() {
        self.tb_switch.setOn(SettingsDefaultsController.getIncludeTB(), animated: false)
    }
    
    private func loadTBtimesaday() {
        self.tb_timesaday_big.setTitle(String(SettingsDefaultsController.getTBtimesadayString()), for: .normal)
    }
    
    private func loadTBTime() {
        self.tb1_time_big.setTitle(SettingsDefaultsController.formatTime(time: SettingsDefaultsController.getTB1Time()), for: .normal)
        // if not including TBlock...
        if SettingsDefaultsController.getIncludeTB() == false {
            self.tb1_time_big.isEnabled = false
            self.tb2_time_big.isEnabled = false
            self.tb1_time_small.isEnabled = false
            self.tb2_time_small.isEnabled = false
            self.tb_timesaday_big.isEnabled = false
            self.tb_timesaday_small.isEnabled = false
        }
    }
    
    private func loadTBTime2() {
        self.tb2_time_big.setTitle(SettingsDefaultsController.formatTime(time: SettingsDefaultsController.getTB2Time()), for: .normal)
    }
    
    private func loadIncludePG() {
        self.pg_switch.setOn(SettingsDefaultsController.getIncludePG(), animated: false)
    }
    
    private func loadPGTime() {
        self.pg1_time_big.setTitle(SettingsDefaultsController.formatTime(time: SettingsDefaultsController.getPG1Time()), for: .normal)
        if SettingsDefaultsController.getIncludePG() == false {
            self.pg1_time_big.isEnabled = false
            self.pg1_time_small.isEnabled = false
            self.pg2_time_big.isEnabled = false
            self.pg2_time_small.isEnabled = false
            self.pg_timesaday_big.isEnabled = false
            self.pg_timesaday_small.isEnabled = false
        }
    }
    
    private func loadPGtimesaday() {
        self.pg_timesaday_big.setTitle(String(SettingsDefaultsController.getPGtimesadayString()), for: .normal)
    }
    
    private func loadPGTime_2() {
        self.pg1_time_big.setTitle(SettingsDefaultsController.formatTime(time: SettingsDefaultsController.getPG2Time()), for: .normal)
    }
    
    private func loadNotificationOption() {
        if self.receiveReminderBefore.isOn {
            self.enableNotificationButtons()
        }
        else {
            self.disableNotificationButtons()
        }
        let title = SettingsDefaultsController.getNotificationTimeString()
        self.notificationOption.setTitle(title, for: .normal)
    }
    
    private func loadSuggestLocationFunctionality() {
        self.suggestLocationFunctionalitySwitch.setOn(SettingsDefaultsController.getSLF(), animated: false)
    }
    
    private func loadRemindMeUpon() {
        self.receiveReminderUpon.setOn(SettingsDefaultsController.getRemindMeUpon(), animated: false)
    }
    
    private func loadRemindMeBefore() {
        self.receiveReminderBefore.setOn(SettingsDefaultsController.getRemindMeBefore(), animated: false)
    }
    
    // MARK: - Picker Functions
    
    private func delegatePickers() {
        self.expirationIntervalPicker.delegate = self
        self.numberOfPatchesPicker.delegate = self
        self.reminderTimePicker.delegate = self
        self.tb_timesaday_picker.delegate = self
        self.pg_timesaday_picker.delegate = self
    }
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // NUM OF ROWS...
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let context = self.getWhichTapped()
        var numberOfRows = 0;
        // for change patch every tapped:
        if context == PDStrings.interval_key() {
            numberOfRows = PDStrings.expirationIntervals.count
        }
        else if context == PDStrings.pg_timesaday_key() || self.getWhichTapped() == PDStrings.tb_timesaday_key() {
            numberOfRows = PDStrings.timesadayCounts.count
        }
        // for number of patches tapped:
        else if context == PDStrings.count_key() {
            numberOfRows = PDStrings.patchCounts.count
        }
        // for notification options tapped
        else if context == PDStrings.notif_key() {
            numberOfRows = PDStrings.notificationSettings.count
        }
        return numberOfRows
        
    }
    
    // ROW TITLES...
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let context = self.getWhichTapped()
        var title = " "
        // for change patch every tapped:
        if context == PDStrings.interval_key() {
            if row < PDStrings.expirationIntervals.count && row >= 0 {
                title = PDStrings.expirationIntervals[row]
            }
        }
        // for number of patches tapped:
        else if context == PDStrings.count_key() {
            if row < PDStrings.patchCounts.count && row >= 0 {
                title = PDStrings.patchCounts[row]
            }
        }
        // for tblock timesaday:
        else if context == PDStrings.tb_timesaday_key() || context == PDStrings.pg_timesaday_key() {
            if row < PDStrings.timesadayCounts.count && row >= 0 {
                title = PDStrings.timesadayCounts[row]
            }
        }
        // for notification options tapped
        else if context == PDStrings.notif_key()  {
            if row < PDStrings.notificationSettings.count && row >= 0 {
                title = PDStrings.notificationSettings[row]
            }
        }
        return title
        
    }
    
    // while picker changes
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedRow = row
    }
    
    private func openOrClosePicker(key: String) {
        
        // initial selector method for the pickers
        // for hiding or unhiding the correct picker
        
        // key is either "interval" , "count" , "notifications"
        
        // change member variable for determining correct picker
        self.setWhichTapped(to: key)
        let context = self.getWhichTapped()
        
        // INTERVAL
        if context == PDStrings.interval_key() {
            self.expirationIntervalPicker.reloadAllComponents()
            // if any other pickers are open, then close them
            if self.numberOfPatchesPicker.isHidden == false {       // numberOfPatches open
                self.numberOfPatchesPicker.isHidden = true
            }
            if self.reminderTimePicker.isHidden == false {          // notifications open
                self.reminderTimePicker.isHidden = true
            }
            self.openOrClose(picker: self.expirationIntervalPicker, buttonTapped: self.changePatchEvery, settingsList: PDStrings.expirationIntervals)
            
        }
            
        // COUNT
        else if context == PDStrings.count_key() {
            self.numberOfPatchesPicker.reloadAllComponents()
            // if any other pickers are open, then close them
            if self.expirationIntervalPicker.isHidden == false {
                self.expirationIntervalPicker.isHidden = true
            }
            if self.reminderTimePicker.isHidden == false {
                self.reminderTimePicker.isHidden = true
            }
            self.numberOfPatches.setTitle(PDStrings.save, for: .selected)
            self.numberOfPatches.setTitleColor(UIColor.blue, for: .selected)
            
            self.openOrClose(picker: self.numberOfPatchesPicker, buttonTapped: self.numberOfPatches, settingsList: PDStrings.patchCounts)

        }
            
        // TB TIMESADAY
        else if context == PDStrings.tb_timesaday_key() {
            self.openOrClose(picker: self.tb_timesaday_picker, buttonTapped: self.tb_timesaday_big, settingsList: PDStrings.timesadayCounts)
        }
        
        // PG TIMESADAY
        else if context == PDStrings.pg_timesaday_key() {
            self.openOrClose(picker: self.pg_timesaday_picker, buttonTapped: self.pg_timesaday_big, settingsList: PDStrings.timesadayCounts)
        }
            
        // NOTIFICATIONS
        else if context == PDStrings.notif_key() {
            self.reminderTimePicker.reloadAllComponents()
            // if any other pickers are open, then close them
            if self.expirationIntervalPicker.isHidden == false {
                self.expirationIntervalPicker.isHidden = true
            }
            if self.numberOfPatchesPicker.isHidden == false {
                self.numberOfPatchesPicker.isHidden = true
            }
            self.openOrClose(picker: self.reminderTimePicker, buttonTapped: self.notificationOption, settingsList: PDStrings.notificationSettings)
        }
        
    }
    
    private func openOrClose(picker: UIPickerView, buttonTapped: UIButton, settingsList: [String]) {
        
        // second openOrClose method for closing pickers and sets the title to the current picker's row
        let context = self.getWhichTapped()
        
        // OPEN PICKER
        
        if picker.isHidden == false {
            buttonTapped.isSelected = false     // deselect
            picker.isHidden = true              // close
            
            // Saving...
            if let row = self.selectedRow {
                
                // save COUNT
                if context == PDStrings.count_key() {
                    guard let oldCount = self.numberOfPatchesWhenEnteredScene else {
                        let choice = PDStrings.patchCounts[row]
                        SettingsDefaultsController.setQuantityWithWarning(to: choice,    oldCount: 0, countButton: self.numberOfPatches)        // save
                        self.numberOfPatches.setTitle(choice, for: .normal)
                        return
                    }
                    SettingsDefaultsController.setQuantityWithWarning(to: PDStrings.patchCounts[row], oldCount: oldCount, countButton: self.numberOfPatches)
                    // configure button title
                    self.numberOfPatches.setTitle(PDStrings.patchCounts[row], for: .normal)
                }
                // save INTERVAL
                else if context == PDStrings.interval_key() {
                    let choice = PDStrings.expirationIntervals[row]
                    SettingsDefaultsController.setTimeInterval(to: choice)
                    // configure button title
                    self.changePatchEvery.setTitle(choice, for: .normal)
                }
                // save TB TIMESADAY
                else if context == PDStrings.tb_timesaday_key() {
                    if let c = Int(PDStrings.timesadayCounts[row]) {
                        SettingsDefaultsController.setTBtimesaday(to: c)
                        if c == 1 {
                            self.disableTBTime2()
                        }
                        else if c == 2 {
                            self.enableTBTime2()
                        }
                        // configure button title
                        self.tb_timesaday_big.setTitle(String(c), for: .normal)
                        self.disableExtraTB()
                    }
                }
                // save PG TIMESDAY
                else if context == PDStrings.pg_timesaday_key() {
                    if let c = Int(PDStrings.timesadayCounts[row]) {
                        SettingsDefaultsController.setPGtimesaday(to: c)
                        if c == 1 {
                            self.disablePGTime2()
                        }
                        else if c == 2 {
                            self.enablePGTime2()
                        }
                        // configure button title
                        self.pg_timesaday_big.setTitle(String(c), for: .normal)
                        self.disableExtraPG()

                    }
                }
                // save NOTIFICATIONS
                else if context == PDStrings.notif_key() {
                    let choice = PDStrings.notificationSettings[row]
                    SettingsDefaultsController.setNotificationOption(to: choice)
                    // configure button title
                    let title = choice
                    self.notificationOption.setTitle(title, for: .normal)
                }
            }
            // resets all the notifications
            if context != PDStrings.tb_timesaday_key() && context != PDStrings.pg_timesaday_key() {
                let last_i = SettingsDefaultsController.getQuantityInt() - 1
                for i in 0...last_i {
                    self.requestNotifications(scheduleIndex: i)
                }
            }
            return
        }
        
        // UNOPEN PICKER
        
        buttonTapped.isSelected = true  // select
        // set starting row to current button title label's text
        if let title = buttonTapped.titleLabel, let readText = title.text {
            picker.reloadAllComponents()
            guard let selectedRowIndex = settingsList.index(of: readText) else {
                picker.selectRow(0, inComponent: 0, animated: false)
                picker.isHidden = false
                return
            }
            picker.selectRow(selectedRowIndex, inComponent: 0, animated: true)
        }
        picker.isHidden = false
    }
    
    // MARK: - Date Picker funcs
    
    func chooseTime(MOEstrogenDeliveryde: Character) {
        
        // create picker view
        let timePickerPoint = CGPoint(x: 0, y: 40)
        let timePickerSize = CGSize(width: 0, height: 0)
        let timePickerRect = CGRect(origin: timePickerPoint, size: timePickerSize)
        let timePicker: UIDatePicker = UIDatePicker(frame: timePickerRect)
        timePicker.datePickerMode = UIDatePickerMode.time
    
        // for testosterone-blocker picker 1
        if MOEstrogenDeliveryde == "t" {
            self.tb1_time_big.isSelected = true
            self.tb1_time_picker_view.isHidden = false
            self.tb1_time_picker_view.addSubview(timePicker)
            self.tb1_time_picker = timePicker
            self.tb1_time_picker.isHidden = false
        }
            
        // for testosterone-blocker picker 2
        else if MOEstrogenDeliveryde == "u" {
            self.tb2_time_big.isSelected = true
            self.tb2_time_picker_view.isHidden = false
            self.tb2_time_picker_view.addSubview(timePicker)
            self.tb2_time_picker = timePicker
            self.tb2_time_picker.isHidden = false
        }
        
        // for progesterone picker 1
        else if MOEstrogenDeliveryde == "p" {
            self.pg1_time_big.isSelected = true
            self.pg1_time_picker_view.isHidden = false
            self.pg1_time_picker_view.addSubview(timePicker)
            self.pg1_time_picker = timePicker
            self.pg1_time_picker.isHidden = false
        }
        
        // for progesterone picker 2
        else if MOEstrogenDeliveryde == "q" {
            self.pg2_time_big.isSelected = true
            self.pg2_time_picker_view.isHidden = false
            self.pg2_time_picker_view.addSubview(timePicker)
            self.pg2_time_picker = timePicker
            self.pg2_time_picker.isHidden = false
        }
        
    }
    
    internal func datePickerDone(sender: UIButton) {
        var time: Date
        if let buttonID = sender.accessibilityIdentifier {
            if buttonID == "bigT" || buttonID == "lilT" {
                self.tb1_time_big.isSelected = false
                time = self.tb1_time_picker.date
                SettingsDefaultsController.setTB1Time(to: time)
                self.tb1_time_big.setTitle(SettingsDefaultsController.formatTime(time: time), for: .normal)
            }
            else if buttonID == "bigT2" || buttonID == "lilT2" {
                self.tb2_time_big.isSelected = false
                time = self.tb2_time_picker.date
                SettingsDefaultsController.setTB2time(to: time)
                self.tb2_time_big.setTitle(SettingsDefaultsController.formatTime(time: time), for: .normal)
            }
            else if buttonID == "bigP" || buttonID == "lilP" {
                self.pg1_time_big.isSelected = false
                time = self.pg1_time_picker.date
                SettingsDefaultsController.setPG1Time(to: time)
                self.pg1_time_big.setTitle(SettingsDefaultsController.formatTime(time: time), for: .normal)
            }
            else {
                self.pg2_time_big.isSelected = false
                time = self.pg2_time_picker.date
                SettingsDefaultsController.setPG2time(to: time)
                self.pg2_time_big.setTitle(SettingsDefaultsController.formatTime(time: time), for: .normal)
            }
        }
    }

    // MARK: - IBActions Picker loads

    @IBAction private func notificationOptionArrowTapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.notif_key())
    }
    
    @IBAction private func notificationOptionTapped(_ sender: Any) {
       self.openOrClosePicker(key: PDStrings.notif_key())
    }
    
    @IBAction func tb_switched(_ sender: Any) {
        SettingsDefaultsController.setIncludeTB(to: self.tb_switch.isOn)
        self.disableExtraTB()
        if self.tb_switch.isOn {
            self.tb1_time_big.isEnabled = true
            self.tb1_time_small.isEnabled = true
            self.tb_timesaday_big.isEnabled = true
            self.tb_timesaday_small.isEnabled = true
            if SettingsDefaultsController.getTBtimesadayInt() == 2 {
                self.tb2_time_big.isEnabled = true
                self.tb2_time_small.isEnabled = true
            }
        }
        else {
            self.tb1_time_big.isEnabled = false
            self.tb1_time_small.isEnabled = false
            self.tb2_time_big.isEnabled = false
            self.tb2_time_small.isEnabled = false
            self.tb_timesaday_big.isEnabled = false
            self.tb_timesaday_small.isEnabled = false
        }
    }
    
    @IBAction func tb1_tapped(_ sender: Any) {
        if self.tb1_time_picker_view.isHidden == false {
            self.tb1_time_picker.isHidden = true
            self.tb1_time_picker_view.isHidden = true         // close if already open
            if let button = sender as? UIButton {
                datePickerDone(sender: button)
            }
            datePickerDone(sender: sender as! UIButton)
        }
        else { self.chooseTime(MOEstrogenDeliveryde: "t") }
    }
    
    @IBAction func tb2_tapped(_ sender: Any) {
        if self.tb2_time_picker_view.isHidden == false {
            self.tb2_time_picker.isHidden = true
            self.tb2_time_picker_view.isHidden = true
            if let button = sender as? UIButton {
                datePickerDone(sender: button)
            }
        }
        else { self.chooseTime(MOEstrogenDeliveryde: "u") }
    }
    
    @IBAction func pg_switched(_ sender: Any) {
        SettingsDefaultsController.setIncludePG(to: self.pg_switch.isOn)
        self.disableExtraPG()
        if self.pg_switch.isOn {
            self.pg1_time_big.isEnabled = true
            self.pg1_time_small.isEnabled = true
            self.pg_timesaday_big.isEnabled = true
            self.pg_timesaday_small.isEnabled = true
            self.pg_timesaday_big.isSelected = false
            if SettingsDefaultsController.getPGtimesadayInt() == 2 {
                self.pg2_time_big.isEnabled = true
                self.pg2_time_small.isEnabled = true
            }
        }
        else {
            self.pg1_time_big.isEnabled = false
            self.pg1_time_small.isEnabled = false
            self.pg2_time_big.isEnabled = false
            self.pg2_time_small.isEnabled = false
            self.pg_timesaday_big.isEnabled = false
            self.pg_timesaday_small.isEnabled = false
        }
    }
    
    @IBAction func pg1_tapped(_ sender: Any) {
        if self.pg1_time_picker_view.isHidden == false {
            self.pg1_time_picker.isHidden = true
            self.pg1_time_picker_view.isHidden = true            // close if already open
            if let button = sender as? UIButton {
                datePickerDone(sender: button)
            }
        }
        else { self.chooseTime(MOEstrogenDeliveryde: "p") }
    }
    
    
    @IBAction func pg2_tapped(_ sender: Any) {
        if self.pg2_time_picker_view.isHidden == false {
            self.pg2_time_picker.isHidden = true
            self.pg2_time_picker_view.isHidden = true
            if let button = sender as? UIButton {
                datePickerDone(sender: button)
            }
        }
        else { self.chooseTime(MOEstrogenDeliveryde: "q") }
    }
    
    
    @IBAction private func changePatchEveryArrowButtonTapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.interval_key())
    }
    
    @IBAction private func numberOfPatchesArrowButtonTapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.count_key())
    }
    
    @IBAction private func changePatchEveryTapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.interval_key())
    }
    
    @IBAction func tb_timesaday_tapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.tb_timesaday_key())
    }
    
    
    
    @IBAction func pg_timesaday_tapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.pg_timesaday_key())
    }
    
    @IBAction private func numberOfPatchesTapped(_ sender: Any) {
        // change member variable for determining correct picker
        self.openOrClosePicker(key: PDStrings.count_key())
        
    }
    
    // MARK: - IBActions switches
    
    @IBAction func receiveReminderUponSwitched(_ sender: Any) {
        SettingsDefaultsController.setRemindMeUpon(to: self.receiveReminderUpon.isOn)
    }
    
    @IBAction private func receiveReminderBeforeSwitched(_ sender: Any) {
        let isOn = self.receiveReminderBefore.isOn
        if isOn {
            self.enableNotificationButtons()
        }
        else {
            self.disableNotificationButtons()
        }
        SettingsDefaultsController.setRemindMeBefore(to: isOn)
    }
    
    @IBAction private func suggestLocationFunctionalitySwitch(_ sender: Any) {
        let state = self.suggestLocationFunctionalitySwitch.isOn
        PDAlertController.alertSLF(changingTo: state)
    }
    
    // MARK: - segues
    
    // to Patch Schedule - this is needed for the swipe, see viewDidLoad()
    @objc private func showPatchScheduleView() {
        self.performSegue(withIdentifier: PDStrings.settingsToScheduleID, sender: self)
    }
    
    // MARK: - view loading and altering
    
    private func enableNotificationButtons() {
        self.notificationOption.setTitleColor(UIColor.blue, for: .normal)
        self.minutesBeforeLabel.textColor = UIColor.black
        self.notificationOption.isEnabled = true
        self.notificationArrow.isEnabled = true
    }
    
    private func disableNotificationButtons() {
        self.minutesBeforeLabel.textColor = UIColor.gray
        self.notificationOption.setTitleColor(UIColor.gray, for: .normal)
        self.notificationOption.isEnabled = false
        self.notificationArrow.isEnabled = false
    }
    
    private func loadSwipe() {
        let swipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.showPatchScheduleView))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    private func disableTBTime2() {
        self.tb1_time_label.text = PDStrings.time
        self.tb2_time_stack.isHidden = true
        self.tb2_time_big.isEnabled = false
        self.tb2_time_small.isEnabled = false
    }
    
    private func enableTBTime2() {
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
        self.tb_timesaday_picker.isHidden = true
        self.tb1_time_big.isSelected = false
        self.tb_timesaday_big.isSelected = false
        self.tb2_time_big.isSelected = false
    }
    
    private func disableExtraPG() {
        self.pg1_time_picker_view.isHidden = true
        self.pg2_time_picker_view.isHidden = true
        self.pg_timesaday_picker.isHidden = true
        self.pg1_time_picker.isHidden = true
        self.pg2_time_picker.isHidden = true
        self.pg1_time_big.isSelected = false
        self.pg2_time_big.isSelected = false
        self.pg_timesaday_big.isSelected = false
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
    
    internal func requestNotifications(scheduleIndex: Int) {
        // request notification iff exists Patch.date
        if let _ = ScheduleController.getMO(index: scheduleIndex) {
            (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyExpired(scheduleIndex: scheduleIndex)
            if SettingsDefaultsController.getRemindMeBefore() {
                (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyChangeSoon(scheduleIndex: scheduleIndex)
            }
        }
    }
    
    @IBAction func arrowTapped(_ sender: Any) {
        self.performSegue(withIdentifier: PDStrings.settingsToScheduleID, sender: self)
    }
    

}

extension SettingsVC: UIScrollViewDelegate {
    
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return settingsStack
    }
}
