//
//  SitesViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/13/19.

import UIKit
import PDKit

class SitesViewModel: CodeBehindDependencies<SitesViewModel>, SitesViewModelProtocol {

    var table: SitesTableProtocol

    init(sitesTable: SitesTableProtocol, dependencies: DependenciesProtocol?=nil) {
        self.table = sitesTable
        if let dep = dependencies {
            super.init(
                sdk: dep.sdk,
                tabs: dep.tabs,
                notifications: dep.notifications,
                alerts: dep.alerts,
                nav: dep.nav,
                badge: dep.badge,
                widget: dep.widget
            )
        } else {
            super.init()
        }
        self.sdk?.sites.reloadContext()
        self.table.sites = sdk?.sites
        watchForChanges()
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
        guard let sites = sdk?.sites else { return }
        sites.reset()
    }

    func reorderSites(sourceRow: Index, destinationRow: Index) {
        guard let sdk = sdk else { return }
        sdk.sites.reorder(at: sourceRow, to: destinationRow)
        sdk.settings.setSiteIndex(to: destinationRow)
        table.reloadData()
    }

    func goToSiteDetails(siteIndex: Index, sitesViewController: UIViewController) {
        SitesViewModel.prepareBackButtonForNavigation(sitesViewController)
        guard let settings = sdk?.settings else { return }
        if table.isEditing {
            table.toggleEdit(isEditing: false)
        }
        let method = settings.deliveryMethod.value
        let params = SiteImageDeterminationParameters(deliveryMethod: method)
        let site = sdk?.sites[siteIndex]
        params.imageId = site?.imageId
        nav?.goToSiteDetails(siteIndex, source: sitesViewController, params: params)
    }

    func handleSiteInsert(sitesViewController: UIViewController) {
        sdk?.sites.insertNew(name: SiteStrings.NewSite) {
            site in
            self.goToSiteDetails(siteIndex: site.order, sitesViewController: sitesViewController)
        }
    }

    func toggleEdit(_ isEditing: Bool) {
        table.toggleEdit(isEditing: isEditing)
    }

    @objc func deleteSite(at indexPath: IndexPath) {
        guard let sites = sdk?.sites else { return }
        sites.delete(at: indexPath.row)
        table.deleteCell(indexPath: indexPath)
        table.reloadCells()
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

    private func watchForChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadDataFromBackgroundUpdate),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    private static func prepareBackButtonForNavigation(_ sitesViewController: UIViewController) {
        let backItem = SiteViewFactory.createBackItem()
        sitesViewController.navigationItem.backBarButtonItem = backItem
    }

    @objc private func reloadDataFromBackgroundUpdate() {
        tabs?.reflect()
    }
}
