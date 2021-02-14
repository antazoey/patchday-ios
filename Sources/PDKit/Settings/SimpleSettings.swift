//
//  MentionedDisclaimer.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.

import Foundation

public class MentionedDisclaimerUD: PDUserDefault<Bool, Bool>, BooleanKeyStorable {
    public var setting: PDSetting = .MentionedDisclaimer

    public convenience init() {
        self.init(DefaultSettings.MentionedDisclaimerRawValue)
    }
}

public class NotificationsMinutesBeforeUD: PDUserDefault<Int, Int>, IntKeyStorable {
    public var setting: PDSetting = .NotificationsMinutesBefore

    public convenience init() {
        self.init(DefaultSettings.NotificationsMinutesBeforeRawValue)
    }
}

public class NotificationsUD: PDUserDefault<Bool, Bool>, BooleanKeyStorable {
    public var setting: PDSetting = .Notifications

    public convenience init() {
        self.init(DefaultSettings.NotificationsRawValue)
    }
}

public class SiteIndexUD: PDUserDefault<Int, Int>, IntKeyStorable {
    public var setting: PDSetting = .SiteIndex

    public convenience init() {
        self.init(DefaultSettings.SiteIndexRawValue)
    }
}
