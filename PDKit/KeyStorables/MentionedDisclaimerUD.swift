//
//  MentionedDisclaimer.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class MentionedDisclaimerUD: PDKeyStorable {
    
    public typealias Value = Bool
    
    public typealias RawValue = Bool
    
    public required init(with val: Bool) { value = val }
    
    public convenience required init() { self.init(with: false) }
    
    public var value: Bool
    
    public var rawValue: Bool { value }
    
    public static var key = PDDefault.MentionedDisclaimer
}
