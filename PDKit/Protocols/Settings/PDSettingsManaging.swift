//
//  PDSettingsManaging.swift
//  PatchData
//
//  Created by Juliya Smith on 11/11/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol PDSettingsManaging: UserDefaultsReading {
    func setDeliveryMethod(to newMethod: DeliveryMethod)
    func setQuantity(to newQuantity: Int)
    func setExpirationInterval(to newInterval: String)
    func setNotifications(to newValue: Bool)
    func setNotificationsMinutesBefore(to newMinutes: Int)
    func setMentionedDisclaimer(to newValue: Bool)
    @discardableResult func setSiteIndex(to newIndex: Index) -> Index
    func reset(defaultSiteCount: Int)
}
