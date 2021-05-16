//
//  MockSettingsPicker.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockSettingsPicker: SettingsPicking, Equatable {

    public init() {}

    public var setting: PDSetting?
    public var activator: UIButton = UIButton()
    public var getStartRow: (SettingsPicking) -> Index = { _ in 0 }
    public var options: [String]?
    public var count: Int { options?.count ?? 0 }
    public var selected: String?
    public var isHidden: Bool = false
    public var view: UIPickerView = UIPickerView()

    public static func == (lhs: MockSettingsPicker, rhs: MockSettingsPicker) -> Bool {
        lhs.view == rhs.view
    }

    public var openCallCount = 0
    public func open() {
        openCallCount += 1
    }

    public var closeCallArgs: [Bool] = []
    public func close(setSelectedRow: Bool) {
        closeCallArgs.append(setSelectedRow)
    }

    public var selectRowCallArgs: [Int] = []
    public var selectRowReturnValue = 0
    public func selectedRow(inComponent component: Int) -> Int {
        selectRowCallArgs.append(component)
        return selectRowReturnValue
    }

    public var selectCallArgs: [Index] = []
    public func select(_ row: Index) {
        selectCallArgs.append(row)
    }
}
