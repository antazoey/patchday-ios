//
//  HormonesViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class HormonesViewModel: CodeBehindDependencies<HormonesViewModel> {

	private let style: UIUserInterfaceStyle
	let table: HormonesTable
	var hormones: HormoneScheduling? { sdk?.hormones }

	private lazy var histories: [SiteImageHistory] = [
		SiteImageHistory(0),
		SiteImageHistory(1),
		SiteImageHistory(2),
		SiteImageHistory(3)
	]

	init(hormonesTableView: UITableView, style: UIUserInterfaceStyle) {
		self.style = style
		self.table = HormonesTable(hormonesTableView)
		super.init()
		initTable(style: style)
	}

	var mainViewControllerTitle: String {
		guard let method = sdk?.settings.deliveryMethod.value else {
			return PDTitleStrings.HormonesTitle
		}
		return PDTitleStrings.Hormones[method]
	}

	var expiredHormoneBadgeValue: String? {
		guard let numExpired = hormones?.totalExpired, numExpired > 0 else { return nil }
		return "\(numExpired)"
	}

	func updateSiteImages() {
		var i = 0
		table.reflectModel(self.sdk, style)
		do {
			try table.cells.forEach {
				cell in
				let history = histories[i]
				history.push(getSiteImage(at: i))
				try cell.reflectSiteImage(history)
				i += 1
			}
		} catch {
			let log = PDLog<HormonesViewModel>()
			log.error("Unable to update site image at row \(i)")
		}
	}

	private func getSiteImage(at row: Index) -> UIImage? {
		guard let sdk = sdk else { return nil }
		let quantity = sdk.settings.quantity.rawValue
		guard row < quantity && row >= 0 else { return nil }
		let hormone = sdk.hormones[row]
		let siteImageDeterminationParams = SiteImageDeterminationParameters(hormone: hormone)
		return SiteImages[siteImageDeterminationParams]
	}

	func handleRowTapped(at index: Index, _ hormonesViewController: UIViewController) {
		goToHormoneDetails(hormoneIndex: index, hormonesViewController)
	}

	func presentDisclaimerAlertIfFirstLaunch() {
		guard isFirstLaunch else { return }
		alerts?.presentDisclaimerAlert()
		sdk?.settings.setMentionedDisclaimer(to: true)
	}

	subscript(row: Index) -> UITableViewCell {
		table.cells.tryGet(at: row) ?? HormoneCell()
	}

	func goToHormoneDetails(hormoneIndex: Index, _ hormonesViewController: UIViewController) {
		nav?.goToHormoneDetails(hormoneIndex, source: hormonesViewController)
	}

	func loadAppTabs(source: UIViewController) {
		guard let navigationController = source.navigationController else { return }
		guard let tabs = navigationController.tabBarController else { return }
		let vcs = navigationController.viewControllers
		setTabs(tabBarController: tabs, appViewControllers: vcs)
	}

	private func initTable(style: UIUserInterfaceStyle) {
		reflectTableModel()
		updateSiteImages()  // Animating images has to happen after `cell.configure()`
	}

	private func reflectTableModel() {
		table.reflectModel(sdk, style)
	}

	private var isFirstLaunch: Bool {
		guard let sdk = sdk else { return false }
		return !sdk.settings.mentionedDisclaimer.value
	}

	private func setTabs(tabBarController: UITabBarController, appViewControllers: [UIViewController]) {
		tabs = TabReflector(
			tabBarController: tabBarController, viewControllers: appViewControllers, sdk: sdk
		)
		AppDelegate.current?.tabs = tabs
		self.tabs = tabs
	}
}
