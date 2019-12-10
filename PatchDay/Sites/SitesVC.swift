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
    
    private var viewModel: SitesViewModel?
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
        viewModel = SitesViewModel(sitesTable: SitesTable(sitesTable))
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
        [SiteViewFactory.createDeleteRowTableAction(indexPath: indexPath, delete: viewModel?.deleteSite(at: indexPath))]
    }
    
    // Row select action
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.goToSiteDetails(siteIndex: indexPath.row, sitesViewController: self)
    }
    
    // Movable
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        viewModel?.isValidSiteIndex(indexPath.row) ?? false
    }
    
    // Highlightable
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.sitesOptionsCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel?.sitesTable.getCell(at: indexPath.row, isEditing: false) ?? UITableViewCell()
    }
    
    // MARK: - Editing cells in the table
    
    // Permit editing at index
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        viewModel?.isValidSiteIndex(indexPath.row) ?? false
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
        viewModel?.sdk?.sites.reorder(at: sourceIndexPath.row, to: destinationIndexPath.row)
        sitesTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        RowHeight
    }
    
    // MARK: - Actions
    
    @objc func insertTapped() {
        viewModel?.handleSiteInsert(sitesViewController: self)
    }

    @objc func editTapped() {
        let props = SiteValueTypeFactory.createBarItemInitProps(#selector(resetTapped), #selector(insertTapped), self)
        viewModel?.handleEditSite(editBarItemProps: props)
        loadTitle(cellEditingState: props.cellEditingState)
        switchNavItems(barItemEditProps: props)
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

    private func switchNavItems(barItemEditProps props: BarItemInitializationProperties) {
        if var barItems = navigationItem.rightBarButtonItems, barItems.count >= 2 {
            barItems[0] = SiteViewFactory.createItemFromEditingState(props)
            barItems[1].title = props.oppositeActionTitle
        }
    }

    private func loadBarButtons() {
        navigationItem.rightBarButtonItems = viewModel.createBarItems(
            insertAction: #selector(insertTapped), editAction: #selector(editTapped), sitesViewController: self
        )
    }
    
    private func loadTitle(cellEditingState: SiteCellEditingState = .Unknown) {
        if cellEditingState == .Editing {
            title = ""
            return
        }

        title = viewModel?.getSitesTitle()
    }

    private func applyTheme() {
        if let theme = app?.styles.theme {
            sitesView.backgroundColor = theme[.bg]
            sitesTable.backgroundColor = theme[.bg]
            sitesTable.separatorColor = theme[.border]
        }
    }
}