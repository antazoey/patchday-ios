//
//  PDSettingsPickerView.swift
//  PatchDay
//
//  Created by Juliya Smith on 2/22/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


class SettingsPickerView: UIPickerView {
    
    public var setting: PDSetting?
    public var choices: [String] = []
    public var startIndex = 0
}
