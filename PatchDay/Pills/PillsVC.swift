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
    
    @IBOutlet var pillsView: UIView!
    @IBOutlet weak var pillsTable: UITableView!
    
    // Dependencies
    private var pills: PillScheduling? = app?.sdk.pills
    private let notifications: PDNotificationScheduling? = app?.notifications
    private let navigation: PDNavigationDelegate? = app?.nav
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        title = PDVCTitleStrings.pillsTitle
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
        return pills?.count ?? 0
    }
    
    func tableView(
        _ tableView: UITableView, cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        return pillCellForRowAt(indexPath.row).load(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let pill = pills?.at(indexPath.row) {
            segueToPillView(for: pill)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(
        _ tableView: UITableView, editActionsForRowAt indexPath: IndexPath
    ) -> [UITableViewRowAction]? {
        let title = ActionStrings.delete
        let delete = UITableViewRowAction(style: .normal, title: title) {
            (action, index) in
            self.deleteCell(at: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    
    @IBAction func takeButtonTapped(_ sender: Any) {
        // Acquire Pill Id from cell's takeButton restore Id.
        if let button = sender as? UIButton,
            let pillIndex = button.restoreSuffix(),
            let pills = pills,
            let pill = pills.at(pillIndex) {
            pills.swallow(pill) {
                self.notifications?.requestDuePillNotification(pill)
                self.pillCellForRowAt(pillIndex).stamp().load(at: pillIndex)
                self.pillsTable.reloadData()
                self.reloadInputViews()
                self.setBadge()
            }
        }
    }
    
    @objc func insertTapped() {
        if let pill = app?.sdk.pills.insertNew(completion: pillsTable.reloadData) {
            segueToPillView(for: pill)
        }
    }
    
    // MARK: - Private / Helpers
    
    private func segueToPillView(for pill: Swallowable) {
        navigation?.goToPillDetails(pill, source: self)
    }
    
    private func pillCellForRowAt(_ index: Index) -> PillCell {
        let indexPath = IndexPath(row: index, section: 0)
        let id = "pillCellReuseId"
        return pillsTable.dequeueReusableCell(withIdentifier: id, for: indexPath) as! PillCell
    }
    
    private func deleteCell(at indexPath: IndexPath) {
        if let sdk = sdk {
            sdk.deletePill(at: indexPath.row)
            pillsTable.deleteRows(at: [indexPath], with: .fade)
            pillsTable.reloadData()
            setBadge()
            let start = indexPath.row
            let end = sdk.pills.count - 1
            if start <= end {
                for i in start...end {
                    pillCellForRowAt(i).loadBackground()
                }
            }
        }
    }
    
    /// Updates the pill views when VC is reloaded from a notification.
    func updateFromBackground() {
        let name = UIApplication.willEnterForegroundNotification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pillsTable.reloadData),
            name: name,
            object: nil
        )
    }
    
    private func setBadge() {
        let v = sdk?.pills.totalDue ?? 0
        navigationController?.tabBarItem.badgeValue = v > 0 ? "\(v)" : nil
    }
    
    private func loadTabBarItemSize() {
        let size: CGFloat = AppDelegate.isPad ? 25 : 9
        let attrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: size)]
        self.navigationController?.tabBarItem.setTitleTextAttributes(attrs, for: .normal)
    }
    
    private func insertInsertButton() {
        let insertButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.add,
            target: self,
            action: #selector(insertTapped)
        )
        insertButton.tintColor = PDColors.get(.Green)
        navigationItem.rightBarButtonItems = [insertButton]
    }
    
    private func applyTheme() {
        if let theme = app?.styles.theme {
            let bgColor = theme[.bg]
            let borderColor = theme[.border]
            pillsView.backgroundColor = bgColor
            pillsTable.backgroundColor = bgColor
            pillsTable.separatorColor = borderColor
        }
    }
}
