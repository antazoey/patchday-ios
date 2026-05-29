//
//  PillsListView.swift
//  PatchDay
//
//  SwiftUI replacement for PillsViewController.
//

import SwiftUI
import PDKit
import WidgetKit

struct PillsListView: View {

    @EnvironmentObject private var container: AppContainer

    @State private var pillsEnabled: Bool = true
    @State private var tapTarget: PillTapTarget?
    @State private var pendingRemoveIndex: Int?

    private struct PillTapTarget: Identifiable {
        let id = UUID()
        let index: Index
        let name: String
        let isDone: Bool
    }

    private var pills: [Swallowable] {
        guard pillsEnabled, let pills = container.sdk?.pills else { return [] }
        return (0..<pills.count).compactMap { pills[$0] }
    }

    var body: some View {
        List {
            if pillsEnabled {
                ForEach(Array(pills.enumerated()), id: \.element.id) { index, pill in
                    Button {
                        tapTarget = PillTapTarget(
                            index: index,
                            name: pill.name,
                            isDone: pill.isDone
                        )
                    } label: {
                        PillRow(pill: pill)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            pendingRemoveIndex = index
                        } label: {
                            Label(ActionStrings.Delete, systemImage: "trash")
                        }
                        .accessibilityIdentifier("pillDeleteButton_\(index)")
                    }
                    .accessibilityIdentifier("PillCell_\(index)")
                }
                .id(container.refreshTick)

                GhostPillRow()
                    .contentShape(Rectangle())
                    .onTapGesture { addNew() }
                    .accessibilityIdentifier("GhostPillCell")
            } else {
                Section {
                    Text(NSLocalizedString("Pills are disabled.", comment: "Empty pills state"))
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("pillsDisabledLabel")
                }
            }
        }
        .listStyle(.plain)
        .accessibilityIdentifier("pillsList")
        .navigationTitle(PDTitleStrings.PillsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Toggle(NSLocalizedString("Enable", comment: ""), isOn: $pillsEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .onChange(of: pillsEnabled) { _, newValue in
                        togglePillsEnabled(newValue)
                    }
                    .accessibilityIdentifier("enablePillsSwitch")
            }
        }
        .confirmationDialog(
            tapTarget?.name ?? "",
            isPresented: tapDialogBinding,
            titleVisibility: .visible,
            presenting: tapTarget
        ) { target in
            if !target.isDone {
                Button(ActionStrings.Take) {
                    take(at: target.index)
                }
            }
            Button(ActionStrings.Edit) {
                container.goToPillDetail(target.index)
            }
            Button(NSLocalizedString("Remove pill", comment: ""), role: .destructive) {
                let index = target.index
                tapTarget = nil
                pendingRemoveIndex = index
            }
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .alert(
            NSLocalizedString("Remove this pill from your schedule?", comment: ""),
            isPresented: removeAlertBinding,
            presenting: pendingRemoveIndex
        ) { _ in
            Button(NSLocalizedString("Remove", comment: ""), role: .destructive) {
                applyRemovePill()
            }
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .onAppear {
            pillsEnabled = container.sdk?.settings.pillsEnabled.rawValue ?? true
            container.refreshBadges()
        }
    }

    private var tapDialogBinding: Binding<Bool> {
        Binding(get: { tapTarget != nil }, set: { if !$0 { tapTarget = nil } })
    }

    private var removeAlertBinding: Binding<Bool> {
        Binding(get: { pendingRemoveIndex != nil }, set: { if !$0 { pendingRemoveIndex = nil } })
    }

    private func applyRemovePill() {
        guard let index = pendingRemoveIndex else { return }
        deletePill(at: index)
    }

    private func take(at index: Index) {
        guard let pills = container.sdk?.pills,
            let pill = pills[index] else { return }
        pills.swallow(pill.id) {
            container.notifications?.requestDuePillNotification(pill)
            container.badge?.reflect()
            container.widget?.set()
            container.triggerRefresh()
        }
    }

    private func deletePill(at index: Index) {
        container.sdk?.pills.delete(at: index)
        container.triggerRefresh()
    }

    private func addNew() {
        guard let pills = container.sdk?.pills,
            let pill = pills.insertNew(onSuccess: nil) else { return }
        guard let index = container.sdk?.pills.indexOf(pill) else { return }
        container.triggerRefresh()
        container.goToPillDetail(index)
    }

    private func togglePillsEnabled(_ on: Bool) {
        container.sdk?.settings.setPillsEnabled(to: on)
        if on {
            container.notifications?.cancelAllDuePillNotifications()
            container.notifications?.requestAllDuePillNotifications()
        } else {
            container.notifications?.cancelAllDuePillNotifications()
        }
        container.widget?.set()
        container.refreshBadges()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
