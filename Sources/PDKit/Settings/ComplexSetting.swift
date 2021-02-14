//
//  ComplexSetting.swift
//  PDKit
//
//  Created by Juliya Smith on 3/1/20.
//  
//

import Foundation

public class ComplexSetting<T1, T2>: PDUserDefault<T1, T2> {

    public var choices: [String] = []

    public var currentIndex: Index {
        choices.tryGetIndex(item: displayableString) ?? 0
    }
}
