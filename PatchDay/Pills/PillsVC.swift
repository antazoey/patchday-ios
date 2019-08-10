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
    
    @IBOutlet var pillsView: UIView!
    @IBOutlet weak var pillsTable: UITableView!
    
    // Dependencies
    private let pillSchedule = patchData.sdk.pillSchedule
    private let shared = patchData.sdk.pdSharedData
    private let notifications = app.notifications
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        title = PDViewControllerTitleStrings.pillsTitle
        pillsTable.delegate = self
        pillsTable.dataSource = self
        loadTabBarItemSize()
        insertInsertButton()
        pillsTable.allowsSelectionDuringEditing = true
        updateFromBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pillsTable.reloadData()
        reloadInputViews()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pillSchedule.count()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        typealias Cell = PillCell
        let pillCell = pillCellForRowAt(indexPath.row)
        let i = indexPath.row
        pillCell.index = i
        pillCell.load()
        return pillCell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let pill = pillSchedule.pills[indexPath.row]
        segueToPillView(for: pill, at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let title = PDActionStrings.delete
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
            let setter = shared.setPillDataForToday
            if let i = Int("\(restoreId.suffix(1))") {
                pillSchedule.takePill(at: i, setPDSharedData: setter)
                notifications.requestPillNotification(forPillAt: i)
                let cell = pillCellForRowAt(i)
                cell.stamp()
                if let pill = pillSchedule.getPill(at: i) {
                    cell.loadDueDateText(from: pill)
                    cell.loadStateImage(from: pill)
                    cell.loadLastTakenText(from: pill)
                }
                cell.enableOrDisableTake()
                pillsTable.reloadData()
                reloadInputViews()
            }
            setBadge()
        }
    }
    
    @objc func insertTapped() {
        let setter = shared.setPillDataForToday
        if let pill = pillSchedule.insert(completion: setter) as? MOPill,
            let i = pillSchedule.pills.firstIndex(of: pill) {
            pillsTable.reloadData()
            segueToPillView(for: pill, at: i)
        }
    }
    
    // MARK: - Private / Helpers
    
    private func segueToPillView(for pill: MOPill, at index: Index) {
        if let sb = storyboard, let navCon = navigationController,
            let pillVC = sb.instantiateViewController(withIdentifier: "PillVC_id") as? PillVC {
            pillVC.setPillIndex(index)
            navCon.pushViewController(pillVC, animated: true)
        }
    }
    
    private func pillCellForRowAt(_ index: Index) -> PillCell {
        let indexPath = IndexPath(row: index, section: 0)
        let id = "pillCellReuseId"
        return pillsTable.dequeueReusableCell(withIdentifier: id, for: indexPath) as! PillCell
    }
    
    private func deleteCell(at indexPath: IndexPath) {
        print(indexPath.row)
        pillSchedule.delete(at: indexPath.row)
        pillsTable.deleteRows(at: [indexPath], with: .fade)
        pillsTable.reloadData()

        let start_i = indexPath.row
        let end_i = pillSchedule.count() - 1
        if start_i <= end_i {
            // Reset cell colors
            for i in start_i...end_i {
                let cell = pillCellForRowAt(i)
                cell.index = i
                cell.setBackground()
            }
        }
        shared.setPillDataForToday()
        setBadge()
    }
    
    /// Updates the pill views when VC is reloaded from a notification.
    func updateFromBackground() {
        let name = UIApplication.willEnterForegroundNotification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: name,
                                               object: nil)
    }
    
    @objc func appWillEnterForeground() {
        pillsTable.reloadData()
    }
    
    private func setBadge() {
        let v = pillSchedule.totalDue()
        navigationController?.tabBarItem.badgeValue = (v > 0) ? "\(v)" : nil
    }
    
    private func loadTabBarItemSize() {
        let size: CGFloat = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ? 9 : 25
        let attrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: size)]
        self.navigationController?.tabBarItem.setTitleTextAttributes(attrs, for: .normal)
    }
    
    private func insertInsertButton() {
        let insertButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add,
                                           target: self,
                                           action: #selector(insertTapped))
        insertButton.tintColor = PDColors.getColor(.Green)
        navigationItem.rightBarButtonItems = [insertButton]
    }
    
    private func applyTheme() {
        let bgColor = app.theme.bgColor
        let borderColor = app.theme.borderColor
        pillsView.backgroundColor = bgColor
        pillsTable.backgroundColor = bgColor
        pillsTable.separatorColor = borderColor
    }
}
