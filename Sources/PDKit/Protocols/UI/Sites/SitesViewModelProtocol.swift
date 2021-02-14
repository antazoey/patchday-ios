//
//  SitesViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  
//

import Foundation

public protocol SitesViewModelProtocol {
    var sites: SiteScheduling? { get }
    var sitesCount: Int { get }
    var table: SitesTableProtocol { get }
    var sitesOptionsCount: Int { get }
    func createSiteCellSwipeActions(indexPath: IndexPath) -> UISwipeActionsConfiguration
    func isValidSiteIndex(_ index: Index) -> Bool
    func resetSites()
    func reorderSites(sourceRow: Index, destinationRow: Index)
    func goToSiteDetails(siteIndex: Index, sitesViewController: UIViewController)
    func handleSiteInsert(sitesViewController: UIViewController)
    func toggleEdit(_ isEditing: Bool)
    func deleteSite(at indexPath: IndexPath)
    func createBarItems(
        insertAction: Selector, editAction: Selector, sitesViewController: UIViewController
    ) -> [UIBarButtonItem]
}
