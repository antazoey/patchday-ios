//
//  PillsVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 12/16/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

typealias PillName = String

class PillsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var pillTable: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var pillController = ScheduleController.pillController
    private var pills = ScheduleController.pillController.pillArray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = PDStrings.VCTitles.pills
        pillTable.delegate = self
        pillTable.dataSource = self
        loadTabBarItemSize()
        let insertButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(insertTapped))
        insertButton.tintColor = PDColors.pdGreen
        navigationItem.rightBarButtonItems = [insertButton]
        pillTable.allowsSelectionDuringEditing = true
        updateFromBackground()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pills = pillController.pillArray
        pillTable.reloadData()
        reloadInputViews()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pillController.pillArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pillTable.dequeueReusableCell(withIdentifier: "pillCellReuseID") as! PillTableViewCell
        if indexPath.row >= 0 && indexPath.row < pills.count {
            let indexStr = String(indexPath.row)
            let pill = pills[indexPath.row]

            cell.nameLabel.text = pill.getName()
            cell.loadStateImage(from: pill)
            cell.stateImageButton.type = .pills
            cell.loadLastTakenText(from: pill)
            cell.loadDueDateText(from: pill)
            cell.takeButton.setTitleColor(UIColor.lightGray, for: .disabled)
            cell.stateImageButton.restorationIdentifier = "i" + indexStr
            cell.takeButton.restorationIdentifier = "t" + indexStr
            cell.takeButton.isEnabled = (pill.isDone()) ? false : true
            
            enableOrDisableTake(for: cell)
            
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = PDColors.pdLightBlue
                cell.imageViewView.backgroundColor = nil
                cell.stateImageButton.backgroundColor = nil
            }
            
            if pill.isExpired() {
                cell.stateImageButton.badgeValue = "!"
            }
            else {
                cell.stateImageButton.badgeValue = nil
            }
 
        }
        
        // Cell background view when selected
        let backgroundView = UIView()
        backgroundView.backgroundColor = PDColors.pdPink
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pill = pills[indexPath.row]
        segueToPillView(for: pill, at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .normal, title: PDStrings.ActionStrings.delete)
        { action, index in
            self.deleteCell(at: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    
    @IBAction func takeButtonTapped(_ sender: Any) {
        let takeButton = sender as! UIButton
        // Acquire Pill ID from cell's takeButton.
        if let restoreID = takeButton.restorationIdentifier {
            let pillIndexStr = String(restoreID.suffix(1))
            if let pillIndex = Int(pillIndexStr) {
                pillController.takePill(at: pillIndex)
                let cell = pillCellForRowAt(pillIndex)
                cell.stamp()
                if let pill = pillController.getPill(at: pillIndex) {
                    cell.loadDueDateText(from: pill)
                    cell.loadStateImage(from: pill)
                    cell.loadLastTakenText(from: pill)
                }
                self.enableOrDisableTake(for: cell)
                pills = pillController.pillArray
                pillTable.reloadData()
                reloadInputViews()
            }
            setBadge()
        }
    }
    
    @objc func insertTapped() {
        if let newPill = pillController.insertNewPill(),
            let newPillIndex = pillController.pillArray.index(of: newPill) {
            segueToPillView(for: newPill, at: newPillIndex)
        }
    }
    
    // MARK: - Private / Helpers
    
    private func segueToPillView(for pill: MOPill, at index: Index) {
        if let sb = storyboard, let navCon = navigationController, let pillVC = sb.instantiateViewController(withIdentifier: "PillVC_id") as? PillVC {
            pillVC.setPillIndex(index)
            navCon.pushViewController(pillVC, animated: true)
        }
    }
    
    private func enableOrDisableTake(for cell: PillTableViewCell) {
        // Disable take
        if cell.stateImage.tintColor == UIColor.lightGray {
            cell.takeButton.setTitle(PDStrings.ActionStrings.taken, for: .normal)
            cell.takeButton.isEnabled = false
            cell.stateImageButton.isEnabled = false
        }
        // Enable
        else {
            cell.takeButton.setTitle(PDStrings.ActionStrings.take, for: .normal)
            cell.takeButton.isEnabled = true
            cell.stateImageButton.isEnabled = true
        }
    }
    
    private func pillCellForRowAt(_ index: Index) -> PillTableViewCell {
        let indexPath = IndexPath(row: index, section: 0)
        return pillTable.cellForRow(at: indexPath) as! PillTableViewCell
    }
    
    private func deleteCell(at indexPath: IndexPath) {
        pillController.deletePill(at: indexPath.row)
        pills.remove(at: indexPath.row)
        pillTable.deleteRows(at: [indexPath], with: .fade)
        pillTable.reloadData()
        if indexPath.row < (pills.count-1) {
            
            // Reset cell colors
            for i in indexPath.row..<pills.count {
                let nextIndexPath = IndexPath(row: i, section: 0)
                pillTable.cellForRow(at: nextIndexPath)?.backgroundColor = (i%2 == 0) ? PDColors.pdLightBlue : view.backgroundColor
            }
        }
        ScheduleController.setPillDataForToday()
        setBadge()
    }
    
    /// Updates the pill views when VC is reloaded from a notification.
    internal func updateFromBackground() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc internal func appWillEnterForeground() {
        pillTable.reloadData()
    }
    
    private func setBadge() {
        let newBadgeValue = ScheduleController.totalPillsDue()
        navigationController?.tabBarItem.badgeValue = (newBadgeValue > 0) ? String(newBadgeValue) : nil
    }
    
    private func loadTabBarItemSize() {
        let size: CGFloat = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ? 9 : 25
        self.navigationController?.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: size)], for: .normal)
    }

}
