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
    
    @IBOutlet private weak var expirationIntervalPicker: UIPickerView!
    
    @IBOutlet private weak var numberOfPatchesPicker: UIPickerView!
    
    @IBOutlet private weak var reminderTimePicker: UIPickerView!
    
    @IBOutlet private weak var settingsView: UIView!
    
    @IBOutlet fileprivate weak var settingsStack: UIStackView!

    // options are "interval" and "count"
    private var whichTapped: String?
    private var selectedRow: Int?
    
    // Schedule outlets (in order of appearance
    @IBOutlet private weak var changePatchEvery: UIButton!
    @IBOutlet private weak var numberOfPatches: UIButton!
    
    // Notification outlets (in order of appearance)
    @IBOutlet private weak var notificationHeading: UILabel!
    @IBOutlet private weak var lineUnderNotificationHeading: UIView!
    @IBOutlet private weak var reminderExplanation: UILabel!
    @IBOutlet private weak var lineUnderReminderExplanation: UIView!
    @IBOutlet private weak var receiveReminderLabel: UILabel!
    @IBOutlet private weak var receiveReminder: UISwitch!
    @IBOutlet private weak var lineUnderReceiveReminderSwitch: UIView!
    @IBOutlet private weak var minutesBeforeLabel: UILabel!
    @IBOutlet private weak var notificationOption: UIButton!
    @IBOutlet private weak var notificationArrow: UIButton!
    @IBOutlet private weak var lineUnderNotificationOption: UIView!
    @IBOutlet private weak var changePatchFunctionExplanation: UILabel!
    @IBOutlet private weak var lineUnderPatchFunctionExplanation: UIView!
    @IBOutlet private weak var suggestLocationLabel: UILabel!
    @IBOutlet private weak var autoChooseSuggestedLocationSwitch: UISwitch!
    @IBOutlet private weak var lineUnderAutoSuggest: UIView!
    
    // bool
    private var weAreHidingFromPicker: Bool = false
    
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
    
    private func loadChangePatchEvery() {
        self.changePatchEvery.setTitle(SettingsDefaultsController.getPatchInterval(), for: .normal)
    }
    
    private func loadNumberOfPatches() {
        self.numberOfPatches.setTitle(SettingsDefaultsController.getNumberOfPatchesString(), for: .normal)
    }
    
    private func loadNotificationOption() {
        if self.receiveReminder.isOn {
            self.enableNotificationButtons()
        }
        else {
            self.disableNotificationButtons()
        }
        self.notificationOption.setTitle(SettingsDefaultsController.getNotificaitonTimeString(), for: .normal)
    }
    
    private func loadAutoChooseLocation() {
        self.autoChooseSuggestedLocationSwitch.setOn(SettingsDefaultsController.getAutoChooseLocation(), animated: true)
    }
    
    private func loadRemindMe() {
        self.receiveReminder.setOn(SettingsDefaultsController.getRemindMe(), animated: true)
    }
    
    // MARK: - Picker Functions
    
    private func delegatePickers() {
        self.expirationIntervalPicker.delegate = self
        self.numberOfPatchesPicker.delegate = self
        self.reminderTimePicker.delegate = self
    }
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // NUM OF ROWS...
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0;
        // for change patch every tapped:
        if self.getWhichTapped() == PDStrings.interval() {
            numberOfRows = PDStrings.expirationIntervals.count
        }
        // for number of patches tapped:
        else if self.getWhichTapped() == PDStrings.count() {
            numberOfRows = PDStrings.patchCounts.count
        }
        // for notification options tapped
        else if self.getWhichTapped() == PDStrings.notifications() {
            numberOfRows = PDStrings.notificationSettings.count
        }
        return numberOfRows
        
    }
    
    // ROW TITLES...
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title = " "
        // for change patch every tapped:
        if self.getWhichTapped() == PDStrings.interval() {
            if row < PDStrings.expirationIntervals.count && row >= 0 {
                title = PDStrings.expirationIntervals[row]
            }
        }
        // for number of patches tapped:
        else if self.getWhichTapped() == PDStrings.count() {
            if row < PDStrings.patchCounts.count && row >= 0 {
                title = PDStrings.patchCounts[row]
            }
        }
        // for notification options tapped
        else if self.getWhichTapped() == PDStrings.notifications()  {
            if row < PDStrings.notificationSettings.count && row >= 0 {
                title = PDStrings.notificationSettings[row]
            }
        }
        return title
        
    }
    
    // AFTER PICKED...
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.selectedRow = row
        
        if self.getWhichTapped() == PDStrings.interval() {
            // save
            if let row: Int = self.selectedRow {
                SettingsDefaultsController.setPatchInterval(to: PDStrings.expirationIntervals[row])
                // configure button title
                self.configureButtonTitleFromPicker(fromButton: self.changePatchEvery, withData: PDStrings.expirationIntervals, row: row)
            }
        }
        
        else if self.getWhichTapped() == PDStrings.count() {
            // save
            if let row: Int = self.selectedRow {
                SettingsDefaultsController.setNumberOfPatchesWithWarning(to: PDStrings.patchCounts[row], numberOfPatchesButton: self.numberOfPatches)
                // configure button title
                self.configureButtonTitleFromPicker(fromButton: self.numberOfPatches, withData: PDStrings.patchCounts, row: row)
            }
        }
        
        else if self.getWhichTapped() == PDStrings.notifications() {
            // save
            if let row: Int = self.selectedRow {
                SettingsDefaultsController.setNotificationOption(to: PDStrings.notificationSettings[row])
                // configure button title
                self.configureButtonTitleFromPicker(fromButton: self.notificationOption, withData: PDStrings.notificationSettings, row: row)
            }
        }
        
        // resets all the notifications
        for i in 0...(SettingsDefaultsController.getNumberOfPatchesInt()-1) {
            self.requestNotifications(patchIndex: i)
        }
        
    }
    
    private func openOrClosePicker(key: String) {
        // key is either "interval" , "count" , "notifications"
        
        // change member variable for determining correct picker
        self.setWhichTapped(to: key)
        
        // INTERVAL
        if self.getWhichTapped() == PDStrings.interval() {
            self.expirationIntervalPicker.reloadAllComponents()
            // if any other pickers are open, then close them
            if self.numberOfPatchesPicker.isHidden == false {
                self.numberOfPatchesPicker.isHidden = true
            }
            if self.reminderTimePicker.isHidden == false {
                self.reminderTimePicker.isHidden = true
            }
            self.openOrClose(picker: self.expirationIntervalPicker, buttonTapped: self.changePatchEvery, settingsList: PDStrings.expirationIntervals)
            
        }
            
        // COUNT
        else if self.getWhichTapped() == PDStrings.count() {
            self.numberOfPatchesPicker.reloadAllComponents()
            // if any other pickers are open, then close them
            if self.expirationIntervalPicker.isHidden == false {
                self.expirationIntervalPicker.isHidden = true
            }
            if self.reminderTimePicker.isHidden == false {
                self.reminderTimePicker.isHidden = true
            }
            self.openOrClose(picker: self.numberOfPatchesPicker, buttonTapped: self.numberOfPatches, settingsList: PDStrings.patchCounts)
        }
            
        // NOTIFICATIONS
        else if self.getWhichTapped() == PDStrings.notifications() {
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

    @IBAction private func notificationOptionArrowTapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.notifications())
        
    }
    @IBAction private func notificationOptionTapped(_ sender: Any) {
       self.openOrClosePicker(key: PDStrings.notifications())
    }
    
    @IBAction private func changePatchEveryArrowButtonTapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.interval())
    }
    
    @IBAction private func numberOfPatchesArrowButtonTapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.count())
    }
    
    @IBAction private func changePatchEveryTapped(_ sender: Any) {
        self.openOrClosePicker(key: PDStrings.interval())
        
    }
    
    @IBAction private func numberOfPatchesTapped(_ sender: Any) {
        // change member variable for determining correct picker
        self.openOrClosePicker(key: PDStrings.count())
        
    }
    
    // MARK: - IBActions switches
    
    @IBAction private func receiveReminderSwitched(_ sender: Any) {
        let isOn = self.receiveReminder.isOn
        if isOn {
            self.enableNotificationButtons()
        }
        else {
            self.disableNotificationButtons()
        }
        SettingsDefaultsController.setRemindMe(to: isOn)
    }
    
    @IBAction private func autoChooseLocationChangeSwitch(_ sender: Any) {
        let state = self.autoChooseSuggestedLocationSwitch.isOn
        PDAlertController.alertForAutoSuggestLocationDescription(changingTo: state)
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
    
    internal func requestNotifications(patchIndex: Int) {
        // request notification iff exists Patch.datePlaced
        if let _ = PatchDataController.getPatch(index: patchIndex) {
            (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyExpired(patchIndex: patchIndex)
            if SettingsDefaultsController.getRemindMe() {
                (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyChangeSoon(patchIndex: patchIndex)
            }
        }
    }

}

extension SettingsViewController: UIScrollViewDelegate {
    
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return settingsStack
    }
}
