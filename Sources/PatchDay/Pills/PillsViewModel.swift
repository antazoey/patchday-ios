//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillsViewModel: CodeBehindDependencies<PillsViewModel>, PillsViewModelProtocol {

    var pillsTable: PillsTableProtocol! = nil

    init(pillsTableView: UITableView) {
        super.init()
        let tableWrapper = PillsTable(pillsTableView, pills: pills)
        self.pillsTable = tableWrapper
        finishInit()
    }

    init(
        pillsTableView: UITableView,
        alertFactory: AlertProducing? = nil,
        table: PillsTableProtocol,
        dependencies: DependenciesProtocol
    ) {
        super.init(
            sdk: dependencies.sdk,
            tabs: dependencies.tabs,
            notifications: dependencies.notifications,
            alerts: dependencies.alerts,
            nav: dependencies.nav,
            badge: dependencies.badge
        )
        self.pillsTable = table
        self.finishInit()
    }

    var pills: PillScheduling? { sdk?.pills }

    var pillsCount: Int { pills?.count ?? 0 }

    func createPillCellSwipeActions(index: IndexPath) -> UISwipeActionsConfiguration {
        let title = ActionStrings.Delete
        let delete = UIContextualAction(style: .normal, title: title) {
            _, _, _ in self.deletePill(at: index)
        }
        delete.backgroundColor = UIColor.red
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func takePill(at index: Index) {
        guard let pills = pills else { return }
        guard let pill = pills[index] else { return }
        pills.swallow(pill.id) {
            self.notifications?.requestDuePillNotification(pill)
            let params = PillCellConfigurationParameters(pill: pill, index: index)
            let cell = self.pillsTable[index]
            cell.stamp().configure(params)
            self.pillsTable.reloadData()
            self.badge?.reflect()
            if let pill = self.sdk?.pills[index] {
                self.notifications?.requestDuePillNotification(pill)
            }
        }
        self.tabs?.reflectPills()
    }

    func deletePill(at index: IndexPath) {
        pills?.delete(at: index.row)
        let pillsCount = pills?.count ?? 0
        pillsTable.deleteCell(at: index, pillsCount: pillsCount)
    }

    func presentPillActions(
        at index: Index, viewController: UIViewController, takePillCompletion: @escaping () -> Void
    ) {
        guard let pill = sdk?.pills[index] else { return }
        let goToDetails = {
            self.goToPillDetails(pillIndex: index, pillsViewController: viewController)
        }
        let takePill = {
            self.takePill(at: index)
            takePillCompletion()
        }
        let handlers = PillCellActionHandlers(goToDetails: goToDetails, takePill: takePill)
        let alert = self.alerts?.createPillActions(pill, handlers)
        alert?.present()
    }

    func goToNewPillDetails(pillsViewController: UIViewController) {
        guard let pill = pills?.insertNew(onSuccess: nil) else { return }
        guard let index = sdk?.pills.indexOf(pill) else { return }
        goToPillDetails(pillIndex: index, pillsViewController: pillsViewController)
    }

    func goToPillDetails(pillIndex: Index, pillsViewController: UIViewController) {
        guard let pills = pills else { return }
        guard pillIndex >= 0 && pillIndex < pills.count else { return }
        nav?.goToPillDetails(pillIndex, source: pillsViewController)
    }

    // MARK: - Private

    private func finishInit() {
        tabs?.reflectPills()
        watchForChanges()
    }

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
