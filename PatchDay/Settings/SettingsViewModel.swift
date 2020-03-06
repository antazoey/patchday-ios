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
    
    var deliveryMethodStartIndex: Index {
        sdk?.settings.deliveryMethod.currentIndex ?? 0
    }
    
    var quantityStartIndex: Index {
        sdk?.settings.quantity.currentIndex ?? 0
    }
    
    var expirationIntervalStartIndex: Index {
        sdk?.settings.expirationInterval.currentIndex ?? 0
    }
    
    var themeStartIndex: Index {
        sdk?.settings.theme.currentIndex ?? 0
    }
    
    func activatePicker(_ picker: SettingsPickerView, onSuccess: () -> ()) {
        if picker.isHidden {
            picker.open()
        } else {
            picker.close()
            saver.save(picker.setting, selectedRow: picker.getStartRow())
        }
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
        reflector.reflectNewButtonTitle(setting: key, newTitle: selectedRowTitle)
    }
    
    func handleNewNotificationsValue(_ newValue: Float) {
        notifications?.cancelAllExpiredHormoneNotifications()
        let newMinutesBeforeValue = Int(newValue)
        sdk?.settings.setNotificationsMinutesBefore(to: newMinutesBeforeValue)
        notifications?.requestAllExpiredHormoneNotifications()
    }
}
