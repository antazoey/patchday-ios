//
//  SettingPickerActivator.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/21/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit


class SettingsPickerActivator {
    
    private let activation: PickerActivation
    private let saver: SettingsStateSaver
    
    init(activation: PickerActivation, saver: SettingsStateSaver) {
        self.activation = activation
        self.saver = saver
    }
    
    public func activate() {
        activation.picker.isHidden ? open() : close()
    }
    
    private func open() {
        activation.activator.isSelected = true
        activation.picker.selectRow(activation.startRow, inComponent: 0, animated: false)
        UIView.transition(
            with: activation.picker as UIView,
            duration: 0.4,
            options: .transitionFlipFromTop,
            animations: { self.activation.picker.isHidden = false },
            completion: nil
        )
    }

    private func close() {
        activation.activator.isSelected = false
        activation.picker.isHidden = true
        saver.save(activation.propertyKey, selectedRow: activation.startRow)
    }
}
