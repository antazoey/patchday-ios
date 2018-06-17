//
//  SitesVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/10/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit

class SitesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var siteTable: UITableView!
    @IBOutlet weak var orderTitle: UILabel!
    
    // Constants
    public var buttonFontSize = { return UIFont.systemFont(ofSize: 15) }()
    public var addFontSize = { return UIFont.systemFont(ofSize: 39)}()
    
    private var siteNames: [String] = CoreDataController.sites().siteNames
    
    private var selected: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.siteTable.delegate = self
        self.siteTable.dataSource = self
        let insertButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(insertTapped))
        insertButton.tintColor = PDColors.pdGreen
        let editButton = UIBarButtonItem(title: PDStrings.actionStrings.edit, style: .plain, target: self, action: #selector(editTapped))
        self.navigationItem.rightBarButtonItems = [insertButton, editButton]
        self.siteTable.allowsSelectionDuringEditing = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.siteNames = CoreDataController.sites().siteNames
        self.siteTable.reloadData()
    }
    
    // MARK: - Table
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .normal, title: PDStrings.actionStrings.delete)
        { action, index in
            self.deleteCell(indexPath: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.siteTable.cellForRow(at: indexPath) as! SiteTableViewCell
        if let text = cell.nameLabel.text, let i = siteNames.index(of: text) {
            self.selected = i
            segueToSiteVC(i)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        tableView.cellForRow(at: indexPath)
        let movable = (indexPath.row < self.siteNames.count) ? true : false
        return movable
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        tableView.cellForRow(at: indexPath)
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
 
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.siteNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.siteTable.dequeueReusableCell(withIdentifier: "cellReuseIdentifier") as! SiteTableViewCell
        let i = indexPath.row
        if i >= 0 && i < self.siteNames.count {
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let editable = (indexPath.row < self.siteNames.count) ? true : false
        return editable
    }
    
    // DELETE CELL
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Deleting MOSite by deleting site row
        if editingStyle == .delete {
            self.deleteCell(indexPath: indexPath)
        }
    }
    
    // REORDER CELLS
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.siteNames[sourceIndexPath.row]
        let begin_i: Int = sourceIndexPath.row
        let end_i: Int = destinationIndexPath.row
        self.siteNames.remove(at: begin_i)
        self.siteNames.insert(movedObject, at: end_i)
        for i in 0...(siteNames.count-1) {
            CoreDataController.coreData.setSiteName(index: i, to: siteNames[i])
        }
        self.siteTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    // MARK: - Actions
    
    @objc func insertTapped() {
        segueToSiteVC(self.siteNames.count)
    }

    @objc func editTapped() {
        if let items = self.navigationItem.rightBarButtonItems {
            switch items[1].title {
            case PDStrings.actionStrings.edit :
                self.swapVisibilityOfCellFeatures(shouldHide: true)
                items[1].title = PDStrings.actionStrings.done
                self.siteTable.isEditing = true
                break
            case PDStrings.actionStrings.done :
                self.swapVisibilityOfCellFeatures(shouldHide: false)
                items[1].title = PDStrings.actionStrings.edit
                self.siteTable.isEditing = false
            default : break
            }
        }
    }
    
    // MARK: - Private
    
    private func segueToSiteVC(_ index: Int) {
        if let sb = storyboard, let navCon = self.navigationController, let siteVC: SiteVC = sb.instantiateViewController(withIdentifier: "SiteVC_id") as? SiteVC {
            siteVC.setReference(to: index)
            navCon.pushViewController(siteVC, animated: true)
        }
    }
    
    private func swapVisibilityOfCellFeatures(shouldHide: Bool) {
        for i in 0...(self.siteNames.count-1) {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = self.siteTable.cellForRow(at: indexPath) as! SiteTableViewCell
            cell.orderLabel.isHidden = shouldHide
            cell.arrowLabel.isHidden = shouldHide
        }
    }
    
    private func deleteCell(indexPath: IndexPath) {
        CoreDataController.coreData.deleteSite(index: indexPath.row)
        self.siteNames.remove(at: indexPath.row)
        self.siteTable.deleteRows(at: [indexPath], with: .fade)
        self.siteTable.reloadData()
        if indexPath.row < (self.siteNames.count-1) {
            
            // Reset cell colors
            for i in indexPath.row...(self.siteNames.count-1) {
                let nextIndexPath = IndexPath(row: i, section: 0)
                self.siteTable.cellForRow(at: nextIndexPath)?.backgroundColor = (i%2 == 0) ? PDColors.pdLightBlue : self.view.backgroundColor
            }
        }
    }

}

