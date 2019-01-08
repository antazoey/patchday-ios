//
//  PillsVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 12/16/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

typealias PillName = String

class PillsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var pillTable: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var pills = PillSchedule.pills
    
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
        pills = PillSchedule.pills
        pillTable.reloadData()
        reloadInputViews()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PillSchedule.count()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        typealias Cell = PillTableViewCell
        let id = "pillCellReuseId"
        let table = pillTable
        let cell = table?.dequeueReusableCell(withIdentifier: id) as! Cell
        let i = indexPath.row
        if i >= 0 && i < pills.count {
            cell.configure(using: pills[i], at: i)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let pill = pills[indexPath.row]
        segueToPillView(for: pill, at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let title = PDStrings.ActionStrings.delete
        let delete = UITableViewRowAction(style: .normal, title: title) {
            (action, index) in
            self.deleteCell(at: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    
    @IBAction func takeButtonTapped(_ sender: Any) {
        let takeButton = sender as! UIButton
        // Acquire Pill Id from cell's takeButton.
        if let restoreId = takeButton.restorationIdentifier {
            let pillIndexStr = String(restoreId.suffix(1))
            if let pillIndex = Int(pillIndexStr) {
                PillSchedule.takePill(at: pillIndex,
                                      setPDSharedData: PDSharedData.setPillDataForToday)
                appDelegate.notificationsController.requestNotifyTakePill(at: pillIndex)
                let cell = pillCellForRowAt(pillIndex)
                cell.stamp()
                if let pill = PillSchedule.getPill(at: pillIndex) {
                    cell.loadDueDateText(from: pill)
                    cell.loadStateImage(from: pill)
                    cell.loadLastTakenText(from: pill)
                }
                cell.enableOrDisableTake()
                pills = PillSchedule.pills
                pillTable.reloadData()
                reloadInputViews()
            }
            setBadge()
        }
    }
    
    @objc func insertTapped() {
        if let pill = PillSchedule.insert(completion: PDSharedData.setPillDataForToday),
            let i = PillSchedule.pills.index(of: pill) {
            segueToPillView(for: pill, at: i)
        }
    }
    
    // MARK: - Private / Helpers
    
    private func segueToPillView(for pill: MOPill, at index: Index) {
        if let sb = storyboard, let navCon = navigationController, let pillVC = sb.instantiateViewController(withIdentifier: "PillVC_id") as? PillVC {
            pillVC.setPillIndex(index)
            navCon.pushViewController(pillVC, animated: true)
        }
    }
    
    private func pillCellForRowAt(_ index: Index) -> PillTableViewCell {
        let indexPath = IndexPath(row: index, section: 0)
        return pillTable.cellForRow(at: indexPath) as! PillTableViewCell
    }
    
    private func deleteCell(at indexPath: IndexPath) {
        PillSchedule.deletePill(at: indexPath.row)
        pills.remove(at: indexPath.row)
        pillTable.deleteRows(at: [indexPath], with: .fade)
        pillTable.reloadData()
        
        if indexPath.row <= (pills.count-1) {
            // Reset cell colors
            for i in indexPath.row..<pills.count {
                let nextIndexPath = IndexPath(row: i, section: 0)
                // Cell bg
                pillTable.cellForRow(at: nextIndexPath)?.backgroundColor = (i%2 == 0) ? PDColors.pdLightBlue : view.backgroundColor
            }
        }
        PDSharedData.setPillDataForToday()
        setBadge()
    }
    
    /// Updates the pill views when VC is reloaded from a notification.
    internal func updateFromBackground() {
        let name = NSNotification.Name.UIApplicationWillEnterForeground
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: name,
                                               object: nil)
    }
    
    @objc internal func appWillEnterForeground() {
        pillTable.reloadData()
    }
    
    private func setBadge() {
        let v = PillSchedule.totalDue()
        navigationController?.tabBarItem.badgeValue = (v > 0) ? "\(v)" : nil
    }
    
    private func loadTabBarItemSize() {
        let size: CGFloat = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ? 9 : 25
        self.navigationController?.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: size)], for: .normal)
    }
}
