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

    private var pills: [Swallowable] {
        guard pillsEnabled, let pills = container.sdk?.pills else { return [] }
        return (0..<pills.count).compactMap { pills[$0] }
    }

    var body: some View {
        List {
            if pillsEnabled {
                ForEach(Array(pills.enumerated()), id: \.element.id) { index, pill in
                    PillRow(pill: pill, onTake: { take(at: index) })
                        .contentShape(Rectangle())
                        .onTapGesture { container.goToPillDetail(index) }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deletePill(at: index)
                            } label: {
                                Label(ActionStrings.Delete, systemImage: "trash")
                            }
                            .accessibilityIdentifier("pillDeleteButton_\(index)")
                        }
                        .accessibilityIdentifier("PillCell_\(index)")
                }
                .id(container.refreshTick)
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
                    .onChange(of: pillsEnabled) { newValue in
                        togglePillsEnabled(newValue)
                    }
                    .accessibilityIdentifier("enablePillsSwitch")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addNew) {
                    Image(systemName: "plus")
                }
                .disabled(!pillsEnabled)
                .accessibilityIdentifier("pillsAddButton")
            }
        }
        .onAppear {
            pillsEnabled = container.sdk?.settings.pillsEnabled.rawValue ?? true
            container.refreshBadges()
        }
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
