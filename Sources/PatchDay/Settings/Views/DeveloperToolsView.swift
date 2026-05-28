//
//  DeveloperToolsView.swift
//  PatchDay
//
//  DEBUG-only menu for verifying iCloud sync, CoreData state, and
//  exercising the various CLI test modes without editing the Xcode scheme.
//  Reachable via Settings → Developer tools when the app was built in DEBUG.
//

#if DEBUG
import SwiftUI
import CoreData
import PDKit
import PatchData

struct DeveloperToolsView: View {

    @EnvironmentObject private var container: AppContainer
    @State private var entityCounts: [String: Int] = [:]
    @State private var lastEventDescription: String = ""
    @State private var lastSyncDate: Date?
    @State private var historyTokenStatus: String = ""
    @State private var iCloudAccountStatus: CloudKitAccountStatusChecker.Status = .unknown
    @State private var wipeOnNextLaunch: Bool = false
    @State private var actionResultMessage: String?
    @State private var showWipeICloudConfirm = false

    var body: some View {
        Form {
            Section(NSLocalizedString("CloudKit", comment: "")) {
                LabeledContent(NSLocalizedString("Account", comment: ""),
                               value: accountLabel)
                LabeledContent(NSLocalizedString("Last event", comment: ""),
                               value: lastEventDescription.isEmpty ? "—" : lastEventDescription)
                if let lastSyncDate = lastSyncDate {
                    LabeledContent(NSLocalizedString("Last successful sync", comment: ""),
                                   value: lastSyncDate.formatted(date: .abbreviated, time: .standard))
                }
                LabeledContent(NSLocalizedString("History token", comment: ""),
                               value: historyTokenStatus)
            }

            Section(NSLocalizedString("Entity counts (local)", comment: "")) {
                ForEach(entityCounts.sorted(by: { $0.key < $1.key }), id: \.key) { name, count in
                    LabeledContent(name, value: "\(count)")
                }
            }

            Section(NSLocalizedString("Sync actions", comment: "")) {
                Button(NSLocalizedString("Refresh state", comment: "")) {
                    loadState()
                }
                Button(NSLocalizedString("Force CoreData save (triggers export)", comment: "")) {
                    container.forceCoreDataSave()
                    actionResultMessage = "Save triggered. Watch Last event row."
                    loadState()
                }
                Button(NSLocalizedString("Reload schedules from store", comment: "")) {
                    container.sdk?.hormones.reloadContext()
                    container.sdk?.pills.reloadContext()
                    container.sdk?.sites.reloadContext()
                    container.triggerRefresh()
                    actionResultMessage = "Schedules reloaded. Switch tabs to see updated data."
                    loadState()
                }
                Button(NSLocalizedString("Trim phantom empty hormones", comment: "")) {
                    let trimmed = container.sdk?.hormones.trimPhantomEmpties() ?? 0
                    container.triggerRefresh()
                    actionResultMessage = trimmed == 0
                        ? "No phantoms to trim."
                        : "Trimmed \(trimmed) empty hormone(s) beyond Quantity. Sync will propagate the deletes to other devices."
                    loadState()
                }
                Toggle(NSLocalizedString("Wipe local store on next launch", comment: ""),
                       isOn: $wipeOnNextLaunch)
                    .onChange(of: wipeOnNextLaunch) { _, value in
                        UserDefaults.standard.set(
                            value,
                            forKey: PDLocalSettingsKey.wipeLocalStoreOnNextLaunch.rawValue
                        )
                    }
                Button(role: .destructive) {
                    showWipeICloudConfirm = true
                } label: {
                    Text(NSLocalizedString("Purge iCloud data (this Apple ID)", comment: ""))
                }
            }

            Section(NSLocalizedString("CLI test modes", comment: "")) {
                Text(NSLocalizedString(
                    "These are the same flags Xcode schemes pass. They take effect on the next cold launch — close the app from the app switcher after toggling.",
                    comment: ""
                ))
                .font(.footnote)
                .foregroundColor(.secondary)
                Button(NSLocalizedString("Schedule --nuke-storage for next launch", comment: "")) {
                    CommandLine.arguments.append("--nuke-storage")
                    actionResultMessage = "Nuke scheduled. Force-quit + relaunch."
                }
                Button(NSLocalizedString("Schedule --notifications-test for next launch", comment: "")) {
                    CommandLine.arguments.append("--notifications-test")
                    actionResultMessage = "Notifications test scheduled. Force-quit + relaunch."
                }
                Button(NSLocalizedString("Schedule --wakeup-test for next launch", comment: "")) {
                    CommandLine.arguments.append("--wakeup-test")
                    actionResultMessage = "Wake-up test scheduled. Force-quit + relaunch."
                }
            }

            if let message = actionResultMessage {
                Section {
                    Text(message)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(NSLocalizedString("Developer tools", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadState)
        .confirmationDialog(
            NSLocalizedString("Delete every iCloud record for this Apple ID? Local data is unaffected.", comment: ""),
            isPresented: $showWipeICloudConfirm,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("Purge iCloud data", comment: ""), role: .destructive) {
                container.purgeICloudData { error in
                    actionResultMessage = error
                        .map { "iCloud purge failed: \($0.localizedDescription)" }
                        ?? "iCloud purge complete."
                }
            }
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
    }

    private var accountLabel: String {
        switch iCloudAccountStatus {
            case .available: return NSLocalizedString("Available", comment: "")
            case .noAccount: return NSLocalizedString("Not signed in", comment: "")
            case .restricted: return NSLocalizedString("Restricted", comment: "")
            case .unknown: return NSLocalizedString("Checking…", comment: "")
        }
    }

    private func loadState() {
        let defaults = UserDefaults.standard
        lastEventDescription = defaults.string(
            forKey: PDLocalSettingsKey.lastCloudKitEventDescription.rawValue
        ) ?? ""
        lastSyncDate = defaults.object(
            forKey: PDLocalSettingsKey.lastICloudSyncDate.rawValue
        ) as? Date
        wipeOnNextLaunch = defaults.bool(
            forKey: PDLocalSettingsKey.wipeLocalStoreOnNextLaunch.rawValue
        )
        let tokenData = defaults.data(
            forKey: PDLocalSettingsKey.lastHistoryToken.rawValue
        )
        historyTokenStatus = tokenData == nil ? "—" : "set (\(tokenData!.count)B)"
        entityCounts = computeEntityCounts()
        CloudKitAccountStatusChecker().check { status in
            iCloudAccountStatus = status
        }
    }

    private func computeEntityCounts() -> [String: Int] {
        let context = CoreDataStack.context
        var result: [String: Int] = [:]
        for name in ["Estrogen", "Pill", "Site"] {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            result[name] = (try? context.count(for: request)) ?? -1
        }
        return result
    }
}
#endif
