//
//  SettingsModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/24/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

class SettingsModel {
    
    public static func getIndex(selections: [String], choice: String?) -> Int {
        if let c = choice, let i = selections.firstIndex(of: c) {
            return i
        }
        return 0
    }
}
