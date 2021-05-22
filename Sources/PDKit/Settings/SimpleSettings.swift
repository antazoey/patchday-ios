//
//  MentionedDisclaimer.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.

import Foundation

public class MentionedDisclaimerUD: PDUserDefault<Bool, Bool>, BooleanKeyStorable {
    public var setting: PDSetting = .MentionedDisclaimer

    public convenience init() {
        self.init(DefaultSettings.MENTIONED_DISCLAIMER_RAW_VALUE)
    }
}

public class NotificationsMinutesBeforeUD: PDUserDefault<Int, Int>, IntKeyStorable {
    public var setting: PDSetting = .NotificationsMinutesBefore

    public convenience init() {
        self.init(DefaultSettings.NOTIFICATIONS_MINUTES_BEFORE_RAW_VALUE)
    }
}

public class NotificationsUD: PDUserDefault<Bool, Bool>, BooleanKeyStorable {
    public var setting: PDSetting = .Notifications

    public convenience init() {
        self.init(DefaultSettings.NOTIFICATIONS_RAW_VALUE)
    }
}

public class SiteIndexUD: PDUserDefault<Int, Int>, IntKeyStorable {
    public var setting: PDSetting = .SiteIndex

    public convenience init() {
        self.init(DefaultSettings.SITE_INDEX_RAW_VALUE)
    }
}

public class PillsEnabledUD: PDUserDefault<Bool, Bool>, BooleanKeyStorable {
    public var setting: PDSetting = .PillsEnabled

    public convenience init() {
        self.init(DefaultSettings.PILLS_ENABLED_RAW_VALUE)
    }
}

public class UseStaticExpirationTimeUD: PDUserDefault<Bool, Bool>, BooleanKeyStorable {
    public var setting: PDSetting = .UseStaticExpirationTime

    public convenience init() {
        self.init(DefaultSettings.USE_STATIC_EXPIRATION_TIME)
    }
}
