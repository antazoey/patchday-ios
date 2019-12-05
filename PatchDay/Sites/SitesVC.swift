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
    
    private let viewModel = SitesViewModel()
    private let RowHeight: CGFloat = 55.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sitesTable.delegate = self
        sitesTable.dataSource = self
        loadBarButtons()
        sitesTable.allowsSelectionDuringEditing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyTheme()
        sitesTable.reloadData()
        loadTitle()
        swapVisibilityOfCellFeatures(
            cellCount: sitesTable.numberOfRows(inSection: 0),
            shouldHide: false
        )
    }
    
    // MARK: - Table and cell characteristics.

    func numberOfSections(in tableView: UITableView) -> Int {
        DefaultNumberOfPickerComponents
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let title = ActionStrings.delete
        let delete = UITableViewRowAction(style: .normal, title: title) {
            _, _ in self.deleteCell(indexPath: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    
    // Row select action
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        segueToSiteDetailVC(indexPath.row)
    }
    
    // Movable
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        viewModel.isValidSiteIndex(indexPath.row)
    }
    
    // Highlightable
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sitesOptionsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel.sitesTable.getCell
    }
    
    // MARK: - Editing cells in the table
    
    // Permit editing at index
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        viewModel.isValidSiteIndex(indexPath.row)
    }
    
    // Editing style
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    // Indentation for edit mode
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    // Delete cell (deletes MOSite)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCell(indexPath: indexPath)
        }
    }
    
    // Reorder cell
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.sdk?.sites.reorder(at: sourceIndexPath.row, to: destinationIndexPath.row)
        sitesTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        RowHeight
    }
    
    // MARK: - Actions
    
    @objc func insertTapped() {
        segueToSiteDetailVC(viewModel.sitesCount)
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
                loadTitle()
                swapVisibilityOfCellFeatures(cellCount: c, shouldHide: false)
                switchBarItemFunctionality(items: &items)
                navigationItem.rightBarButtonItems = items
                sitesTable.isEditing = false
            default : break
            }
        }
    }
    
    @objc func resetTapped() {
        loadTitle()
        viewModel.resetSites()
        sitesTable.isEditing = false
        let range = 0..<viewModel.sitesCount
        let indexPathsToReload = range.map({ (value: Int) -> IndexPath in IndexPath(row: value, section: 0)})
        sitesTable.reloadData()
        sitesTable.reloadRows(at: indexPathsToReload, with: .automatic)
        let c = sitesTable.numberOfRows(inSection: 0)
        swapVisibilityOfCellFeatures(cellCount: c, shouldHide: false)
        switchNavItems()  // Close editing
    }
    
    // MARK: - Private
    
    private func segueToSiteDetailVC(_ siteIndex: Int) {
        viewModel.goToSiteDetails(siteIndex: siteIndex, sitesViewController: self)
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
        viewModel.deleteSite(at: indexPath.row)
        sitesTable.deleteRows(at: [indexPath], with: .fade)
        sitesTable.reloadData()
        if indexPath.row < viewModel.sitesCount {
            resetCellColors(startIndex: indexPath.row)
        }
    }

    private func resetCellColors(startIndex: Index) {
        for i in startIndex..<viewModel.sitesCount {
            let nextIndexPath = IndexPath(row: i, section: 0)
            let cell = sitesTable.cellForRow(at: nextIndexPath)
            cell?.backgroundColor = viewModel.styles?.getCellColor(at: i)
        }
    }
    
    private func loadBarButtons() {
        navigationItem.rightBarButtonItems = viewModel.createBarItems(
            insertAction: #selector(insertTapped), editAction: #selector(editTapped), sitesViewController: self
        )
    }
    
    private func loadTitle() {
        title = viewModel.getSitesTitle()
    }

    private func applyTheme() {
        if let theme = app?.styles.theme {
            sitesView.backgroundColor = theme[.bg]
            sitesTable.backgroundColor = theme[.bg]
            sitesTable.separatorColor = theme[.border]
        }
    }
}