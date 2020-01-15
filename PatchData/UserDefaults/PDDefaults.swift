//
//  PDDefaults.swift
//  PatchData
//
//  Created by Juliya Smith on 11/11/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class PDDefaults: UserDefaultsManaging {

    private let store: UserDefaultsWriting
    private var state: PDState
    private let hormones: HormoneScheduling
    private let sites: HormoneSiteScheduling

    init(
        store: UserDefaultsWriting,
        state: PDState,
        hormones: HormoneScheduling,
        sites: HormoneSiteScheduling
    ) {
        self.store = store
        self.state = state
        self.hormones = hormones
        self.sites = sites
    }

    public var deliveryMethod: DeliveryMethodUD { store.deliveryMethod }
    public var expirationInterval: ExpirationIntervalUD { store.expirationInterval }
    public var quantity: QuantityUD { store.quantity }
    public var notifications: NotificationsUD { store.notifications }
    public var notificationsMinutesBefore: NotificationsMinutesBeforeUD { store.notificationsMinutesBefore }
    public var mentionedDisclaimer: MentionedDisclaimerUD { store.mentionedDisclaimer }
    public var siteIndex: SiteIndexUD { store.siteIndex }
    public var theme: PDThemeUD { store.theme }

    public func setDeliveryMethod(to newMethod: DeliveryMethod) {
        store.replaceStoredDeliveryMethod(to: newMethod)
        let newIndex = KeyStorableHelper.defaultQuantity(for: newMethod)
        store.replaceStoredSiteIndex(to: newIndex, siteCount: sites.count)
        hormones.broadcastData()
        state.deliveryMethodChanged = true
    }

    public func setQuantity(to newQuantity: Int) {
        let endRange = PickerOptions.quantities.count
        if newQuantity < endRange && newQuantity > 0 {
            let oldQuantity = store.quantity.rawValue
            if newQuantity < oldQuantity {
                state.decreasedQuantity = true
                hormones.delete(after: newQuantity - 1)
            } else if newQuantity > oldQuantity {
                state.decreasedQuantity = false
                hormones.fillIn(to: newQuantity)
            }
            store.replaceStoredQuantity(to: newQuantity)
        }
    }

    public func setExpirationInterval(to newInterval: String) {
        let exp = PickerOptions.getExpirationInterval(for: newInterval)
        store.replaceStoredExpirationInterval(to: exp)
    }

    public func setTheme(to newTheme: String) {
        let theme = PickerOptions.getTheme(for: newTheme)
        store.replaceStoredTheme(to: theme)
    }
    
    public func setTheme(to newTheme: PDTheme) {
        store.replaceStoredTheme(to: newTheme)
    }

    @discardableResult
    public func setSiteIndex(to newIndex: Index) -> Index {
        store.replaceStoredSiteIndex(to: newIndex, siteCount: sites.count)
    }
    
    public func setNotifications(to newValue: Bool) {
        store.replaceStoredNotifications(to: newValue)
    }
    
    public func setNotificationsMinutesBefore(to newMinutes: Int) {
        store.replaceStoredNotificationsMinutesBefore(to: newMinutes)
    }
    
    public func setMentionedDisclaimer(to newValue: Bool) {
        store.replaceStoredMentionedDisclaimer(to: newValue)
    }
    
    public func reset(defaultSiteCount: Int) {
        store.reset(defaultSiteCount: defaultSiteCount)
    }
}