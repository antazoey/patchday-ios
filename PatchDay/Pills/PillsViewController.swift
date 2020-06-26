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

	@IBOutlet var pillsView: UIView!
	@IBOutlet weak var pillsTableView: UITableView!

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
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.pillsCount
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		viewModel.pillsTable[indexPath.row]
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		viewModel.presentPillActions(at: indexPath.row, viewController: self) {
			self.initViewModel()
			self.pillsTableView.reloadRows(at: [indexPath], with: .none)
			self.viewModel.tabs?.reflectPills()
			self.viewModel.badge?.reflect()
			if let pill = self.viewModel.sdk?.pills[indexPath.row] {
				self.viewModel.notifications?.requestDuePillNotification(pill)
			}
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

	@IBAction func takeButtonTapped(_ sender: Any) {
		guard let pillIndex = (sender as? UIButton)?.restoreSuffix() else { return }
		viewModel.takePill(at: pillIndex)
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
}
