//
//  Settings.swift
//  PatchData
//
//  Created by Juliya Smith on 11/11/19.

import Foundation
import PDKit

public class Settings: SettingsManaging {

    private let writer: UserDefaultsWriting
    private let hormones: HormoneScheduling
    private let sites: SiteScheduling

    /// For Settings logic that requires the use of dependencies, such as the Schedules.
    /// For all other Settings logic that does not require using dependencies, use the Writer class.

    init(
        writer: UserDefaultsWriting,
        hormones: HormoneScheduling,
        sites: SiteScheduling
    ) {
        self.writer = writer
        self.hormones = hormones
        self.sites = sites
    }

    public var deliveryMethod: DeliveryMethodUD { writer.deliveryMethod }
    public var expirationInterval: ExpirationIntervalUD { writer.expirationInterval }
    public var quantity: QuantityUD { writer.quantity }
    public var notifications: NotificationsUD { writer.notifications }
    public var notificationsMinutesBefore: NotificationsMinutesBeforeUD {
        writer.notificationsMinutesBefore
    }
    public var mentionedDisclaimer: MentionedDisclaimerUD { writer.mentionedDisclaimer }
    public var siteIndex: SiteIndexUD { writer.siteIndex }
    public var pillsEnabled: PillsEnabledUD { writer.pillsEnabled }

    public func getSettingAsDisplayableString(for setting: PDSetting) -> String {
        switch setting {
            case .DeliveryMethod: return deliveryMethod.displayableString
            case .ExpirationInterval: return expirationInterval.displayableString
            case .Quantity: return quantity.displayableString
            case .Notifications: return notifications.displayableString
            case .NotificationsMinutesBefore: return notificationsMinutesBefore.displayableString
            case .MentionedDisclaimer: return mentionedDisclaimer.displayableString
            case .SiteIndex: return siteIndex.displayableString
            case .PillsEnabled: return pillsEnabled.displayableString
            case .XDays: return expirationInterval.xDays.rawValue ?? ""
        }
    }

    public func setDeliveryMethod(to newMethod: DeliveryMethod) {
        writer.replaceStoredDeliveryMethod(to: newMethod)
        sites.reset()
        hormones.shareData()
        let defaultQuantity = DefaultQuantities.Hormone[newMethod]
        setQuantity(to: defaultQuantity)
    }

    public func setQuantity(to newQuantity: Int) {
        let endRange = SettingsOptions.quantities.count
        guard newQuantity <= endRange && newQuantity > 0 else { return }
        let oldQuantity = writer.quantity.rawValue
        if newQuantity < oldQuantity {
            hormones.delete(after: newQuantity - 1)
        } else if newQuantity > oldQuantity {
            hormones.fillIn(to: newQuantity)
        }
        writer.replaceStoredQuantity(to: newQuantity)
    }

    public func setExpirationInterval(to newInterval: String) {
        let exp = SettingsOptions.getExpirationInterval(for: newInterval)
        writer.replaceStoredExpirationInterval(to: exp)
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

    public func setPillsEnabled(to newValue: Bool) {
        writer.replaceStoredPillsEnabled(to: newValue)
    }

    public func reset(defaultSiteCount: Int) {
        writer.reset(defaultSiteCount: defaultSiteCount)
    }
}
