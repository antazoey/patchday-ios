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
    
    var selectedSettings: PDSetting? = nil
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
        if let settings = selectedSettings,
            let props = createPickerActivation(key: settings, activator: activator, pickers: pickers) {
            SettingsPickerActivator(activation: props, saver: saver).activate()
            onSuccess()
        }
    }
    
    private func createPickerActivation(key: PDSetting, activator: UIButton, pickers: SettingsPickers) -> PickerActivation? {
        let pickerSelector = SettingsPickerSelector(pickers)
        guard let picker = pickerSelector.selectPicker(key: key) else { return nil }
        let options = PickerOptions.getStrings(for: key)
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
