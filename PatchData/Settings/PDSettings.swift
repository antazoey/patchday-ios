//
//  PDDefaults.swift
//  PatchData
//
//  Created by Juliya Smith on 11/11/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class PDSettings: PDSettingsManaging {

    private let writer: UserDefaultsWriting
    private var state: PDState
    private let hormones: HormoneScheduling
    private let sites: SiteScheduling

    init(
        writer: UserDefaultsWriting,
        state: PDState,
        hormones: HormoneScheduling,
        sites: SiteScheduling
    ) {
        self.writer = writer
        self.state = state
        self.hormones = hormones
        self.sites = sites
    }

    public var deliveryMethod: DeliveryMethodUD { writer.deliveryMethod }
    public var expirationInterval: ExpirationIntervalUD { writer.expirationInterval }
    public var quantity: QuantityUD { writer.quantity }
    public var notifications: NotificationsUD { writer.notifications }
    public var notificationsMinutesBefore: NotificationsMinutesBeforeUD { writer.notificationsMinutesBefore }
    public var mentionedDisclaimer: MentionedDisclaimerUD { writer.mentionedDisclaimer }
    public var siteIndex: SiteIndexUD { writer.siteIndex }
    public var theme: PDThemeUD { writer.theme }

    public func setDeliveryMethod(to newMethod: DeliveryMethod) {
        writer.replaceStoredDeliveryMethod(to: newMethod)
        writer.incrementStoredSiteIndex()
        hormones.shareData()
        state.theDeliveryMethodHasMutated = true
    }

    public func setQuantity(to newQuantity: Int) {
        let endRange = PickerOptions.quantities.count + 1
        if newQuantity < endRange && newQuantity > 0 {
            let oldQuantity = writer.quantity.rawValue
            if newQuantity < oldQuantity {
                hormones.delete(after: newQuantity - 1)
                state.theQuantityHasDecreased = true
                state.theQuantityHasIncreased = false
            } else if newQuantity > oldQuantity {
                state.theQuantityHasIncreased = true
                state.theQuantityHasDecreased = false
                hormones.fillIn(to: newQuantity)
            }
            writer.replaceStoredQuantity(to: newQuantity)
        }
    }

    public func setExpirationInterval(to newInterval: String) {
        let exp = PickerOptions.getExpirationInterval(for: newInterval)
        writer.replaceStoredExpirationInterval(to: exp)
    }

    public func setTheme(to newTheme: String) {
        let theme = PickerOptions.getTheme(for: newTheme)
        writer.replaceStoredTheme(to: theme)
    }
    
    public func setTheme(to newTheme: PDTheme) {
        writer.replaceStoredTheme(to: newTheme)
    }

    @discardableResult
    public func setSiteIndex(to newIndex: Index) -> Index {
        writer.replaceStoredSiteIndex(to: newIndex)
    }
    
    public func setNotifications(to newValue: Bool) {
        writer.replaceStoredNotifications(to: newValue)
    }
    
    public func setNotificationsMinutesBefore(to newMinutes: Int) {
        writer.replaceStoredNotificationsMinutesBefore(to: newMinutes)
    }
    
    public func setMentionedDisclaimer(to newValue: Bool) {
        writer.replaceStoredMentionedDisclaimer(to: newValue)
    }
    
    public func reset(defaultSiteCount: Int) {
        writer.reset(defaultSiteCount: defaultSiteCount)
    }
}
