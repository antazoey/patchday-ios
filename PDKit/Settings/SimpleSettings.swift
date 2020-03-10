//
//  MentionedDisclaimer.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class MentionedDisclaimerUD: PDUserDefault<Bool, Bool>, BooleanKeyStorable {
    public var setting: PDSetting = .MentionedDisclaimer
}

public class NotificationsMinutesBeforeUD: PDUserDefault<Int, Int>, IntKeyStorable {
    public var setting: PDSetting = .NotificationsMinutesBefore
}

public class NotificationsUD: PDUserDefault<Bool, Bool>, BooleanKeyStorable {
    public var setting: PDSetting = .Notifications
}

public class SiteIndexUD: PDUserDefault<Int, Int>, IntKeyStorable {
    public var setting: PDSetting = .SiteIndex
}
