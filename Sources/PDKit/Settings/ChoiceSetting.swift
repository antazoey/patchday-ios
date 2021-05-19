//
//  ComplexSetting.swift
//  PDKit
//
//  Created by Juliya Smith on 3/1/20.

import Foundation

public class ChoiceSetting<T1, T2>: PDUserDefault<T1, T2> {

    public var choices: [String] = []

    public var choiceIndex: Index {
        choices.tryGetIndex(item: displayableString) ?? 0
    }
}
