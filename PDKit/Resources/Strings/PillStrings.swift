//
//  PillStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 2/15/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


public class PillStrings {
    
    public static let NewPill = {
        NSLocalizedString("New Pill", comment: "Displayed under a button with medium room.")
    }()
    
    public static let NotYetTaken = {
        NSLocalizedString("Not yet taken", comment: "Short as possible. Replace with just ... if too long.")
    }()
    
    public struct PillTypes {
        public static let defaultPills = { ["T-Blocker", "Progesterone"] }()
        public static let extraPills = { ["Estrogen", "Prolactin"] }()
    }
}
