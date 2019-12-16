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

    private var viewModel: PillsViewModel?
    
    @IBOutlet var pillsView: UIView!
    @IBOutlet weak var pillsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tableWrapper = PillsTable(pillsTable, pills: viewModel?.pills, theme: viewModel?.styles?.theme)
        viewModel = PillsViewModel(pillsTable: tableWrapper)
        applyTheme()
        title = VCTitleStrings.pillsTitle
        pillsTable.delegate = self
        pillsTable.dataSource = self
        insertInsertButton()
        pillsTable.allowsSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pillsTable.reloadData()
        reloadInputViews()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.pills?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel?.pillsTable.getCell(at: indexPath.row) ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.goToPillDetails(pillIndex: indexPath.row, pillsViewModel: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        PillCell.RowHeight
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
        if let pillIndex = (sender as? UIButton)?.restoreSuffix() {
            viewModel?.takePill(at: pillIndex)
            self.reloadInputViews()
        }
    }

    // MARK: - Private / Helpers

    private func deleteCell(at indexPath: IndexPath) {
        viewModel?.deletePill(at: indexPath)
    }
    
    private func insertInsertButton() {
        let insertButton = PillsViewFactory.createInsertButton(action: #selector(viewModel?.handleInsertNewPill))
        navigationItem.rightBarButtonItems = [insertButton]
    }
    
    private func applyTheme() {
        if let theme = viewModel?.styles?.theme {
            let bgColor = theme[.bg]
            let borderColor = theme[.border]
            pillsView.backgroundColor = bgColor
            pillsTable.backgroundColor = bgColor
            pillsTable.separatorColor = borderColor
        }
    }
}
