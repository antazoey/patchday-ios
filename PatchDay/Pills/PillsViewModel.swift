//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillsViewModel: CodeBehindDependencies<PillsViewModel> {

	var pillsTable: PillsTable! = nil
	var viewFactory: PillsViewFactory

	init(pillsTableView: UITableView, viewFactory: PillsViewFactory) {
		self.viewFactory = viewFactory
		super.init()
		let tableWrapper = PillsTable(pillsTableView, pills: pills)
		self.pillsTable = tableWrapper
		watchForChanges()
	}

	var pills: PillScheduling? {
		sdk?.pills
	}

	var pillsCount: Int {
		pills?.count ?? 0
	}

	func createPillCellSwipeActions(index: IndexPath) -> UISwipeActionsConfiguration {
		let delete = viewFactory.createSiteCellDeleteSwipeAction {
			self.deletePill(at: index)
		}
		return UISwipeActionsConfiguration(actions: [delete])
	}

	func takePill(at index: Index) {
		guard let pills = pills else { return }
		guard let pill = pills[index] else { return }
		pills.swallow(pill.id) {
			self.tabs?.reflectDuePillBadgeValue()
			self.notifications?.requestDuePillNotification(pill)
			let params = PillCellConfigurationParameters(pill: pill, index: index)
			self.pillsTable[index].stamp().configure(params)
			self.pillsTable.reloadData()
		}
	}

	func deletePill(at index: IndexPath) {
		pills?.delete(at: index.row)
		let pillsCount = pills?.count ?? 0
		pillsTable.deleteCell(at: index, pillsCount: pillsCount)
	}

	func presentPillActions(at index: Index, viewController: UIViewController) {
        guard let pill = sdk?.pills[index] else { return }
		let goToDetails = { self.goToPillDetails(pillIndex: index, pillsViewController: viewController) }
		let takePill = { self.takePill(at: index) }
		let handlers = PillCellActionHandlers(goToDetails: goToDetails, takePill: takePill)
		alerts?.presentPillActions(for: pill, handlers: handlers)
	}

	func goToNewPillDetails(pillsViewController: UIViewController) {
		guard let pill = pills?.insertNew(onSuccess: nil) else { return }
		nav?.goToPillDetails(pill, source: pillsViewController)
	}

	func goToPillDetails(pillIndex: Index, pillsViewController: UIViewController) {
		guard let pill = pills?[pillIndex] else { return }
		nav?.goToPillDetails(pill, source: pillsViewController)
	}

	// MARK: - Private

	private func watchForChanges() {
		let name = UIApplication.willEnterForegroundNotification
		NotificationCenter.default.addObserver(
			self, selector: #selector(reloadDataFromBackgroundUpdate), name: name, object: nil
		)
	}

    @objc private func reloadDataFromBackgroundUpdate() {
        pillsTable.reloadData()
		tabs?.reflect()
    }
}
