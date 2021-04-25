//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillsViewModel: CodeBehindDependencies<PillsViewModel>, PillsViewModelProtocol {

    var pillsTable: PillsTableProtocol! = nil

    private let undoState = PillUndoState()

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
            badge: dependencies.badge,
            widget: dependencies.widget
        )
        self.pillsTable = table
        self.finishInit()
    }

    var pills: PillScheduling? { sdk?.pills }

    var pillsCount: Int {
        guard enabled else { return 0 }
        return pills?.count ?? 0
    }

    var enabled: Bool { sdk?.settings.pillsEnabled.rawValue ?? true }

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

        // Cache old lastTaken for undo-ing
        undoState.set(at: index, lastTaken: pill.lastTaken)

        pills.swallow(pill.id) {
            self.handlePillTakenTimesChanged(at: index, for: pill)
        }
        self.tabs?.reflectPills()
    }

    func undoTakePill(at index: Index) {
        guard let pills = pills else { return }
        guard let pill = pills[index] else { return }
        let lastLastTaken = undoState.popLastTaken(index: index)
        pills.unswallow(pill.id, lastTaken: lastLastTaken) {
            self.handlePillTakenTimesChanged(at: index, for: pill)
        }
        self.tabs?.reflectPills()
    }

    func deletePill(at index: IndexPath) {
        pills?.delete(at: index.row)
        let pillsCount = pills?.count ?? 0
        pillsTable.deleteCell(at: index, pillsCount: pillsCount)
    }

    func presentPillActions(
        at index: Index,
        viewController: UIViewController,
        reloadViews: @escaping () -> Void
    ) {
        guard let pill = sdk?.pills[index] else { return }
        let goToDetails = {
            self.goToPillDetails(pillIndex: index, pillsViewController: viewController)
        }
        let takePill = {
            self.takePill(at: index)
            reloadViews()
        }
        let undoTake = {
            self.undoTakePill(at: index)
            reloadViews()
        }
        let handlers = PillCellActionHandlers(
            goToDetails: goToDetails, takePill: takePill, undoTakePill: undoTake
        )
        if let alert = self.alerts?.createPillActions(pill, handlers) {
            alert.present()
        }
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

    func togglePillsEnabled(_ toggledOn: Bool) {
        guard enabled != toggledOn else { return }
        sdk?.settings.setPillsEnabled(to: toggledOn)
        if toggledOn {
            tabs?.reflectPills()
            notifications?.cancelAllDuePillNotifications()
            notifications?.requestAllDuePillNotifications()
        } else {
            tabs?.clearPills()
            notifications?.cancelAllDuePillNotifications()
        }
        widget?.set()
    }

    func setBackgroundView() {
        pillsTable.setBackgroundView(isEnabled: enabled)
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

    private func handlePillTakenTimesChanged(at index: Index, for pill: Swallowable) {
        self.notifications?.requestDuePillNotification(pill)
        let params = PillCellConfigurationParameters(pill: pill, index: index)
        self.pillsTable[index].configure(params)
        self.pillsTable.reloadData()
        self.badge?.reflect()
        self.notifications?.requestDuePillNotification(pill)
    }
}
