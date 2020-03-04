//
//  PDSettingsPickerView.swift
//  PatchDay
//
//  Created by Juliya Smith on 2/22/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class SettingsPickerView: UIPickerView {

    public var setting: PDSetting!
    public var activator: UIButton?
    public var getStartRow: () -> Index = { 0 }
    
    public func open() {
        activator?.isSelected = true
        selectStartRow()
        show()
    }
    
    public func close() {
        activator?.isSelected = false
        isHidden = true
    }
    
    private func selectStartRow() {
        let startRow = getStartRow()
        selectRow(startRow, inComponent: 0, animated: false)
    }
    
    private func show() {
        UIView.transition(
            with: self as UIView,
            duration: 0.4,
            options: .transitionFlipFromTop,
            animations: { self.isHidden = false },
            completion: nil
        )
    }
}
