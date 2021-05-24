//
//  HormoneDetailViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/26/19.

import Foundation
import PDKit

enum TextFieldButtonSenderType: String {
    case PickerActivator = "pick"
    case DefaultTextFieldEditor = "type"
}

class HormoneDetailViewModel: CodeBehindDependencies<HormoneDetailViewModel>, HormoneDetailViewModelProtocol {

    private var alertFactory: AlertProducing?
    private let now: NowProtocol
    var hormoneId: UUID?  // Determined after PatchData SDK available
    lazy var selections = HormoneSelectionState()
    let handleInterfaceUpdatesFromNewSite: () -> Void

    init(
        _ hormoneIndex: Index,
        _ newSiteHandler: @escaping () -> Void,
        _ alertFactory: AlertProducing,
        _ dependencies: DependenciesProtocol,
        _ now: NowProtocol?=nil
    ) {
        self.handleInterfaceUpdatesFromNewSite = newSiteHandler
        self.alertFactory = alertFactory
        self.now = now ?? PDNow()
        super.init(
            sdk: dependencies.sdk,
            tabs: dependencies.tabs,
            notifications: dependencies.notifications,
            alerts: dependencies.alerts,
            nav: dependencies.nav,
            badge: dependencies.badge,
            widget: dependencies.widget
        )
    }

    init(_ hormoneIndex: Index, _ newSiteHandler: @escaping () -> Void) {
        self.handleInterfaceUpdatesFromNewSite = newSiteHandler
        self.now = PDNow()
        super.init()
        if let sdk = self.sdk, self.alertFactory == nil {
            self.alertFactory = AlertFactory(sdk: sdk, tabs: self.tabs)
            self.hormoneId = sdk.hormones[hormoneIndex]?.id
        }
    }

    var hormone: Hormonal? {
        guard let id = hormoneId else { return nil }
        return sdk?.hormones[id]
    }

    /// Returns the date selected from the UI. If no date has been selected, returns the hormones date.
    /// If the hormone does not have a valid date, returns the current date.
    var dateSelected: Date? {
        get {
            if let selected = selections.date {
                return selected
            }
            let date = hormone?.date
            return date?.isDefault() ?? true ? nil : date
        }
        set { selections.date = newValue }
    }

    var dateSelectedText: String {
        guard let date = dateSelected else { return PlaceholderStrings.DotDotDot }
        return PDDateFormatter.formatDate(date)
    }

    var datePickerDate: Date {
        dateSelected ?? Date()
    }

    var selectSiteStartText: String {
        guard let hormone = hormone else { return ActionStrings.Select }
        if hormone.hasSite {
            return hormone.siteName.isEmpty ? SiteStrings.NewSite : hormone.siteName
        }
        return ActionStrings.Select
    }

    var expirationDateText: String {
        guard let hormone = hormone else { return PlaceholderStrings.DotDotDot }
        let expirationInterval = hormone.expirationInterval
        guard let dateSelected = dateSelected else { return PlaceholderStrings.DotDotDot }
        if let expiration = DateFactory.createExpirationDate(
            expirationInterval: expirationInterval, to: dateSelected
        ) {
            return HormoneStrings.getExpirationDateText(expiration: expiration)
        }
        return PlaceholderStrings.DotDotDot
    }

    var siteStartRow: Index {
        guard selections.siteIndex < 0 else { return selections.siteIndex }
        guard let site = getSite() else { return 0 }
        let order = site.order
        let end = siteCount
        if 0..<end ~= order {
            selections.site = site
            return order
        }
        return 0
    }

    var siteCount: Int {
        sdk?.sites.count ?? 0
    }

    var autoPickedDate: Date {
        let date = ChangeHormoneCommand.createAutoDate(
            hormone: hormone, useStaticTime: useStaticExpirationTime, now: now
        )
        selections.date = date
        return date
    }

    var autoPickedExpirationDateText: String {
        if let hormone = hormone, let date = hormone.createExpirationDate(from: Date()) {
            return PDDateFormatter.formatDay(date)
        }
        return PlaceholderStrings.DotDotDot
    }

    func handleIfUnsaved(_ viewController: UIViewController) {
        let save: () -> Void = {
            self.saveSelections()
            self.nav?.pop(source: viewController)
        }
        let discard: () -> Void = {
            self.selections.date = nil
            self.selections.site = nil
            self.nav?.pop(source: viewController)
        }
        if selections.hasSelections {
            self.alerts?.createUnsavedAlert(
                viewController,
                saveAndContinueHandler: save,
                discardHandler: discard
            ).present()
        } else {
            self.nav?.pop(source: viewController)
        }
    }

    func selectSuggestedSite() -> String {
        guard let nextSite = sdk?.sites.suggested else { return SiteStrings.NewSite }
        let name = nextSite.name
        selections.site = nextSite
        return !name.isEmpty ? name : SiteStrings.NewSite
    }

    func getSiteName(at row: Index) -> SiteName? {
        guard let name = sdk?.sites.names.tryGet(at: row) else { return nil }
        return !name.isEmpty ? name : SiteStrings.NewSite
    }

    func createHormoneViewStrings() -> HormoneViewStrings? {
        guard let hormone = hormone else { return nil }
        return HormoneStrings.create(hormone)
    }

    @discardableResult func trySelectSite(at row: Index) -> String? {
        guard let site = sdk?.sites[row] else { return nil }
        selections.site = site
        // If is a new hormone and has no date did not set one, set automatically to now.
        if let hormone = hormone, selections.date == nil && hormone.date.isDefault() {
            selections.date = Date()
        }
        return site.name
    }

    func saveSelections() {
        trySaveSite()
        trySaveDate()
        tabs?.reflectHormones()
        badge?.reflect()
        requestNewNotifications()
        selections = HormoneSelectionState()
    }

    func extractSiteNameFromTextField(_ siteTextField: UITextField) -> String {
        siteTextField.text ?? ""
    }

    func presentNewSiteAlert(newSiteName: String) {
        guard newSiteName.count > 0 else { return }
        guard let alertFactory = alertFactory else { return }
        let handlers = NewSiteAlertActionHandler {
            let newSite = self.sdk?.sites.insertNew(name: newSiteName) {
                self.handleInterfaceUpdatesFromNewSite()
            }
            self.selections.site = newSite ?? self.selections.site
        }
        let alert = alertFactory.createNewSiteAlert(handlers)
        alert.present()

        // For when user sets with text and not site
        if self.selections.site == nil {
            self.selections.siteName = newSiteName
        }
    }

    private func trySaveDate() {
        guard let sdk = sdk else { return }
        guard let hormone = hormone else { return }
        guard let date = selections.date else { return }
        sdk.hormones.setDate(by: hormone.id, with: date)
        badge?.reflect()
    }

    private func trySaveSite() {
        guard let sdk = sdk else { return }
        guard let hormone = hormone else { return }
        if let site = selections.site {
            sdk.hormones.setSite(by: hormone.id, with: site)
        } else if let siteName = selections.siteName {
            sdk.hormones.setSiteName(by: hormone.id, with: siteName)
        }
    }

    private func requestNewNotifications() {
        guard let hormone = hormone, let notifications = notifications else { return }
        notifications.requestExpiredHormoneNotification(for: hormone)
        if hormone.expiresOvernight {
            notifications.requestOvernightExpirationNotification(for: hormone)
        }
    }

    private func getSite() -> Bodily? {
        guard let hormone = hormone, let id = hormone.siteId else { return nil }
        return sdk?.sites[id]
    }

    private var useStaticExpirationTime: Bool {
        sdk?.hormones.useStaticExpirationTime ?? DefaultSettings.USE_STATIC_EXPIRATION_TIME
    }
}
