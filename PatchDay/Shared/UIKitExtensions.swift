//
//  UIKitExtensions.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/17/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit

extension UIPickerView {

    func selectRow(_ row: Int) {
        selectRow(row, inComponent: 0, animated: false)
    }
    
    func getSelectedRow() -> Int {
        return selectedRow(inComponent: 0)
    }
}

extension UISwitch {
    
    func setOn(_ on: Bool) {
        setOn(on, animated: false)
    }
}

extension UIButton {
    
    func setStatelessTitle(to title: String) {
        setTitle(title, for: .normal)
        setTitle(title, for: .disabled)
    }
    
    func setTitle(to title: String) {
        setTitle(title, for: .normal)
    }
}
