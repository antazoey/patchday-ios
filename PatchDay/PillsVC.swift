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
        let insertButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(insertTapped))
        insertButton.tintColor = PDColors.pdGreen
        navigationItem.rightBarButtonItems = [insertButton]
        pillTable.allowsSelectionDuringEditing = true
        updateFromBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pills = pillController.pillArray
        pillTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pillController.pillArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pillTable.dequeueReusableCell(withIdentifier: "pillCellReuseID") as! PillTableViewCell
        if indexPath.row >= 0 && indexPath.row < pills.count {
            let indexStr = String(indexPath.row)
            let pill = pills[indexPath.row]
            enableOrDisableTake(for: cell)
            cell.nameLabel.text = pill.getName()
            cell.stateImage.image = loadPillImage(for: pill)
            cell.stateImageButton.type = .pills
            cell.lastTakenLabel.text = loadLastTimeTaken(for: pill)
            cell.setDueDateText(for: pill)
            cell.takeButton.setTitleColor(UIColor.lightGray, for: .disabled)
            cell.stateImage.restorationIdentifier = "i" + indexStr
            cell.takeButton.restorationIdentifier = "t" + indexStr
            cell.takeButton.isEnabled = (pill.isDone()) ? false : true
            
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = PDColors.pdLightBlue
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
        return 200.0
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
        if let restoreID = takeButton.restorationIdentifier {
            let pillIndexStr = String(restoreID.suffix(1))
            if let pillIndex = Int(pillIndexStr) {
                pillController.takePill(at: pillIndex)
                let cell = pillCellForRowAt(pillIndex)
                cell.stamp()
                if let pill = pillController.getPill(at: pillIndex) {
                    cell.setDueDateText(for: pill)
                    animatePillImageChange(pillImageView: cell.stateImage, pill: pill)
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
    
    private func loadPillImage(for pill: MOPill) -> UIImage {
        if pill.isDone() {
            return PDImages.pillDone
        }
        return PDImages.pill
    }
    
    private func loadLastTimeTaken(for pill: MOPill) -> String {
        if let lastTaken = pill.getLastTaken() {
            return PDDateHelper.format(date: lastTaken as Date, useWords: true)
        }
        return PDStrings.PlaceholderStrings.new_pill
    }
    
    private func enableOrDisableTake(for cell: PillTableViewCell) {
        if cell.stateImage.image == PDImages.pillDone {
            cell.takeButton.isEnabled = false
            cell.stateImageButton.isEnabled = false
        }
        else {
            cell.takeButton.isEnabled = true
            cell.stateImageButton.isEnabled = true
        }
    }
    
    private func pillCellForRowAt(_ index: Index) -> PillTableViewCell {
        let indexPath = IndexPath(row: index, section: 0)
        return pillTable.cellForRow(at: indexPath) as! PillTableViewCell
    }
    
    private func animatePillImageChange(pillImageView: UIImageView, pill: MOPill) {
        UIView.transition(with: pillImageView as UIView, duration: 0.4, options: .transitionCrossDissolve, animations: { pillImageView.image = self.loadPillImage(for: pill)
        }, completion: nil)
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

}
