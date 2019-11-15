//
//  SitesVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/10/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class SitesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var sitesView: UIView!
    @IBOutlet weak var sitesTable: UITableView!
    @IBOutlet weak var orderTitle: UILabel!
    
    private let model = SitesModel(sites: app?.sdk.sites, defaults: app?.sdk.defaults)

    public var buttonFontSize = { return UIFont.systemFont(ofSize: 15) }()
    
    public var addFontSize = { return UIFont.systemFont(ofSize: 39) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sitesTable.delegate = self
        sitesTable.dataSource = self
        loadBarButtons()
        sitesTable.allowsSelectionDuringEditing = true
        loadTabBarItemSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyTheme()
        sitesTable.reloadData()
        setTitle()
        swapVisibilityOfCellFeatures(
            cellCount: sitesTable.numberOfRows(inSection: 0),
            shouldHide: false
        )
    }
    
    // MARK: - Table and cell characteristics.

    func tableView(
        _ tableView: UITableView,
        editActionsForRowAt indexPath: IndexPath
    ) -> [UITableViewRowAction]?
    {
        let title = ActionStrings.delete
        let delete = UITableViewRowAction(style: .normal, title: title) {
            _, _ in self.deleteCell(indexPath: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    
    // Row action
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        segueToSiteDetailVC(indexPath.row)
    }
    
    // Movable
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        tableView.cellForRow(at: indexPath)
        return indexPath.row < model.sites?.names.count ?? indexPath.row
    }
    
    // Highlightable
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        tableView.cellForRow(at: indexPath)
        return true
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites?.names.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "siteCellReuseId"
        if let siteCell = sitesTable.dequeueReusableCell(withIdentifier: id) as? SiteCell,
            let sites = sites,
            let siteName = sites.names.tryGet(at: indexPath.row) {
    
            siteCell.configure(
                at: indexPath.row,
                name: siteName,
                siteCount: sites.count,
                isEditing: sitesTable.isEditing
            )
            return siteCell
        }
        return UITableViewCell()
    }
    
    // MARK: - Editing cells in the table
    
    // Permits editing on filled cells
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < sites?.count ?? indexPath.row
    }
    
    // Editing style
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Indentation for edit mode
    func tableView(_ tableView: UITableView,
                   shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Delete cell (deletes MOSite)
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            deleteCell(indexPath: indexPath)
        }
    }
    
    // Reorder cell
    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        sites?.reorder(at: sourceIndexPath.row, to: destinationIndexPath.row)
        sitesTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    // MARK: - Actions
    
    @objc func insertTapped() {
        if let siteCount = sites?.count {
            segueToSiteDetailVC(siteCount)
        }
    }

    @objc func editTapped() {
        let c = sitesTable.numberOfRows(inSection: 0)
        if var items = navigationItem.rightBarButtonItems {
            switch items[1].title {
            case ActionStrings.edit :
                self.title = ""
                self.navigationController?.tabBarItem.title = VCTitleStrings.sitesTitle
                swapVisibilityOfCellFeatures(cellCount: c, shouldHide: true)
                switchBarItemFunctionality(items: &items)
                navigationItem.rightBarButtonItems = items
                sitesTable.isEditing = true
            case ActionStrings.done :
                setTitle()
                swapVisibilityOfCellFeatures(cellCount: c, shouldHide: false)
                switchBarItemFunctionality(items: &items)
                navigationItem.rightBarButtonItems = items
                sitesTable.isEditing = false
            default : break
            }
        }
    }
    
    @objc func resetTapped() {
        setTitle()
        if let sites = sites {
            sites.reset()
            sitesTable.isEditing = false
            let range = 0..<sites.count
            let indexPathsToReload: [IndexPath] = range.map({
                (value: Int) -> IndexPath in
                return IndexPath(row: value, section: 0)
            })
            sitesTable.reloadData()
            sitesTable.reloadRows(at: indexPathsToReload, with: .automatic)
            let c = sitesTable.numberOfRows(inSection: 0)
            swapVisibilityOfCellFeatures(cellCount: c, shouldHide: false)
            switchNavItems()    // Close editing
        }
    }
    
    // MARK: - Private
    
    private func segueToSiteDetailVC(_ siteIndex: Int) {
        let backItem = UIBarButtonItem()
        backItem.title = VCTitleStrings.sitesTitle
        navigationItem.backBarButtonItem = backItem
        if let sb = storyboard, let navCon = navigationController, let siteVC = sb.instantiateViewController(withIdentifier: "SiteDetailVC_id") as? SiteDetailVC {
            siteVC.setSiteScheduleIndex(to: siteIndex)
            navCon.pushViewController(siteVC, animated: true)
        }
    }
    
    // Hides labels in the table cells for edit mode.
    private func swapVisibilityOfCellFeatures(cellCount: Int, shouldHide: Bool) {
        for i in 0..<cellCount {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = sitesTable.cellForRow(at: indexPath) as! SiteCell
            cell.swapVisibilityOfCellFeatures(cellIndex: i, shouldHide: shouldHide)
        }
    }
    
    private func switchBarItemFunctionality(items: inout [UIBarButtonItem]) {
        switch items[1].title {
        case ActionStrings.edit :
            items[1].title = ActionStrings.done
            items[0] = UIBarButtonItem(
                title: ActionStrings.reset,
                style: .plain,
                target: self,
                action: #selector(resetTapped)
            )
            items[0].tintColor = UIColor.red
            
        case ActionStrings.done :
            items[1].title = ActionStrings.edit
            items[0] = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonItem.SystemItem.add,
                target: self,
                action: #selector(insertTapped)
            )
            items[0].tintColor = PDColors.get(.Green)
        default : break
        }
    }
    
    private func switchNavItems() {
        if var items = navigationItem.rightBarButtonItems {
            switchBarItemFunctionality(items: &items)
            navigationItem.rightBarButtonItems = items
        }
    }
    
    private func deleteCell(indexPath: IndexPath) {
        if let sites = sites {
            sites.delete(at: indexPath.row)
            sitesTable.deleteRows(at: [indexPath], with: .fade)
            sitesTable.reloadData()
            if indexPath.row <= (sites.names.count - 1) {
                // Reset cell colors
                for i in indexPath.row..<sites.count {
                    let nextIndexPath = IndexPath(row: i, section: 0)
                    let cell = sitesTable.cellForRow(at: nextIndexPath)
                    cell?.backgroundColor = styles?.getCellColor(at: i)
                }
            }
        }
    }
    
    private func loadBarButtons() {
        let insertButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.add,
            target: self,
            action: #selector(insertTapped)
        )
        insertButton.tintColor = PDColors.get(.Green)
        let editButton = UIBarButtonItem(
            title: ActionStrings.edit,
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
        navigationItem.rightBarButtonItems = [insertButton, editButton]
    }
    
    private func setTitle() {
        typealias Titles = VCTitleStrings
        let method 
        title = VCTitleStrings.getSitesTitle(for: <#T##DeliveryMethod#>)
        switch sdk.defaults.deliveryMethod.value {
        case .Patches:
            title = VCTitleStrings.patchSitesTitle
        case .Injections:
            title = VCTitleStrings.injectionSitesTitle
        }        
        self.navigationController?.tabBarItem.title = VCTitleStrings.sitesTitle
    }

    private func loadTabBarItemSize() {
        let size: CGFloat = AppDelegate.isPad ? 25 : 9
        let fontSize = UIFont.systemFont(ofSize: size)
        let font = [NSAttributedString.Key.font: fontSize]
        self.navigationController?.tabBarItem.setTitleTextAttributes(font, for: .normal)
    }
    
    private func applyTheme() {
        if let theme = app?.styles.theme {
            sitesView.backgroundColor = theme[.bg]
            sitesTable.backgroundColor = theme[.bg]
            sitesTable.separatorColor = theme[.border]
        }
    }
}
