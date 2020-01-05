//
//  SitesVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/10/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class SitesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var sitesView: UIView!
    @IBOutlet weak var sitesTableView: UITableView!
    
    private var viewModel: SitesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModelIfNil()
        sitesTableView.delegate = self
        sitesTableView.dataSource = self
        loadBarButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initViewModelIfNil()
        applyTheme()
        viewModel.sitesTable.reloadData()
        loadTitle()
    }
    
    // MARK: - Table and cell characteristics.

    func numberOfSections(in tableView: UITableView) -> Int {
        DefaultNumberOfPickerComponents
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        viewModel.createDeleteRowActionAsList(indexPath: indexPath)
    }
    
    // Row select action
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.goToSiteDetails(siteIndex: indexPath.row, sitesViewController: self)
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
        viewModel.sitesTable.getCell(at: indexPath.row)
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
        viewModel.tryDeleteFromEditingStyle(style: editingStyle, at: indexPath)
    }
    
    // Reorder cell
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.reorderSites(sourceRow: sourceIndexPath.row, destinationRow: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.sitesTable.RowHeight
    }
    
    // MARK: - Actions

    @objc func editTapped() {
        let props = createBarItemProps()
        viewModel.handleEditSite(editBarItemProps: props)
        loadTitle(actionState: props.tableActionState)
        switchNavItems(barItemEditProps: props)
    }

    @objc func insertTapped() {
        viewModel.handleSiteInsert(sitesViewController: self)
    }

    @objc func resetTapped() {
        loadTitle()
        viewModel.resetSites()
        switchNavItems(barItemEditProps: createBarItemProps())
    }
    
    // MARK: - Private

    private func initViewModelIfNil() {
        if viewModel == nil {
            viewModel = SitesViewModel(sitesTableView: sitesTableView)
        }
    }

    private func createBarItemProps() -> BarItemInitializationProperties {
        SiteValueTypeFactory.createBarItemInitProps(#selector(resetTapped), #selector(insertTapped), self)
    }

    private func switchNavItems(barItemEditProps props: BarItemInitializationProperties) {
        if var barItems = navigationItem.rightBarButtonItems {
            viewModel.switchBarItems(items: &barItems, barItemEditProps: props)
        }
    }

    private func loadBarButtons() {
        navigationItem.rightBarButtonItems = viewModel.createBarItems(
            insertAction: #selector(insertTapped), editAction: #selector(editTapped), sitesViewController: self
        )
    }
    
    private func loadTitle(actionState: SiteTableActionState = .Unknown) {
        title = viewModel.getSitesViewControllerTitle(actionState)
    }

    private func applyTheme() {
        if let theme = viewModel.styles?.theme {
            sitesView.backgroundColor = theme[.bg]
        }
    }
}
