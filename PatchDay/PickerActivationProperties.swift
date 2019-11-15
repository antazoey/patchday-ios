//
//  PickerActivationProperties.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

struct PickerActivationProperties {
    var picker: UIPickerView
    var activator: UIButton
    var choices: [String]
    var startRow: Index
    var propertyKey: PDDefault
}
