//
//  SettingsPickerViewing.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol SettingsPickerViewing {

    /// The setting this picker is for.
    var setting: PDSetting? { get }

    /// A method that returns the start index.
    var getStartRow: () -> Index { get }

    /// The available picker options that the user can select.
    var options: [String]? { get }

    /// The number of available options
    var count: Int { get }

    /// The current selected option.
    var selected: String? { get }

    /// The property from UIView.
    var isHidden: Bool { get set }

    /// The associated UIPickerView.
    var view: UIPickerView { get }

    /// Open the picker so the user can select an option.
    func open()

    /// Close the picker after the user selects on option.
    func close(setSelectedRow: Bool)

    /// The method from setting picker views.
    func selectedRow(inComponent component: Int) -> Int

    /// Handle a user selecting a row.
    func select(_ row: Index)
}
