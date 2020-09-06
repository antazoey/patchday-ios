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

    private var _activator: UIButton?

    public var setting: PDSetting?
    public var activator: UIButton {
        get { _activator ?? UIButton() }
        set {
            newValue.setTitle(ActionStrings.Save, for: .selected)
            _activator = newValue
        }
    }
    public var getStartRow: () -> Index = { 0 }

    public var options: [String]?

    public var selected: String? {
        options?.tryGet(at: selectedRow(inComponent: 0))
    }

    public func open() {
        _activator?.isSelected = true
        show()
        selectStartRow()
    }

    public func close(setSelectedRow: Bool=true) {
        isHidden = true
        guard let button = _activator else { return }
        button.isSelected = false
        button.isHighlighted = false
        if setSelectedRow, let selected = selected {
            button.setTitle(selected)
            button.setNeedsDisplay()
        }
    }

    private func selectStartRow() {
        selectRow(getStartRow(), inComponent: 0, animated: true)
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
