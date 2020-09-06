//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillsViewModel: CodeBehindDependencies<PillsViewModel> {

    var pillsTable: PillsTable! = nil

    init(pillsTableView: UITableView) {
        super.init()
        finishInit(pillsTableView)
    }

    init(
        pillsTableView: UITableView,
        alertFactory: AlertProducing? = nil,
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
        self.finishInit(pillsTableView)
    }

    private func finishInit(_ pillsTableView: UITableView) {
        let tableWrapper = PillsTable(pillsTableView, pills: pills)
        self.pillsTable = tableWrapper
        tabs?.reflectPills()
        watchForChanges()
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
            self.pillsTable[index].stamp().configure(params)
            self.pillsTable.reloadData()
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
        let goToDetails = { self.goToPillDetails(pillIndex: index, pillsViewController: viewController) }
        let takePill = {
            _ = self.takePill(at: index)
            takePillCompletion()
            self.tabs?.reflectPills()
            self.badge?.reflect()
            if let pill = self.sdk?.pills[index] {
                self.notifications?.requestDuePillNotification(pill)
            }
        }
        let handlers = PillCellActionHandlers(goToDetails: goToDetails, takePill: takePill)
        let alert = self.alerts?.createPillActions(pill, handlers)
        alert?.present()
    }

    func goToNewPillDetails(pillsViewController: UIViewController) {
        guard let pill = pills?.insertNew(onSuccess: nil) else { return }
        guard let index = sdk?.pills.indexOf(pill) else { return }
        nav?.goToPillDetails(index, source: pillsViewController)
    }

    func goToPillDetails(pillIndex: Index, pillsViewController: UIViewController) {
        nav?.goToPillDetails(pillIndex, source: pillsViewController)
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
