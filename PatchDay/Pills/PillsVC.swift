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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = PDStrings.VCTitles.pills
        pillTable.delegate = self
        pillTable.dataSource = self
        loadTabBarItemSize()
        let insertButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(insertTapped))
        insertButton.tintColor = PDColors.getColor(.Green)
        navigationItem.rightBarButtonItems = [insertButton]
        pillTable.allowsSelectionDuringEditing = true
        updateFromBackground()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pillTable.reloadData()
        reloadInputViews()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PillScheduleRef.count()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        typealias Cell = PillTableViewCell
        let cell = pillCellForRowAt(indexPath.row)
        let i = indexPath.row
        if i >= 0 && i < PillScheduleRef.pills.count {
            cell?.configure(using: PillScheduleRef.pills[i], at: i)
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let pill = PillScheduleRef.pills[indexPath.row]
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
            let setter = PDSharedDataRef.setPillDataForToday
            if let i = Int("\(restoreId.suffix(1))") {
                PillScheduleRef.takePill(at: i, setPDSharedData: setter)
                appDelegate.notificationsController.requestNotifyTakePill(at: i)
                let cell = pillCellForRowAt(i)
                cell?.stamp()
                if let pill = PillScheduleRef.getPill(at: i) {
                    cell?.loadDueDateText(from: pill)
                    cell?.loadStateImage(from: pill)
                    cell?.loadLastTakenText(from: pill)
                }
                cell?.enableOrDisableTake()
                pillTable.reloadData()
                reloadInputViews()
            }
            setBadge()
        }
    }
    
    @objc func insertTapped() {
        let setter = PDSharedDataRef.setPillDataForToday
        if let pill = PillScheduleRef.insert(completion: setter) as? MOPill,
            let i = PillScheduleRef.pills.index(of: pill) {
            pillTable.reloadData()
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
    
    private func pillCellForRowAt(_ index: Index) -> PillTableViewCell? {
        let indexPath = IndexPath(row: index, section: 0)
        let id = "pillCellReuseId"
        return pillTable.dequeueReusableCell(withIdentifier: id, for: indexPath) as? PillTableViewCell
    }
    
    private func deleteCell(at indexPath: IndexPath) {
        print(indexPath.row)
        PillScheduleRef.delete(at: indexPath.row)
        pillTable.deleteRows(at: [indexPath], with: .fade)
        pillTable.reloadData()

        let start_i = indexPath.row
        let end_i = PillScheduleRef.count() - 1
        if start_i <= end_i {
            // Reset cell colors
            for i in start_i...end_i {
                let cell = pillCellForRowAt(i)
                cell?.setIndex(to: i)
                cell?.setBackground()
            }
        }
        PDSharedDataRef.setPillDataForToday()
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
        let v = PillScheduleRef.totalDue()
        navigationController?.tabBarItem.badgeValue = (v > 0) ? "\(v)" : nil
    }
    
    private func loadTabBarItemSize() {
        let size: CGFloat = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ? 9 : 25
        let attrs = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: size)]
        self.navigationController?.tabBarItem.setTitleTextAttributes(attrs, for: .normal)
    }
}
