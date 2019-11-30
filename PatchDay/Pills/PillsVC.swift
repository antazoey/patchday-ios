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

    private let viewModel = PillsCodeBehind()
    private var pillsTableWrapper: PillsTable?
    
    @IBOutlet var pillsView: UIView!
    @IBOutlet weak var pillsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pillsTableWrapper = PillsTable(pillsTable)
        applyTheme()
        title = VCTitleStrings.pillsTitle
        pillsTable.delegate = self
        pillsTable.dataSource = self
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
        viewModel.sdk?.pills.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        pillsTableWrapper?.getCellForRowAt(indexPath.row)?.load(at: indexPath.row) ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let pill = viewModel.pills?.at(indexPath.row) {
            segueToPillView(for: pill)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        170.0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let title = ActionStrings.delete
        let delete = UITableViewRowAction(style: .normal, title: title) {
            (action, index) in self.deleteCell(at: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    
    @IBAction func takeButtonTapped(_ sender: Any) {
        if let button = sender as? UIButton,
           let pillIndex = button.restoreSuffix(),
           let pill = viewModel.takePill(at: pillIndex) {

            self.viewModel.notifications?.requestDuePillNotification(pill)
            self.pillsTableWrapper?.getCellForRowAt(pillIndex)?.stamp().load(pill, pillIndex: pillIndex)
            self.pillsTable.reloadData()
            self.reloadInputViews()
        }
    }
    
    @objc func insertTapped() {
        if let pill = app?.sdk.pills.insertNew(completion: pillsTable.reloadData) {
            segueToPillView(for: pill)
        }
    }
    
    // MARK: - Private / Helpers
    
    private func segueToPillView(for pill: Swallowable) {
        viewModel.nav?.goToPillDetails(pill, source: self)
    }
    
    private func deleteCell(at indexPath: IndexPath) {
        viewModel.pills?.delete(at: indexPath.row)
        let pillsCount = viewModel.pills?.count ?? 0
        pillsTableWrapper?.deleteCell(at: indexPath, pillsCount: pillsCount)
    }
    
    /// Updates the pill views when VC is reloaded from a notification.
    func updateFromBackground() {
        let name = UIApplication.willEnterForegroundNotification
        NotificationCenter.default.addObserver(
            self, selector: #selector(pillsTable.reloadData), name: name, object: nil
        )
    }
    
    private func insertInsertButton() {
        let insertButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(insertTapped)
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

extension UITableView {

    func dequeuePillCell() -> PillCell? {
        dequeueReusableCell(withIdentifier: "pillCellReuseId") as? PillCell
    }
}

