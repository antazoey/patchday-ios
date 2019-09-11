//
//  SitesVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/10/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class SitesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var sitesView: UIView!
    @IBOutlet weak var sitesTable: UITableView!
    @IBOutlet weak var orderTitle: UILabel!
    
    // Dependencies
    private let siteSchedule = patchData.sdk.siteSchedule
    private let defaults = patchData.sdk.defaults

    public var buttonFontSize = {
        return UIFont.systemFont(ofSize: 15)
    }()
    public var addFontSize = {
        return UIFont.systemFont(ofSize: 39)
    }()
    public var siteNames: [String] = patchData.sdk.siteSchedule.getNames()
    public var siteImgIds: [String] = patchData.sdk.siteSchedule.getImageIds()
    
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
        reloadSiteNames()
        sitesTable.reloadData()
        setTitle()
        swapVisibilityOfCellFeatures(cellCount: sitesTable.numberOfRows(inSection: 0), shouldHide: false)
    }
    
    // MARK: - Table and cell characteristics.
    
    // Edit actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .normal, title: PDActionStrings.delete)
        { _, _ in
            self.deleteCell(indexPath: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    
    // Row action
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        segueToSiteVC(indexPath.row)
    }
    
    // Movable
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        tableView.cellForRow(at: indexPath)
        let movable = (indexPath.row < siteNames.count) ? true : false
        return movable
    }
    
    // Highlightable
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        tableView.cellForRow(at: indexPath)
        return true
    }

    // Defines table sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Defines table rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return siteNames.count
    }

    // Defines cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "siteCellReuseId"
        let siteCell = sitesTable.dequeueReusableCell(withIdentifier: id) as! SiteCell
        siteCell.configure(at: indexPath.row,
                           name: siteNames[indexPath.row],
                           siteCount: siteNames.count,
                           isEditing: sitesTable.isEditing)
        return siteCell
    }
    
    // MARK: - Editing cells in the table
    
    // Permits editing on filled cells
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let editable = (indexPath.row < siteNames.count) ? true : false
        return editable
    }
    
    // Editing style
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Indentation for edit mode
    func tableView(_ tableView: UITableView,
                   shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Delete cell (deletes MOSite)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCell(indexPath: indexPath)
        }
    }
    
    // Reorder cell (reorders MOSite order attributes)
    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        let siteToMove = siteSchedule.sites[sourceIndexPath.row]
        siteSchedule.sites.remove(at: sourceIndexPath.row)
        siteSchedule.sites.insert(siteToMove, at: destinationIndexPath.row)
        if sourceIndexPath.row == siteSchedule.nextIndex(changeIndex: defaults.setSiteIndex) {
            defaults.setSiteIndex(to: destinationIndexPath.row)
        }
        let count = siteSchedule.count()
        for i in 0..<count {
            siteSchedule.setOrder(at: i, to: Int16(i))
        }
        reloadSiteNames()
        sitesTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    // MARK: - Actions
    
    @objc func insertTapped() {
        segueToSiteVC(siteNames.count)
    }

    @objc func editTapped() {
        let c = sitesTable.numberOfRows(inSection: 0)
        if var items = navigationItem.rightBarButtonItems {
            switch items[1].title {
            case PDActionStrings.edit :
                self.title = ""
                self.navigationController?.tabBarItem.title = PDViewControllerTitleStrings.sitesTitle
                swapVisibilityOfCellFeatures(cellCount: c, shouldHide: true)
                switchBarItemFunctionality(items: &items)
                navigationItem.rightBarButtonItems = items
                sitesTable.isEditing = true
            case PDActionStrings.done :
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
        siteSchedule.reset()
        reloadSiteNames()
        sitesTable.isEditing = false
        let range = 0..<siteNames.count
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
    
    // MARK: - Private
    
    private func segueToSiteVC(_ siteIndex: Int) {
        let backItem = UIBarButtonItem()
        backItem.title = PDViewControllerTitleStrings.sitesTitle
        navigationItem.backBarButtonItem = backItem
        if let sb = storyboard, let navCon = navigationController, let siteVC = sb.instantiateViewController(withIdentifier: "SiteVC_id") as? SiteVC {
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
        case PDActionStrings.edit :
            items[1].title = PDActionStrings.done
            items[0] = UIBarButtonItem(title: PDActionStrings.reset,
                                       style: .plain,
                                       target: self,
                                       action: #selector(resetTapped))
            items[0].tintColor = UIColor.red
            
        case PDActionStrings.done :
            items[1].title = PDActionStrings.edit
            items[0] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add,
                                       target: self,
                                       action: #selector(insertTapped))
            items[0].tintColor = PDColors.getColor(.Green)
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
        siteSchedule.delete(at: indexPath.row)
        siteNames.remove(at: indexPath.row)
        sitesTable.deleteRows(at: [indexPath], with: .fade)
        sitesTable.reloadData()
        if indexPath.row <= (siteNames.count-1) {
            // Reset cell colors
            for i in indexPath.row..<siteNames.count {
                let nextIndexPath = IndexPath(row: i, section: 0)
                sitesTable.cellForRow(at: nextIndexPath)?.backgroundColor =
                    app.theme.getCellColor(at: i)
            }
        }
    }
    
    private func loadBarButtons() {
        let insertButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add,
                                           target: self,
                                           action: #selector(insertTapped))
        insertButton.tintColor = PDColors.getColor(.Green)
        let editButton = UIBarButtonItem(title: PDActionStrings.edit,
                                         style: .plain,
                                         target: self,
                                         action: #selector(editTapped))
        navigationItem.rightBarButtonItems = [insertButton, editButton]
    }
    
    private func setTitle() {
        typealias Titles = PDViewControllerTitleStrings
        switch defaults.deliveryMethod.value {
        case .Patches:
            title = PDViewControllerTitleStrings.patchSitesTitle
        case .Injections:
            title = PDViewControllerTitleStrings.injectionSitesTitle
        }        
        self.navigationController?.tabBarItem.title = PDViewControllerTitleStrings.sitesTitle
    }
    
    private func reloadSiteNames() {
        siteNames = siteSchedule.getNames()
    }
    
    private func loadTabBarItemSize() {
        let size: CGFloat = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ? 9 : 25
        let fontSize = UIFont.systemFont(ofSize: size)
        let font = [NSAttributedString.Key.font: fontSize]
        self.navigationController?.tabBarItem.setTitleTextAttributes(font, for: .normal)
    }
    
    private func applyTheme() {
        sitesView.backgroundColor = app.theme.bgColor
        sitesTable.backgroundColor = app.theme.bgColor
        sitesTable.separatorColor = app.theme.borderColor
    }
}

