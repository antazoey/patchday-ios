//
//  SettingPicker.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/21/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit

class SettingsPicker {
    
    private let props: PickerActivationProperties
    private let saver: SettingsStateSaver
    
    init(pickerActivationProperties: PickerActivationProperties, saver: SettingsStateSaver) {
        self.props = pickerActivationProperties
        self.saver = saver
    }
    
    public func activate() {
        if !props.picker.isHidden {
            close()
        } else {
            props.activator.isSelected = true
            open()
        }
    }
    
    private func open() {
        props.picker.selectRow(props.startRow, inComponent: 0, animated: false)
        UIView.transition(
            with: props.picker as UIView,
            duration: 0.4,
            options: .transitionFlipFromTop,
            animations: { self.props.picker.isHidden = false },
            completion: nil
        )
    }

    private func close() {
        props.activator.isSelected = false
        props.picker.isHidden = true
        saver.save(props.propertyKey, selectedRow: props.startRow)
    }
}
