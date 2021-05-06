//
//  PDSettingsPicker.swift
//  PatchDay
//
//  Created by Juliya Smith on 2/22/20.

import UIKit
import PDKit

class SettingsPicker: UIPickerView, SettingsPicking {

    private var _activator: UIButton?
    public var setting: PDSetting?

    public var activator: UIButton {
        get { _activator ?? UIButton() }
        set {
            newValue.setTitle(ActionStrings.Save, for: .selected)
            _activator = newValue
        }
    }

    public subscript(_ index: Index) -> NSAttributedString {
        let title = options?.tryGet(at: index) ?? ""
        let textColor = PDColors[.Text]
        return NSAttributedString(
            string: title, attributes: [NSAttributedString.Key.foregroundColor: textColor]
        )
    }

    public var getStartRow: () -> Index = { 0 }

    public var options: [String]?

    public var count: Int {
        options?.count ?? 0
    }

    public var selected: String? {
        options?.tryGet(at: selectedRow(inComponent: 0))
    }

    public var view: UIPickerView {
        self as UIPickerView
    }

    public func open() {
        _activator?.isSelected = true
        show()
        selectStartRow()
    }

    public func close(setSelectedRow: Bool) {
        isHidden = true
        guard let button = _activator else { return }
        button.isSelected = false
        button.isHighlighted = false
        if setSelectedRow, let selected = selected {
            button.setTitle(selected)
            button.setNeedsDisplay()
        }
    }

    public func select(_ row: Index) {
        activator.setTitle(self[row].string)
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
