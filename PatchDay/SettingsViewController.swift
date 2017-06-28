//
//  SettingsViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/20/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var settingsView: UIView!
    
    // Picker Vars
    @IBOutlet weak var multiPicker: UIPickerView!
    // options are "interval" and "count"
    private var whichTapped: String? = nil
    
    @IBOutlet weak var numberOfPatchesPicker: UIPickerView!
    
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
        self.delegatePicker()
        
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
    
    func delegatePicker() {
        self.multiPicker.delegate = self
        self.multiPicker.dataSource = self
        
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
            title = PatchDayStrings.expirationIntervals[row]
        }
        // for number of patches tapped:
        else if self.getWhichTapped() == PatchDayStrings.count() {
            title = PatchDayStrings.patchCounts[row]
        }
        // for notification options tapped
        else if self.getWhichTapped() == PatchDayStrings.notifications() {
            title = PatchDayStrings.notificationSettings[row]
        }
        return title
        
    }
    
    // AFTER PICKED...
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // DID SELECT ROW
        // change label of corresponding button
        if self.getWhichTapped() == PatchDayStrings.interval() {
            self.configureButtonTitleFromPicker(fromButton: self.changePatchEvery, withData: PatchDayStrings.expirationIntervals, row: row)
            // update User Defaults
            // resets all the notifications
            SettingsController.setExpirationInterval(with: PatchDayStrings.expirationIntervals[row])
            for i in 0...(SettingsController.getNumberOfPatchesInt()-1) {
                (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyExpired(patchIndex: i)
                if SettingsController.getNotifyMeBool() {
                    (UIApplication.shared.delegate as! AppDelegate).notificationsController.requestNotifyChangeSoon(patchIndex: i)
                }
            }
        }
        else if self.getWhichTapped() == PatchDayStrings.count() {
            // WARNING: This overwrites patch data
            PDAlertController.alertForChangingPatchCount(newPatchCount: row, numberOfPatchesButton: self.numberOfPatches)
        }
        else if self.getWhichTapped() == PatchDayStrings.notifications() {
            self.configureButtonTitleFromPicker(fromButton: self.notificationOption, withData: PatchDayStrings.notificationSettings, row: row)
            // update User Defaults
            SettingsController.setNotificationTime(with: PatchDayStrings.notificationSettings[row])
        }
        
        self.multiPicker.isHidden = true
        if weAreHidingFromPicker {
            self.unHideNotificationOutlets()
        }
    }
    
    // MARK: - IBActions Picker loads
    
    @IBAction func notificationOptionArrowTapped(_ sender: Any) {
        self.loadPicker(key: PatchDayStrings.notifications())
        
    }
    @IBAction func notificationOptionTapped(_ sender: Any) {
       self.loadPicker(key: PatchDayStrings.notifications())
    }
    
    @IBAction func changePatchEveryArrowButtonTapped(_ sender: Any) {
        self.loadPicker(key: PatchDayStrings.interval())
    }
    
    @IBAction func numberOfPatchesArrowButtonTapped(_ sender: Any) {
        self.loadPicker(key: PatchDayStrings.count())
    }
    
    @IBAction func changePatchEveryTapped(_ sender: Any) {
        self.loadPicker(key: PatchDayStrings.interval())
        
    }
    
    @IBAction func numberOfPatchesTapped(_ sender: Any) {
        // change member variable for determining correct picker
        self.loadPicker(key: PatchDayStrings.count())
        
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
        SettingsController.setAutoChoose(bool: state)

    }
    
    // MARK: - other IBActions
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        PDAlertController.alertForResettingPatchData()
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
    
    private func hideNotificationOutlets() {
        self.notificationHeading.isHidden = true
        self.lineUnderNotificationHeading.backgroundColor = self.getBackgroundColor()
        self.reminderExplanation.isHidden = true
        self.lineUnderReminderExplanation.backgroundColor = self.getBackgroundColor()
        self.receiveReminderLabel.isHidden = true
        self.receiveReminder.isHidden = true
        self.lineUnderReceiveReminderSwitch.backgroundColor = self.getBackgroundColor()
        self.minutesBeforeLabel.isHidden = true
        self.notificationOption.isHidden = true
        self.notificationArrow.isHidden = true
        self.lineUnderNotificationOption.backgroundColor = self.getBackgroundColor()
        self.changePatchFunctionExplanation.isHidden = true
        self.lineUnderPatchFunctionExplanation.backgroundColor = self.getBackgroundColor()
        self.suggestLocationLabel.isHidden = true
        self.autoChooseSuggestedLocationSwitch.isHidden = true
        self.lineUnderAutoSuggest.backgroundColor = self.getBackgroundColor()
        
    }
    
    private func unHideNotificationOutlets() {
        self.notificationHeading.isHidden = false
        self.lineUnderNotificationHeading.backgroundColor = PatchDayColors.darkLines
        self.reminderExplanation.isHidden = false
        self.lineUnderReminderExplanation.backgroundColor = PatchDayColors.lightLines
        self.receiveReminderLabel.isHidden = false
        self.receiveReminder.isHidden = false
        self.lineUnderReceiveReminderSwitch.backgroundColor = PatchDayColors.lightLines
        self.minutesBeforeLabel.isHidden = false
        self.notificationOption.isHidden = false
        self.notificationArrow.isHidden = false
        self.lineUnderNotificationOption.backgroundColor = PatchDayColors.lightLines
        self.changePatchFunctionExplanation.isHidden = false
        self.lineUnderPatchFunctionExplanation.backgroundColor = PatchDayColors.lightLines
        self.suggestLocationLabel.isHidden = false
        self.autoChooseSuggestedLocationSwitch.isHidden = false
        self.lineUnderAutoSuggest.backgroundColor = PatchDayColors.lightLines

    }
    
    private func loadPicker(key: String) {
        // key is either "interval" , "count" , "notifications"
        
        // change member variable for determining correct picker
        self.setWhichTapped(to: key)
        self.multiPicker.reloadAllComponents()
        // Unhide the picker
        self.multiPicker.isHidden = false
        // hide outlets that get in the way of the picker on some devices...
        if self.pickerViewDoesObtrude() {
            self.hideNotificationOutlets()
            self.weAreHidingFromPicker = true
        }
        // set start of picker
        if self.getWhichTapped() == PatchDayStrings.interval() {
            if let title = self.changePatchEvery.titleLabel, let readText = title.text {
                guard let selectedRowIndex = PatchDayStrings.expirationIntervals.index(of: readText) else {
                    return
                }
                self.multiPicker.selectRow(selectedRowIndex, inComponent: 0, animated: false)
            }
        }
        else if self.getWhichTapped() == PatchDayStrings.count() {
            if let title = self.numberOfPatches.titleLabel, let readText = title.text {
                guard let selectedRowIndex = PatchDayStrings.patchCounts.index(of: readText) else {
                    return
                }
                self.multiPicker.selectRow(selectedRowIndex, inComponent: 0, animated: false)
            }
        }
        else if self.getWhichTapped() == PatchDayStrings.notifications() {
            if let title = self.notificationOption.titleLabel, let readText = title.text {
                guard let selectedRowIndex = PatchDayStrings.notificationSettings.index(of: readText) else {
                    return
                }
                self.multiPicker.selectRow(selectedRowIndex, inComponent: 0, animated: false)
            }
        }
        
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
    
    private func getBottomLineY() -> CGFloat {
        let convertedFrame = self.lineUnderAutoSuggest.convert(self.notificationHeading.frame, to: self.settingsView)
        return convertedFrame.origin.y
    }
    
    private func getPickerY() -> CGFloat {
        return self.multiPicker.frame.origin.y
    }
    
    private func pickerViewDoesObtrude() -> Bool {
        // indicates if certain views are in the way of seeing the picker
        return (self.getPickerY() + 45) <= self.getBottomLineY()
    }

}
