//
//  SitesViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/13/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SitesViewModel: CodeBehindDependencies<SitesViewModel> {

	let table: SitesTable

	init(sitesTableView: UITableView) {
		self.table = SitesTable(sitesTableView)
		super.init()
		self.table.sites = sdk?.sites
	}

	var sites: SiteScheduling? {
		sdk?.sites
	}

	var sitesCount: Int {
		sdk?.sites.count ?? 0
	}

	var sitesOptionsCount: Int {
		sdk?.sites.names.count ?? 0
	}

	func createSiteCellSwipeActions(indexPath: IndexPath) -> UISwipeActionsConfiguration {
		let delete = SiteViewFactory.createDeleteRowTableAction(
			indexPath: indexPath, delete: deleteSite
		)
		return UISwipeActionsConfiguration(actions: [delete])
	}

	func isValidSiteIndex(_ index: Index) -> Bool {
		sdk?.sites[index] != nil
	}

	func resetSites() {
		if let sites = sdk?.sites {
			sites.reset()
		}
		table.reloadCells()
	}

	func reorderSites(sourceRow: Index, destinationRow: Index) {
		sdk?.sites.reorder(at: sourceRow, to: destinationRow)
		table.reloadData()
	}

	func goToSiteDetails(siteIndex: Index, sitesViewController: UIViewController) {
		SitesViewModel.prepareBackButtonForNavigation(sitesViewController)
		guard let settings = sdk?.settings else { return }
		let method = settings.deliveryMethod.value
		let params = SiteImageDeterminationParameters(deliveryMethod: method)
		if let site = sdk?.sites[siteIndex] {
			nav?.goToSiteDetails(site, source: sitesViewController, params: params)
		}
	}

	func handleSiteInsert(sitesViewController: UIViewController) {
		goToSiteDetails(siteIndex: sitesCount, sitesViewController: sitesViewController)
	}

	func toggleEdit(_ props: BarItemInitializationProperties) {
		table.toggleEdit(state: props.tableActionState)
	}

	func tryDeleteFromEditingStyle(style: UITableViewCell.EditingStyle, at indexPath: IndexPath) {
		guard style == .delete else { return }
		deleteSite(at: indexPath)
	}

	@objc func deleteSite(at indexPath: IndexPath) {
		guard let sites = sdk?.sites else { return }
		sites.delete(at: indexPath.row)
		table.deleteCell(indexPath: indexPath)
	}

	func getSitesViewControllerTitle(_ siteCellActionState: SiteTableActionState) -> String {
		siteCellActionState == .Editing ? "" : getViewControllerTitleFromDeliveryMethod()
	}

	func createBarItems(
		insertAction: Selector, editAction: Selector, sitesViewController: UIViewController
	) -> [UIBarButtonItem] {
		let insert = SiteViewFactory.createInsertItem(
			insert: insertAction, sitesViewController: sitesViewController
		)
		let edit = SiteViewFactory.createEditItem(
			edit: editAction, sitesViewController: sitesViewController
		)
		return [insert, edit]
	}

	private static func prepareBackButtonForNavigation(_ sitesViewController: UIViewController) {
		let backItem = SiteViewFactory.createBackItem()
		sitesViewController.navigationItem.backBarButtonItem = backItem
	}

	private func getViewControllerTitleFromDeliveryMethod() -> String {
		guard let sdk = sdk else { return ViewTitleStrings.SiteTitle }
		let method = sdk.settings.deliveryMethod.value
		return ViewTitleStrings.getSitesTitle(for: method)
	}
}
