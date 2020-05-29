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

	var index: Index
	var hormone: Hormonal? {
		sdk?.hormones[self.index]
	}
	var selections = HormoneSelectionState()
	let handleInterfaceUpdatesFromNewSite: () -> Void

	init(
		_ hormoneIndex: Index,
		_ newSiteHandler: @escaping () -> Void,
		_ dependencies: DependenciesProtocol
	) {
		self.index = hormoneIndex
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

	init(_ hormoneIndex: Index, _ newSiteHandler: @escaping () -> Void) {
		self.index = hormoneIndex
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
			let date = hormone?.date
			return date?.isDefault() ?? true ? nil : date
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
		guard let hormone = hormone, hormone.hasDate else { return ActionStrings.Select }
		return PDDateFormatter.formatDate(hormone.date)
	}

	var selectSiteTextFieldStartText: String {
		guard let hormone = hormone else { return ActionStrings.Select }
		return hormone.hasSite ? hormone.siteName : ActionStrings.Select
	}

	var expirationDateText: String {
		guard let hormone = hormone else { return DotDotDot }
		let expInt = hormone.expirationInterval
		guard let date = dateSelected else { return DotDotDot }
		if let expDate = DateFactory.createExpirationDate(expirationInterval: expInt, to: date) {
			return PDDateFormatter.formatDay(expDate)
		}
		return DotDotDot
	}

	var siteStartRow: Index {
		guard selections.siteIndex < 0 else { return selections.siteIndex }
		guard let site = getSite() else { return 0 }
		let order = site.order
		let end = siteCount
		if order >= 1 && order <= end {
			selections.site = site
			return order
		}
		return 0
	}

	var siteCount: Int {
		sdk?.sites.count ?? 0
	}

	var autoPickedDateText: String {
		let date = Date()
		selections.date = date
		return PDDateFormatter.formatDate(date)
	}

	var autoPickedExpirationDateText: String {
		if let hormone = hormone, let date = hormone.createExpirationDate(from: Date()) {
			return PDDateFormatter.formatDay(date)
		}
		return DotDotDot
	}

	func getSiteName(at row: Index) -> SiteName? {
		guard let name = sdk?.sites.names.tryGet(at: row) else { return nil }
		return name != "" ? name : SiteStrings.NewSite
	}

	func createHormoneViewStrings() -> HormoneViewStrings? {
		guard let hormone = hormone else { return nil }
		return HormoneStrings.create(hormone)
	}

	@discardableResult func trySelectSite(at row: Index) -> String? {
		guard let site = sdk?.sites[row] else { return nil }
		selections.site = site
		return site.name
	}

	func saveSelections() {
		trySave()
		tabs?.reflectHormoneCharacteristics()
		badge?.reflect()
		requestNewNotifications()
	}

	func extractSiteNameFromTextField(_ siteTextField: UITextField) -> String {
		guard let text = siteTextField.text else { return SiteStrings.NewSite }
		return text != "" ? text : SiteStrings.NewSite
	}

	func presentNewSiteAlert(newSiteName: String) {
		guard let alerts = alerts else { return }
		let handlers = NewSiteAlertActionHandler {
			let newSite = self.sdk?.sites.insertNew(name: newSiteName, save: true) {
				self.handleInterfaceUpdatesFromNewSite()
			}
			self.selections.site = newSite ?? self.selections.site
		}
		alerts.presentNewSiteAlert(handlers: handlers)
	}

	private func trySave() {
		trySaveDate()
		trySaveSite()
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
		guard let site = selections.site else { return }
		let isSuggested = site.id == sdk.sites.suggested?.id
		sdk.hormones.setSite(
			by: hormone.id, with: site, incrementSiteIndex: isSuggested
		)
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
}
