//
//  HormoneDetailViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/26/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


enum TextFieldButtonSenderType: String {
    case PickerActivator = "pick"
    case DefaultTextFieldEditor = "type"
}


class HormoneDetailViewModel: CodeBehindDependencies<HormoneDetailViewModel> {

    private var expirationIntervalHours: Int {
        guard let hours = sdk?.settings.expirationInterval.hours else { return DefaultSettings.ExpirationIntervalHours }
        return hours
    }

    var hormone: Hormonal
    var selectionState = HormoneSelectionState()
    let handleInterfaceUpdatesFromNewSite: () -> ()

    init(_ hormone: Hormonal, _ newSiteHandler: @escaping () -> ()) {
        self.hormone = hormone
        self.handleInterfaceUpdatesFromNewSite = newSiteHandler
        super.init()
    }

    var dateSelected: Date {
        get { selectionState.selectedDate ?? hormone.date }
        set { selectionState.selectedDate = newValue }
    }

    var dateSelectedText: String {
        PDDateFormatter.formatDate(dateSelected)
    }

    var selectDateButtonStartText: String {
        if !hormone.hasDate {
            return ActionStrings.Select
        }
        return PDDateFormatter.formatDate(hormone.date)
    }

    var selectSiteTextFieldStartText: String {
        if !hormone.hasSite {
            return ActionStrings.Select
        }
        if let siteName = getSite()?.name {
            return siteName
        }
        return SiteStrings.NewSite
    }

    var expirationDateText: String {
        createExpirationDateString(from: dateSelected)
    }

    var hormoneIndex: Index {
        sdk?.hormones.indexOf(hormone) ?? -1
    }

    var siteIndexStartRow: Index {
        guard selectionState.selectedSiteIndex >= 0 else {
            guard let site = getSite() else { return 0 }
            let order = site.order
            let end = sitesCount
            if order >= 1 && order <= end {
                selectionState.selectedSite = site
                return order
            }
            return 0
        }
        return selectionState.selectedSiteIndex
    }

    var sitesCount: Int {
        sdk?.sites.count ?? 0
    }

    var autoPickedDateText: String {
        let date = Date()
        selectionState.selectedDate = date
        return PDDateFormatter.formatDate(date)
    }
    
    var autoPickedExpirationDateText: String {
        createExpirationDateString(from: Date())
    }

    func createHormoneViewStrings() -> HormoneViewStrings {
        guard let method = sdk?.settings.deliveryMethod.value else {
            return createHormoneViewStrings(method: DefaultSettings.DeliveryMethodValue)
        }
        return ColonStrings.createHormoneViewStrings(deliveryMethod: method, hormone: hormone)
    }
    
    func createHormoneViewStrings(method: DeliveryMethod) -> HormoneViewStrings {
        ColonStrings.createHormoneViewStrings(deliveryMethod: method, hormone: hormone)
    }

    @discardableResult func trySelectSite(at row: Index) -> String? {
        guard let site = sdk?.sites.at(row) else { return nil }
        selectionState.selectedSite = site
        return site.name
    }

    func saveFromSelectionState() {
        var expState = createInitialExpirationState(from: hormone)
        trySave()
        expState.isExpiredAfterSave = hormone.isExpired
        handleExpirationState(state: expState)
        handleExpirationStateInNotifications(state: expState)
        requestNewNotifications()
        tabs?.reflectHormoneCharacteristics()
    }

    func extractSiteNameFromTextField(_ siteTextField: UITextField) -> String {
        guard let text = siteTextField.text else { return SiteStrings.NewSite }
        return text != "" ? text : SiteStrings.NewSite
    }

    func presentNewSiteAlert(newSiteName: String) {
        guard let alerts = alerts else { return }
        let handlers = NewSiteAlertActionHandler() {
            self.sdk?.sites.insertNew(name: newSiteName, save: true) {
                self.handleInterfaceUpdatesFromNewSite()
            }
        }
        alerts.presentNewSiteAlert(handlers: handlers)
    }

    private func createInitialExpirationState(from hormone: Hormonal) -> HormoneExpirationState {
        HormoneExpirationState(
            wasExpiredBeforeSave: hormone.isExpired, wasPastAlertTimeAfterSave: hormone.isPastNotificationTime
        )
    }

    private func trySave() {
        if let sdk = sdk {
            trySaveDate(sdk.hormones, selectionState.selectedDate, doSave: false)
            trySaveSite(sdk.hormones, selectionState.selectedSite, doSave: true)
            return
        }
        log.error("Save failed - PatchData SDK is nil")
    }

    private func trySaveDate(_ hormones: HormoneScheduling, _ selectedDate: Date?, doSave: Bool=true) {
        if let date = selectedDate {
            hormones.setDate(by: hormone.id, with: date, doSave: doSave)
            return
        }
        log.info("There are no changes to the \(PDEntity.hormone) date")
    }

    private func trySaveSite(_ hormones: HormoneScheduling, _ selectedSite: Bodily?, doSave: Bool=true) {
        if let site = selectedSite {
            let isSuggested = site.id == sdk?.sites.suggested?.id
            hormones.setSite(by: hormone.id, with: site, bumpSiteIndex: isSuggested, doSave: doSave)
            return
        }
        log.info("There are no changes to the \(PDEntity.hormone) \(PDEntity.site)")
    }

    private func handleExpirationState(state: HormoneExpirationState) {
        reflectExpirationInAppBadge(state: state)
    }

    private func reflectExpirationInAppBadge(state: HormoneExpirationState) {
        if !state.isExpiredAfterSave {
            badge?.decrement()
        } else if !state.wasExpiredBeforeSave && state.isExpiredAfterSave {
            // ^ Don't increment if already incremented (already was expired)
            badge?.increment()
        }
    }

    private func handleExpirationStateInNotifications(state: HormoneExpirationState) {
        guard !state.wasPastAlertTimeAfterSave else { return }
        notifications?.cancelExpiredHormoneNotification(for: hormone)
    }

    private func requestNewNotifications() {
        guard let notifications = notifications else { return }
        notifications.requestExpiredHormoneNotification(for: hormone)
        if hormone.expiresOvernight {
            notifications.requestOvernightExpirationNotification(for: hormone)
        }
    }

    private func createExpirationDateString(from startDate: Date) -> String {
        let hours = expirationIntervalHours
        guard let expDate = DateFactory.createDate(byAddingHours: hours, to: startDate) else { return "" }
        return PDDateFormatter.formatDate(expDate)
    }

    private func getSite() -> Bodily? {
        guard let id = hormone.siteId else { return nil }
        return sdk?.sites.get(by: id)
    }
}
