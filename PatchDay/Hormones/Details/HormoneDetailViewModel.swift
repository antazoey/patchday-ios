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

	var hormone: Hormonal
	var selections = HormoneSelectionState()
	let handleInterfaceUpdatesFromNewSite: () -> Void
	
	init(
		_ hormone: Hormonal,
		_ newSiteHandler: @escaping () -> Void,
		_ dependencies: DependenciesProtocol
	) {
		self.hormone = hormone
		self.handleInterfaceUpdatesFromNewSite = newSiteHandler
		super.init(
			sdk: dependencies.sdk,
			tabs: dependencies.tabs,
			notifications: dependencies.notifications,
			alerts: dependencies.alerts,
			nav: dependencies.nav,
			badge: dependencies.badge
		)
	}

	init(_ hormone: Hormonal, _ newSiteHandler: @escaping () -> Void) {
		self.hormone = hormone
		self.handleInterfaceUpdatesFromNewSite = newSiteHandler
		super.init()
	}

	/// Returns the date selected from the UI. If no date has been selected, returns the hormones date. If the hormone does not
	/// have a valid date, returns the current date.
	var dateSelected: Date? {
		get {
			if let selected = selections.date {
				return selected
			}
			let date = hormone.date
			return date.isDefault() ? nil : date
		}
		set { selections.date = newValue }
	}

	var dateSelectedText: String {
		guard let date = dateSelected else { return DotDotDot }
		return PDDateFormatter.formatDate(date)
	}
	
	var datePickerDate: Date {
		dateSelected ?? Date()
	}

	var selectDateButtonStartText: String {
		guard hormone.hasDate else { return ActionStrings.Select }
		return PDDateFormatter.formatDate(hormone.date)
	}

	var selectSiteTextFieldStartText: String {
		guard hormone.hasSite else { return ActionStrings.Select }
		return hormone.siteName ?? SiteStrings.NewSite
	}

	var expirationDateText: String {
		let expInt = hormone.expirationInterval
		guard let date = dateSelected else { return DotDotDot }
		if let expDate = DateFactory.createExpirationDate(expirationInterval: expInt, to: date) {
			return PDDateFormatter.formatDay(expDate)
		}
		return DotDotDot
	}

	var hormoneIndex: Index {
		sdk?.hormones.indexOf(hormone) ?? -1
	}

	var siteIndexStartRow: Index {
		guard selections.siteIndex < 0 else { return selections.siteIndex }
		guard let site = getSite() else { return 0 }
		let order = site.order
		let end = sitesCount
		if order >= 1 && order <= end {
			selections.site = site
			return order
		}
		return 0
	}

	var sitesCount: Int {
		sdk?.sites.count ?? 0
	}

	var autoPickedDateText: String {
		let date = Date()
		selections.date = date
		return PDDateFormatter.formatDate(date)
	}

	var autoPickedExpirationDateText: String {
		if let date = hormone.createExpirationDate(from: Date()) {
			return PDDateFormatter.formatDay(date)
		}
		return DotDotDot
	}

	func getSiteName(at row: Index) -> SiteName {
		var siteName = sdk?.sites.names.tryGet(at: row)
		if siteName == "" {
			siteName = SiteStrings.NewSite
		}
		return siteName ?? SiteStrings.NewSite
	}

	func createHormoneViewStrings() -> HormoneViewStrings {
		HormoneStrings.create(hormone)
	}

	@discardableResult func trySelectSite(at row: Index) -> String? {
		guard let site = sdk?.sites[row] else { return nil }
		selections.site = site
		return site.name
	}

	func saveFromSelectionState() {
		var expState = createInitialExpirationState(from: hormone)
		trySave()
		expState.isExpiredAfterSave = hormone.isExpired
		reflectExpirationInAppBadge(expState)
		handleExpirationStateInNotifications(expState)
		requestNewNotifications()
		tabs?.reflectHormoneCharacteristics()
	}

	func extractSiteNameFromTextField(_ siteTextField: UITextField) -> String {
		guard let text = siteTextField.text else { return SiteStrings.NewSite }
		return text != "" ? text : SiteStrings.NewSite
	}

	func presentNewSiteAlert(newSiteName: String) {
		guard let alerts = alerts else { return }
		let handlers = NewSiteAlertActionHandler {
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
		guard let sdk = sdk else { return }
		trySaveDate(sdk.hormones, selections.date)
		trySaveSite(sdk.hormones, selections.site)
	}

	private func trySaveDate(_ hormones: HormoneScheduling, _ selectedDate: Date?) {
		guard let date = selectedDate else {
			log.info("There are no changes to the \(PDEntity.hormone) date")
			return
		}
		hormones.setDate(by: hormone.id, with: date)
	}

	private func trySaveSite(_ hormones: HormoneScheduling, _ selectedSite: Bodily?) {
		guard let site = selectedSite else {
			log.info("There are no changes to the \(PDEntity.hormone) \(PDEntity.site)")
			return
		}
		let isSuggested = site.id == sdk?.sites.suggested?.id
		hormones.setSite(by: hormone.id, with: site, incrementSiteIndex: isSuggested)
	}

	private func reflectExpirationInAppBadge(_ state: HormoneExpirationState) {
		if !state.isExpiredAfterSave {
			badge?.decrement()
		} else if !state.wasExpiredBeforeSave && state.isExpiredAfterSave {
			// ^ Don't increment if already incremented (already was expired)
			badge?.increment()
		}
	}

	private func handleExpirationStateInNotifications(_ state: HormoneExpirationState) {
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

	private func getSite() -> Bodily? {
		guard let id = hormone.siteId else { return nil }
		return sdk?.sites[id]
	}
}
