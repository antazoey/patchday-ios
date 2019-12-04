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

class HormoneDetailViewModel: CodeBehindDependencies {

    private var expirationIntervalHours: Int{
        sdk?.defaults.expirationInterval.hours ?? DefaultExpirationIntervalHours
    }

    var hormone: Hormonal
    var selectionState = HormoneSelectionState()

    static let viewControllerId = "HormoneDetailVC_id"

    init(_ hormone: Hormonal) {
        self.hormone = hormone
    }

    var dateSelected: Date {
        get {
            selectionState.selectedDate ?? hormone.date
        }
        set {
            selectionState.selectedDate = newValue
        }
    }

    var dateSelectedText: String {
        DateHelper.format(date: dateSelected, useWords: true)
    }

    var selectSiteTextFieldStartText: String {
        hormone.isCerebral ? ActionStrings.select : hormone.siteName
    }

    var expirationDateText: String {
        createExpirationDateString(from: dateSelected)
    }

    var hormoneIndex: Index {
        sdk?.hormones.indexOf(hormone) ?? -1
    }

    var siteIndexStartRow: Index {
        if selectionState.siteIndexSelected > -1 {
            return selectionState.siteIndexSelected
        } else if let site = hormone.site {
            let order = site.order
            let end = sitesCount
            if order >= 1 && order <= end {
                selectionState.siteIndexSelected = order
                return order
            }
        }
        return 0
    }

    var sitesCount: Int {
        sdk?.sites.count ?? 0
    }

    var autoPickedDateText: String {
        DateHelper.format(date: Date(), useWords: true)
    }
    
    var autoPickedExpirationDateText: String {
        createExpirationDateString(from: Date())
    }

    func createHormoneViewStrings() -> HormoneViewStrings {
        let method = sdk?.defaults.deliveryMethod.value ?? DefaultDeliveryMethod
        return ColonedStrings.createHormoneViewStrings(deliveryMethod: method, hormone: hormone)
    }

    func selectSite(at row: Index) -> String {
        if let name = sdk?.sites.names.tryGet(at: row) {
            selectionState.siteIndexSelected = row
            return name
        }
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

    func presentNewSiteAlert(source: HormoneDetailVC, newSiteName: String) {
        alerts?.presentNewSiteAlert(with: newSiteName, at: selectionState.siteIndexSelected, hormoneVC: source)
    }

    private func createInitialExpirationState(from hormone: Hormonal) -> HormoneExpirationState {
        HormoneExpirationState(
            wasExpiredBeforeSave: hormone.isExpired, wasPastAlertTimeAfterSave: hormone.isPastNotificationTime
        )
    }

    private func trySave() {
        if let sdk = sdk {
            trySaveDate(sdk.hormones, selectionState.selectedDate)
            trySaveSite(sdk.hormones, selectionState.selectedSite)
        }
    }

    private func trySaveDate(_ hormones: HormoneScheduling, _ selectedDate: Date?) {
        if let date = selectedDate {
            hormones.setDate(for: &hormone, with: date)
        }
    }

    private func trySaveSite(_ hormones: HormoneScheduling, _ selectedSite: Bodily?) {
        if let site = selectedSite {
            hormones.setSite(for: &hormone, with: site)
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
}