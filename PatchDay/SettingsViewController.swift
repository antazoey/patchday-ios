//
//  SettingsViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/20/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Pickers
    
    @IBOutlet weak var expirationIntervalPicker: UIPickerView!
    
    @IBOutlet weak var numberOfPatchesPicker: UIPickerView!
    
    @IBOutlet weak var reminderTimePicker: UIPickerView!
    
    @IBOutlet weak var settingsView: UIView!
    
    @IBOutlet weak var settingsStack: UIStackView!

    // options are "interval" and "count"
    private var whichTapped: String?
    private var selectedRow: Int?
    
    // Schedule outlets (in order of appearance
    @IBOutlet weak var changePatchEvery: UIButton!
    @IBOutlet var numberOfPatches: UIButton!
    
    // Notification outlets (in order of appearance)
    @IBOutlet weak var notificationHeading: UILabel!
    @IBOutlet weak var lineUnderNotificationHeading: UIView!
    @IBOutlet weak var reminderExplanation: UILabel!
    @IBOutlet weak var lineUnderReminderExplanation: UIView!
    @IBOutlet weak var receiveReminderLabel: UILabel!
    @IBOutlet weak var receiveReminder: UISwitch!
    @IBOutlet weak var lineUnderReceiveReminderSwitch: UIView!
    @IBOutlet weak var minutesBeforeLabel: UILabel!
    @IBOutlet weak var notificationOption: UIButton!
    @IBOutlet weak var notificationArrow: UIButton!
    @IBOutlet weak var lineUnderNotificationOption: UIView!
    @IBOutlet weak var changePatchFunctionExplanation: UILabel!
    @IBOutlet weak var lineUnderPatchFunctionExplanation: UIView!
    @IBOutlet weak var suggestLocationLabel: UILabel!
    @IBOutlet weak var autoChooseSuggestedLocationSwitch: UISwitch!
    @IBOutlet weak var lineUnderAutoSuggest: UIView!
    
    // bool
    public var weAreHidingFromPicker: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        PDAlertController.currentVC = self
        self.numberOfPatches.tag = 10
        self.settingsView.backgroundColor = UIColor.white
        self.loadSwipe()
        self.delegatePickers()
        
        // load titles
        self.loadRemindMe()
        self.loadChangePatchEvery()
        self.loadNumberOfPatches()
        self.loadNotificationOption()
        self.loadAutoChooseLocation()
    }
    
    // MARK: - Data loaders
    
    func loadChangePatchEvery() {
        self.changePatchEvery.setTitle(SettingsController.getExpirationInterval(), for: .normal)
    }
    
    func loadNumberOfPatches() {
        self.numberOfPatches.setTitle(SettingsController.getNumberOfPatchesString(), for: .normal)
    }
    
    func loadNotificationOption() {
        if self.receiveReminder.isOn {
            self.enableNotificationButtons()
        }
        else {
            self.disableNotificationButtons()
        }
        self.notificationOption.setTitle(SettingsController.getNotificationTimeString(), for: .normal)
    }
    
    func loadAutoChooseLocation() {
        self.autoChooseSuggestedLocationSwitch.setOn(SettingsController.getAutoChooseBool(), animated: true)
    }
    
    func loadRemindMe() {
        self.receiveReminder.setOn(SettingsController.getNotifyMeBool(), animated: true)
    }
    
    // MARK: - Picker Functions
    
    func delegatePickers() {
        self.expirationIntervalPicker.delegate = self
        self.numberOfPatchesPicker.delegate = self
        self.reminderTimePicker.delegate = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // NUM OF ROWS...
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0;
        // for change patch every tapped:
        if self.getWhichTapped() == PatchDayStrings.interval() {
            numberOfRows = PatchDayStrings.expirationIntervals.count
        }
        // for number of patches tapped:
        else if self.getWhichTapped() == PatchDayStrings.count() {
            numberOfRows = PatchDayStrings.patchCounts.count
        }
        // for notification options tapped
        else if self.getWhichTapped() == PatchDayStrings.notifications() {
            numberOfRows = PatchDayStrings.notificationSettings.count
        }
        return numberOfRows
        
    }
    
    // ROW TITLES...
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title = " "
        // for change patch every tapped:
        if self.getWhichTapped() == PatchDayStrings.interval() {
            if row < PatchDayStrings.expirationIntervals.count && row >= 0 {
                title = PatchDayStrings.expirationIntervals[row]
            }
        }
        // for number of patches tapped:
        else if self.getWhichTapped() == PatchDayStrings.count() {
            if row < PatchDayStrings.patchCounts.count && row >= 0 {
                title = PatchDayStrings.patchCounts[row]
            }
        }
        // for notification options tapped
        else if self.getWhichTapped() == PatchDayStrings.notifications()  {
            if row < PatchDayStrings.notificationSettings.count && row >= 0 {
                title = PatchDayStrings.notificationSettings[row]
            }
        }
        return title
        
    }
    
    // AFTER PICKED...
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.selectedRow = row
        
        if self.getWhichTapped() == PatchDayStrings.interval() {
            // save
            if let row: Int = self.selectedRow {
                SettingsController.setExpirationInterval(with: PatchDayStrings.expirationIntervals[row])
                // configure button title
                self.configureButtonTitleFromPicker(fromButton: self.changePatchEvery, withData: PatchDayStrings.expirationIntervals, row: row)
            }
        }
        
        else if self.getWhichTapped() == PatchDayStrings.count() {
            // save
            if let row: Int = self.selectedRow {
                SettingsController.setNumberOfPatches(with: PatchDayStrings.patchCounts[row])
                // configure button title
                self.configureButtonTitleFromPicker(fromButton: self.numberOfPatches, withData: PatchDayStrings.patchCounts, row: row)
            }
        }
        
        else if self.getWhichTapped() == PatchDayStrings.notifications() {
            // save
            if let row: Int = self.selectedRow {
                SettingsController.setNotificationTime(with: PatchDayStrings.patchCounts[row])
                // configure button title
                self.configureButtonTitleFromPicker(fromButton: self.notificationOption, withData: PatchDayStrings.notificationSettings, row: row)
            }
        }
        
        // resets all the notifications
        for i in 0...(SettingsController.getNumberOfPatchesInt()-1) {
            self.requestNotifications(patchIndex: i)
        }
        
    }
    
    private func openOrClosePicker(key: String) {
        // key is either "interval" , "count" , "notifications"
        
        // change member variable for determining correct picker
        self.setWhichTapped(to: key)
        
        // INTERVAL
        if self.getWhichTapped() == PatchDayStrings.interval() {
            self.expirationIntervalPicker.reloadAllComponents()
            // if any other pickers are open, then close them
            if self.numberOfPatchesPicker.isHidden == false {
                self.numberOfPatchesPicker.isHidden = true
            }
            if self.reminderTimePicker.isHidden == false {
                self.reminderTimePicker.isHidden = true
            }
            self.openOrClose(picker: self.expirationIntervalPicker, buttonTapped: self.changePatchEvery, settingsList: PatchDayStrings.expirationIntervals)
            
        }
            
        // COUNT
        else if self.getWhichTapped() == PatchDayStrings.count() {
            self.numberOfPatchesPicker.reloadAllComponents()
            // if any other pickers are open, then close them
            if self.expirationIntervalPicker.isHidden == false {
                self.expirationIntervalPicker.isHidden = true
            }
            if self.reminderTimePicker.isHidden == false {
                self.reminderTimePicker.isHidden = true
            }
            self.openOrClose(picker: self.numberOfPatchesPicker, buttonTapped: self.numberOfPatches, settingsList: PatchDayStrings.patchCounts)
        }
            
        // NOTIFICATIONS
        else if self.getWhichTapped() == PatchDayStrings.notifications() {
            self.reminderTimePicker.reloadAllComponents()
            // if any other pickers are open, then close them
            if self.expirationIntervalPicker.isHidden == false {
                self.expirationIntervalPicker.isHidden = true
            }
            if self.numberOfPatchesPicker.isHidden == false {
                self.numberOfPatchesPicker.isHidden = true
            }
            self.openOrClose(picker: self.reminderTimePicker, buttonTapped: self.notificationOption, settingsList: PatchDayStrings.notificationSettings)
        }
        
    }
    
    private func openOrClose(picker: UIPickerView, buttonTapped: UIButton, settingsList: [String]) {
        // if already open, close the picker
        if picker.isHidden == false {
            // close it
            picker.isHidden = true
            // exit call
            return
        }
        if let title = buttonTapped.titleLabel, let readText = title.text {
            guard let selectedRowIndex = settingsList.index(of: readText) else {
                picker.selectRow(0, inComponent: 0, animated: false)
                picker.isHidden = false
                return
            }
            picker.selectRow(selectedRowIndex, inComponent: 0, animated: false)
        }
        picker.isHidden = false
    }

    // MARK: - IBActions Picker loads

    @IBAction func notificationOptionArrowTapped(_ sender: Any) {
        self.openOrClosePicker(key: PatchDayStrings.notifications())
        
    }
    @IBAction func notificationOptionTapped(_ sender: Any) {
       self.openOrClosePicker(key: PatchDayStrings.notifications())
    }
    
    @IBAction func changePatchEveryArrowButtonTapped(_ sender: Any) {
        self.openOrClosePicker(key: PatchDayStrings.interval())
    }
    
    @IBAction func numberOfPatchesArrowButtonTapped(_ sender: Any) {
        self.openOrClosePicker(key: PatchDayStrings.count())
    }
    
    @IBAction func changePatchEveryTapped(_ sender: Any) {
        self.openOrClosePicker(key: PatchDayStrings.interval())
        
    }
    
    @IBAction func numberOfPatchesTapped(_ sender: Any) {
        // change member variable for determining correct picker
        self.openOrClosePicker(key: PatchDayStrings.count())
        
    }
    
    // MARK: - IBActions switches
    
    @IBAction func receiveReminderSwitched(_ sender: Any) {
        let isOn = self.receiveReminder.isOn
        if isOn {
            self.enableNotificationButtons()
        }
        else {
            self.disableNotificationButtons()
        }
        SettingsController.setNotifyMe(bool: isOn)
    }
    
    @IBAction func autoChooseLocationChangeSwitch(_ sender: Any) {
        let state = self.autoChooseSuggestedLocationSwitch.isOn
        PDAlertController.alertForAutoSuggestLocationDescription(changingTo: state)
    }
    
    // MARK: - segues
    
    // to Patch Schedule - this is needed for the swipe, see viewDidLoad()
    func showPatchScheduleView() {
        self.performSegue(withIdentifier: PatchDayStrings.settingsToScheduleID, sender: self)
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
    
    private func configureButtonTitleFromPicker(fromButton: UIButton, withData: [String], row: Int) {
        // change the pushed state of the button
        fromButton.titleLabel?.text = withData[row]
        // change the normal state of the button
        fromButton.setTitle(withData[row], for: .normal)
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
    
    public func requestNotifications(patchIndex: Int) {
        // request notification iff exists Patch.datePlaced
        if let _ = PatchDataController.getPatch(forIndex: patchIndex) {
            (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyExpired(patchIndex: patchIndex)
            if SettingsController.getNotifyMeBool() {
                (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyChangeSoon(patchIndex: patchIndex)
            }
        }
        
    }

}

extension SettingsViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return settingsStack
    }
}
