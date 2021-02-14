//
//  ComplexSetting.swift
//  PDKit
//
//  Created by Juliya Smith on 3/1/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class ComplexSetting<T1, T2>: PDUserDefault<T1, T2> {

    public var choices: [String] = []

    public var currentIndex: Index {
        choices.tryGetIndex(item: displayableString) ?? 0
    }
}
