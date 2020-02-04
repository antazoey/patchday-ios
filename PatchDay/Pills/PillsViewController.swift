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

class PillsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var viewModel: PillsViewModel!
    private var viewFactory: PillsViewFactory!
    
    @IBOutlet var pillsView: UIView!
    @IBOutlet weak var pillsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModelIfNil()
        applyTheme()
        title = VCTitleStrings.PillsTitle
        pillsTableView.delegate = self
        pillsTableView.dataSource = self
        insertInsertBarButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initViewModelIfNil()
        viewModel.pillsTable.reloadData()
        reloadInputViews()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.pills?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel.pillsTable.getCell(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.goToPillDetails(pillIndex: indexPath.row, pillsViewController: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        PillCell.RowHeight
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        viewModel.createPillCellSwipeActions(index: indexPath)
    }
    
    @IBAction func takeButtonTapped(_ sender: Any) {
        if let pillIndex = (sender as? UIButton)?.restoreSuffix() {
            viewModel.takePill(at: pillIndex)
            self.reloadInputViews()
        }
    }

    // MARK: - Private / Helpers

    private func initViewModelIfNil() {
        if viewModel == nil {
            viewFactory = PillsViewFactory(insertButtonAction: handleInsertNewPill)
            viewModel = PillsViewModel(pillsTableView: pillsTableView, viewFactory: viewFactory)
        }
    }
    
    private func insertInsertBarButtonItem() {
        let insertButton = viewFactory.createInsertButton()
        navigationItem.rightBarButtonItems = [insertButton]
    }
    
    private func applyTheme() {
        if let theme = viewModel.styles?.theme {
            pillsView.backgroundColor = theme[.bg]
        }
    }
    
    @objc private func handleInsertNewPill() {
        viewModel.goToNewPillDetails(pillsViewController: self)
    }
}
