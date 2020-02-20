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
    
    var selectedDefault: PDDefault? = nil
    var reflector: SettingsReflector
    var saver: SettingsStateSaver
    
    init(reflector: SettingsReflector, saver: SettingsStateSaver) {
        self.reflector = reflector
        self.saver = saver
        super.init()
    }
    
    func createDefaultFromButton(_ button: UIButton) -> PDDefault? {
        if let key = button.tryGetKeyFromButtonMetadata() {
            return PDDefault(rawValue: key)
        }
        return nil
    }
    
    func activatePicker(pickers: SettingsPickers, activator: UIButton, onSuccess: () -> ()) {
        if let def = selectedDefault,
            let props = createPickerActivationProps(for: def, activator: activator, pickers: pickers) {
            SettingsPicker(pickerActivationProperties: props, saver: saver).activate()
            onSuccess()
        }
    }
    
    private func createPickerActivationProps(
        for key: PDDefault, activator: UIButton, pickers: SettingsPickers
    ) -> PickerActivationProperties? {
        let options = PickerOptions.getStrings(for: key)
        let pickerSelector = SettingsPickerSelector(pickers)
        if let picker = pickerSelector.selectPicker(key: key) {
            let startRow = options.tryGetIndex(item: activator.titleLabel?.text) ?? 0
            return PickerActivationProperties(
                picker: picker,
                activator: activator,
                options: options,
                startRow: startRow,
                propertyKey: key
            )
        }
        return nil
    }
}
