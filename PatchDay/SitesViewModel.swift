//
//  SitesViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/13/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SitesViewModel: CodeBehindDependencies {

    let sitesTable: SitesTable

    init(sitesTable: SitesTable) {
        self.sitesTable = sitesTable
    }

    var sites: HormoneSiteScheduling? {
        sdk?.sites
    }

    var sitesCount: Int {
        sdk?.sites.count ?? 0
    }

    var sitesOptionsCount: Int {
        sdk?.sites.names.count ?? 0
    }

    func isValidSiteIndex(_ index: Index) -> Bool {
        sdk?.sites.at(index) != nil
    }

    func resetSites() {
        if let sites = sdk?.sites {
            sites.reset()
        }
    }

    func goToSiteDetails(siteIndex: Index, sitesViewController: UIViewController) {
        SitesViewModel.prepareBackButtonForNavigation(sitesViewController)
        if let site = sdk?.sites.at(siteIndex) {
            nav?.goToSiteDetails(site, source: sitesViewController)
        }
    }

    func handleSiteInsert(sitesViewController: UIViewController) {
        goToSiteDetails(siteIndex: sitesCount, sitesViewController: sitesViewController)
    }

    func handleEditSite(editBarItemProps props: BarItemInitializationProperties) {
        sitesTable.prepareCellsForEditMode(editingState: props.cellEditingState)
    }

    @objc func deleteSite(at indexPath: IndexPath) {
        if let sites = sdk?.sites {
            sites.delete(at: indexPath.row)
        }
        sitesTable.deleteRows(at: [indexPath], with: .fade)
        sitesTable.reloadData()
        if indexPath.row < viewModel.sitesCount {
            resetCellColors(startIndex: indexPath.row)
        }
    }

    func getSitesTitle() -> String {
        if let method = sdk?.defaults.deliveryMethod.value {
            return VCTitleStrings.getSitesTitle(for: method)
        }
        return VCTitleStrings.siteTitle
    }

    func createBarItems(insertAction: Selector, editAction: Selector, sitesViewController: UIViewController) -> [UIBarButtonItem] {
        let insert = SiteViewFactory.createInsertItem(insertAction: insertAction, sitesViewController: sitesViewController)
        let edit = SiteViewFactory.createEditItem(editAction: editAction, sitesViewController: sitesViewController)
        return [insert, edit]
    }

    private static func prepareBackButtonForNavigation(_ sitesViewController: UIViewController) {
        let backItem = SiteViewFactory.createBackItem()
        sitesViewController.navigationItem.backBarButtonItem = backItem
    }
}
