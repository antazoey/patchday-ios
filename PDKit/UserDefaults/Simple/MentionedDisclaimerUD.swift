//
//  MentionedDisclaimer.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class MentionedDisclaimerUD: SimpleUserDefault<Bool>, BooleanKeyStorable {

    public convenience required init() { self.init(false) }
    public static var key = PDDefault.MentionedDisclaimer
}
