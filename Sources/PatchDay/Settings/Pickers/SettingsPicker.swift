//
//  SettingsPicker.swift
//  PatchDay
//
//  Created by Juliya Smith on 2/22/20.

import UIKit
import PDKit

class SettingsPicker: UIPickerView, SettingsPicking {

    private var _activator: UIButton?
    var setting: PDSetting?
    var indexer: SettingsPickerIndexing?

    public var activator: UIButton {
        get { _activator ?? UIButton() }
        set {
            newValue.setTitle(ActionStrings.Save, for: .selected)
            _activator = newValue
        }
    }

    subscript(_ index: Index) -> NSAttributedString {
        let title = options.tryGet(at: index) ?? ""
        let attributes = [NSAttributedString.Key.foregroundColor: PDColors[.Text]]
        return NSAttributedString(string: title, attributes: attributes)
    }

    var getStartRow: () -> Index = { 0 }

    var options: [String] {
        SettingsOptions[setting]
    }

    var count: Int {
        options.count
    }

    var view: UIPickerView {
        self as UIPickerView
    }

    func open() {
        _activator?.isSelected = true
        show()
        selectStartRow()
    }

    func close(setSelectedRow: Bool) {
        isHidden = true
        activator.isSelected = false
        activator.isHighlighted = false
        if setSelectedRow, let selected = selected {
            activator.setTitle(selected)
            activator.setNeedsDisplay()
        }
    }

    private var selected: String? {
        options.tryGet(at: selectedRow(inComponent: 0))
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
