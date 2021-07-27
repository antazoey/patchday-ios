//
//  PillsViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 12/16/17.

import UIKit
import PDKit
import WidgetKit

typealias PillName = String

class PillsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var viewModel: PillsViewModelProtocol!

    @IBOutlet var pillsView: UIView!
    @IBOutlet weak var pillsTableView: UITableView!
    @IBOutlet weak var enablePillsSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        willEnterForeground()
        title = PDTitleStrings.PillsTitle
        pillsTableView.delegate = self
        pillsTableView.dataSource = self
        loadBarButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        willEnterForeground()
        super.viewDidAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.tabs?.reflectHormones()
    }

    @objc func willEnterForeground() {
        initViewModel()
        viewModel.pillsTable.reloadData()
        reloadInputViews()
        applyTheme()
        loadPillsEnabled()
        WidgetCenter.shared.reloadAllTimelines()
    }

    @IBAction func enablePillsSwitchToggled(_ sender: Any) {
        guard let switchObj = sender as? UISwitch else { return }
        viewModel.togglePillsEnabled(switchObj.isOn)
        pillsTableView.reloadData()
        setTableBackgroundView()
        if let items = navigationItem.rightBarButtonItems, items.count > 0 {
            items[0].isEnabled = switchObj.isOn
        }
    }

    // MARK: - Table Delegate Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.pillsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel.pillsTable[indexPath.row] as! UITableViewCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.presentPillActions(at: indexPath.row, viewController: self) {
            self.initViewModel()
            self.pillsTableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        PillCell.RowHeight
    }

    func tableView(
        _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        viewModel.createPillCellSwipeActions(index: indexPath)
    }

    // MARK: - Private / Helpers

    private func initViewModel() {
        viewModel = PillsViewModel(pillsTableView: pillsTableView)
    }

    private func loadBarButtons() {
        let insertButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.add,
            target: self,
            action: #selector(handleInsertNewPill)
        )
        insertButton.tintColor = PDColors[.NewItem]
        insertButton.isEnabled = viewModel.enabled
        navigationItem.rightBarButtonItems = [insertButton]
        let backItem = PDViewFactory.createTextBarButtonItem(PDTitleStrings.PillTitle)
        navigationItem.backBarButtonItem = backItem
    }

    private func applyTheme() {
        pillsView.backgroundColor = UIColor.systemBackground
    }

    @objc private func handleInsertNewPill() {
        viewModel.goToNewPillDetails(pillsViewController: self)
    }

    private func loadPillsEnabled() {
        enablePillsSwitch.isOn = viewModel.enabled
        setTableBackgroundView()
    }

    private func setTableBackgroundView() {
        pillsTableView.reloadData()
        viewModel.setBackgroundView()
    }
}
