//
//  SettingsViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/29/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class SettingsViewModel: CodeBehindDependencies<SettingsViewModel> {
    
    var selectedSetting: PDSetting? = nil
    var reflector: SettingsReflector
    var saver: SettingsStateSaver
    
    init(reflector: SettingsReflector, saver: SettingsStateSaver) {
        self.reflector = reflector
        self.saver = saver
        super.init()
    }
    
    func getSettingFromButton(_ button: UIButton) -> PDSetting? {
        guard let key = button.tryGetKeyFromButtonMetadata() else { return nil }
        return PDSetting(rawValue: key)
    }
    
    func activatePicker(pickers: SettingsPickers, activator: UIButton, onSuccess: () -> ()) {
        guard let key = selectedSetting else { return }
        guard let props = createPickerActivation(key: key, activator: activator, pickers: pickers) else { return }
        SettingsPickerActivator(activation: props, saver: saver).activate()
        onSuccess()
    }
    
    func getCurrentPickerOptions() -> [String] {
        PickerOptions.get(for: selectedSetting)
    }
    
    func getRowTitle(at row: Int) -> String? {
        getCurrentPickerOptions().tryGet(at: row)
    }
    
    func selectRow(row: Int) {
        guard let key = selectedSetting else { return }
        guard let selectedRowTitle = getRowTitle(at: row) else { return }
        reflector.reflectNewButtonTitle(key: key, newTitle: selectedRowTitle)
    }
    
    func handleNewNotificationsValue(_ newValue: Float) {
        notifications?.cancelAllExpiredHormoneNotifications()
        let newMinutesBeforeValue = Int(newValue)
        notificationsMinutesBeforeValueLabel.text = String(newMinutesBeforeValue)
        sdk?.settings.setNotificationsMinutesBefore(to: newMinutesBeforeValue)
        notifications?.requestAllExpiredHormoneNotifications()
    }
    
    private func createPickerActivation(key: PDSetting, activator: UIButton, pickers: SettingsPickers) -> PickerActivation? {
        let pickerSelector = SettingsPickerSelector(pickers)
        guard let picker = pickerSelector.selectPicker(key: key) else { return nil }
        let options = PickerOptions.get(for: key)
        let startRow = options.tryGetIndex(item: activator.titleLabel?.text) ?? 0
        return PickerActivation(
            picker: picker,
            activator: activator,
            options: options,
            startRow: startRow,
            propertyKey: key
        )
    }
}
