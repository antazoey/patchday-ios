//
//  PDUserDefault.swift
//  PDKit
//
//  Created by Juliya Smith on 2/23/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


public class PDUserDefault<T1, T2> {
    
    public var value: T1 { rawValue as! T1 }
    
    public var rawValue: T2
    
    public var setting: PDSetting
    
    init(_ rawValue: T2, setting: PDSetting) {
        self.rawValue = rawValue
        self.setting = setting
    }
}
