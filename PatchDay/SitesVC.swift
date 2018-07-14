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
    
    @IBOutlet weak var siteTable: UITableView!
    @IBOutlet weak var orderTitle: UILabel!
    
    // Constants
    public var buttonFontSize = { return UIFont.systemFont(ofSize: 15) }()
    public var addFontSize = { return UIFont.systemFont(ofSize: 39)}()
    
    // Variables
    public var siteNames: [String] = ScheduleController.siteController.getScheduleSiteNames()
    public var siteImgIDs: [String] = PDSiteHelper.getSiteImageIDs(ScheduleController.siteController.siteArray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        siteTable.delegate = self
        siteTable.dataSource = self
        loadBarButtons()
        siteTable.allowsSelectionDuringEditing = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadSiteNames()
        siteTable.reloadData()
        setTitle()
        swapVisibilityOfCellFeatures(shouldHide: false)
    }
    
    // MARK: - Table and cell characteristics.
    
    // Edit actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .normal, title: PDStrings.ActionStrings.delete)
        { _, _ in
            self.deleteCell(indexPath: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    
    // Row selection, like action
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
        let cell = siteTable.dequeueReusableCell(withIdentifier: "siteCellReuseID") as! SiteTableViewCell
        let i = indexPath.row
        if i >= 0 && i < siteNames.count {
            cell.orderLabel.text = String(i + 1) + "."
            cell.nameLabel.text = siteNames[i]
            if i % 2 == 0 {
                cell.backgroundColor = PDColors.pdLightBlue
            }
        }
        
        // Cell background view when selected
        let backgroundView = UIView()
        backgroundView.backgroundColor = PDColors.pdPink
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    // MARK: - Editing cells in the table
    
    // Permits editing on filled cells
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let editable = (indexPath.row < siteNames.count) ? true : false
        return editable
    }
    
    // Editing style
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    // Indentation for edit mode
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // Delete cell (deletes MOSite)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCell(indexPath: indexPath)
        }
    }
    
    // Reorder cell (reorders MOSite order attributes)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let siteToMove = ScheduleController.siteController.siteArray[sourceIndexPath.row]
        ScheduleController.siteController.siteArray.remove(at: sourceIndexPath.row)
        ScheduleController.siteController.siteArray.insert(siteToMove, at: destinationIndexPath.row)
        for i in 0..<ScheduleController.siteCount() {
            ScheduleController.siteController.setSiteOrder(index: i, to: Int16(i))
        }
        reloadSiteNames()
        siteTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    // MARK: - Actions
    
    @objc func insertTapped() {
        segueToSiteVC(siteNames.count)
    }

    @objc func editTapped() {
        if var items = navigationItem.rightBarButtonItems {
            switch items[1].title {
            case PDStrings.ActionStrings.edit :
                self.title = ""
                self.navigationController?.tabBarItem.title = PDStrings.VCTitles.sites
                swapVisibilityOfCellFeatures(shouldHide: true)
                switchBarItemFunctionality(items: &items)
                navigationItem.rightBarButtonItems = items
                siteTable.isEditing = true
            case PDStrings.ActionStrings.done :
                setTitle()
                swapVisibilityOfCellFeatures(shouldHide: false)
                switchBarItemFunctionality(items: &items)
                navigationItem.rightBarButtonItems = items
                siteTable.isEditing = false
            default : break
            }
        }
    }
    
    @objc func resetTapped() {
        setTitle()
        ScheduleController.siteController.resetSiteData()
        reloadSiteNames()
        siteTable.isEditing = false
        let range = 0..<siteNames.count
        let indexPathsToReload: [IndexPath] = range.map({
            (value: Int) -> IndexPath in
            return IndexPath(row: value, section: 0)
        })
        siteTable.reloadData()
        siteTable.reloadRows(at: indexPathsToReload, with: .automatic)
        swapVisibilityOfCellFeatures(shouldHide: false)
        switchNavItems()    // Close editing
    }
    
    // MARK: - Private
    
    private func segueToSiteVC(_ siteIndex: Int) {
        let backItem = UIBarButtonItem()
        backItem.title = PDStrings.VCTitles.sites
        navigationItem.backBarButtonItem = backItem
        if let sb = storyboard, let navCon = navigationController, let siteVC = sb.instantiateViewController(withIdentifier: "SiteVC_id") as? SiteVC {
            siteVC.setSiteScheduleIndex(to: siteIndex)
            navCon.pushViewController(siteVC, animated: true)
        }
    }
    
    // Hides labels in the table cells for edit mode.
    private func swapVisibilityOfCellFeatures(shouldHide: Bool) {
        for i in 0..<siteNames.count {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = siteTable.cellForRow(at: indexPath) as! SiteTableViewCell
            cell.orderLabel.isHidden = shouldHide
            cell.arrowLabel.isHidden = shouldHide
        }
    }
    
    private func switchBarItemFunctionality(items: inout [UIBarButtonItem]) {
        switch items[1].title {
        case PDStrings.ActionStrings.edit :
            items[1].title = PDStrings.ActionStrings.done
            items[0] = UIBarButtonItem(title: PDStrings.ActionStrings.reset, style: .plain, target: self, action: #selector(resetTapped))
            items[0].tintColor = UIColor.red
            
        case PDStrings.ActionStrings.done :
            items[1].title = PDStrings.ActionStrings.edit
            items[0] = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(insertTapped))
            items[0].tintColor = PDColors.pdGreen
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
        ScheduleController.siteController.deleteSite(at: indexPath.row)
        siteNames.remove(at: indexPath.row)
        siteTable.deleteRows(at: [indexPath], with: .fade)
        siteTable.reloadData()
        if indexPath.row < (siteNames.count-1) {
            
            // Reset cell colors
            for i in indexPath.row..<siteNames.count {
                let nextIndexPath = IndexPath(row: i, section: 0)
                siteTable.cellForRow(at: nextIndexPath)?.backgroundColor = (i%2 == 0) ? PDColors.pdLightBlue : view.backgroundColor
            }
        }
    }
    
    private func loadBarButtons() {
        let insertButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(insertTapped))
        insertButton.tintColor = PDColors.pdGreen
        let editButton = UIBarButtonItem(title: PDStrings.ActionStrings.edit, style: .plain, target: self, action: #selector(editTapped))
        navigationItem.rightBarButtonItems = [insertButton, editButton]
    }
    
    private func setTitle() {
        title = (UserDefaultsController.usingPatches()) ? PDStrings.VCTitles.patch_sites : PDStrings.VCTitles.injection_sites
        self.navigationController?.tabBarItem.title = PDStrings.VCTitles.sites
    }
    
    private func reloadSiteNames() {
        siteNames = ScheduleController.siteController.getScheduleSiteNames()
    }

}

