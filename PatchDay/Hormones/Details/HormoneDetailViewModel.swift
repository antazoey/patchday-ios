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

    private var expirationIntervalHours: Int{
        sdk?.defaults.expirationInterval.hours ?? DefaultExpirationIntervalHours
    }

    var hormone: Hormonal
    var selectionState = HormoneSelectionState()
    let handleNewSite: () -> ()

    init(_ hormone: Hormonal, _ newSiteHandler: @escaping () -> ()) {
        self.hormone = hormone
        self.handleNewSite = newSiteHandler
        super.init()
    }

    var dateSelected: Date {
        get { selectionState.selectedDate ?? hormone.date }
        set { selectionState.selectedDate = newValue }
    }

    var dateSelectedText: String {
        DateHelper.format(date: dateSelected, useWords: true)
    }

    var selectDateButtonStartText: String {
        if !hormone.hasDate {
            return ActionStrings.select
        }

        return DateHelper.format(date: hormone.date, useWords: true)
    }

    var selectSiteTextFieldStartText: String {
        if !hormone.hasSite {
            return ActionStrings.select
        }

        if let siteName = getSite()?.name {
            return siteName
        }

        return SiteStrings.newSite
    }

    var expirationDateText: String {
        createExpirationDateString(from: dateSelected)
    }

    var hormoneIndex: Index {
        sdk?.hormones.firstIndexOf(hormone) ?? -1
    }

    var siteIndexStartRow: Index {
        if selectionState.selectedSiteIndex > -1 {
            return selectionState.selectedSiteIndex
        } else if let site = getSite() {
            let order = site.order
            let end = sitesCount
            if order >= 1 && order <= end {
                selectionState.selectedSite = site
                return order
            }
        }
        return 0
    }

    var sitesCount: Int {
        sdk?.sites.count ?? 0
    }

    var autoPickedDateText: String {
        let date = Date()
        selectionState.selectedDate = date
        return DateHelper.format(date: date, useWords: true)
    }
    
    var autoPickedExpirationDateText: String {
        createExpirationDateString(from: Date())
    }

    func createHormoneViewStrings() -> HormoneViewStrings {
        let method = sdk?.defaults.deliveryMethod.value ?? DefaultDeliveryMethod
        return ColonStrings.createHormoneViewStrings(deliveryMethod: method, hormone: hormone)
    }

    @discardableResult func trySelectSite(at row: Index) -> String? {
        if let site = sdk?.sites.at(row) {
            selectionState.selectedSite = site
            return site.name
        }
        return nil
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
        if siteTextField.text == nil || siteTextField.text == "" {
            siteTextField.text = SiteStrings.newSite
        }
        return siteTextField.text!
    }

    func presentNewSiteAlert(source: HormoneDetailViewController, newSiteName: String) {
        alerts?.presentNewSiteAlert(with: newSiteName, at: selectionState.selectedSiteIndex, hormoneDetailVC: source)
    }

    private func createInitialExpirationState(from hormone: Hormonal) -> HormoneExpirationState {
        HormoneExpirationState(
            wasExpiredBeforeSave: hormone.isExpired, wasPastAlertTimeAfterSave: hormone.isPastNotificationTime
        )
    }

    private func trySave() {
        if let sdk = sdk {
            trySaveDate(sdk.hormones, selectionState.selectedDate, doSave: false)
            trySaveSite(sdk.hormones, selectionState.selectedSite)
        } else {
            log.error("Save failed - PatchData SDK is nil")
        }
    }

    private func trySaveDate(_ hormones: HormoneScheduling, _ selectedDate: Date?, doSave: Bool=true) {
        if let date = selectedDate {
            hormones.setDate(for: &hormone, with: date, doSave: doSave)
        } else {
            log.info("Tried saving date but none was selected")
        }
    }

    private func trySaveSite(_ hormones: HormoneScheduling, _ selectedSite: Bodily?, doSave: Bool=true) {
        if let site = selectedSite {
            hormones.setSite(for: &hormone, with: site, doSave: doSave)
        } else {
            log.info("Tried saving site but none was selected")
        }
    }

    private func handleExpirationState(state: HormoneExpirationState) {
        reflectExpirationInAppBadge(state: state)
    }

    private func reflectExpirationInAppBadge(state: HormoneExpirationState) {
        if !state.isExpiredAfterSave && (badge?.hasValue ?? false) {
            badge?.decrement()
        } else if !state.wasExpiredBeforeSave && state.isExpiredAfterSave {
            badge?.increment()
        }
    }

    private func handleExpirationStateInNotifications(state: HormoneExpirationState) {
        if !state.wasPastAlertTimeAfterSave {
            notifications?.cancelExpiredHormoneNotification(for: hormone)
        }
    }

    private func requestNewNotifications() {
        if let notifications = notifications {
            notifications.requestExpiredHormoneNotification(for: hormone)
            if hormone.expiresOvernight {
                notifications.requestOvernightExpirationNotification(for: hormone)
            }
        }
    }

    private func createExpirationDateString(from startDate: Date) -> String {
        if let expDate = DateHelper.calculateExpirationDate(from: startDate, expirationIntervalHours) {
            return DateHelper.format(date: expDate, useWords: true)
        }
        return ""
    }

    private func getSite() -> Bodily? {
        if let id = hormone.siteId {
            return sdk?.sites.get(by: id)
        }
        return nil
    }
}
