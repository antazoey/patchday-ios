//
//  HormonesListView.swift
//  PatchDay
//
//  SwiftUI replacement for HormonesViewController. Reads hormone state
//  directly from the PatchData SDK exposed via AppContainer. A small no-op
//  HormonesTableProtocol lets us still instantiate HormonesViewModel so the
//  change-hormone command logic stays in one place (no parallel
//  implementation).
//

import SwiftUI
import PDKit

struct HormonesListView: View {

    @EnvironmentObject private var container: AppContainer

    @State private var tapTarget: TapTarget?
    @State private var showDisclaimer = false

    private struct TapTarget: Identifiable {
        let id = UUID()
        let index: Index
        let currentSite: SiteName
        let suggestedSite: SiteName?
        let change: () -> Void
    }

    private var quantity: Int {
        container.sdk?.settings.quantity.rawValue ?? 0
    }

    private var title: String {
        guard let method = container.sdk?.settings.deliveryMethod.value else {
            return PDTitleStrings.HormonesTitle
        }
        return PDTitleStrings.Hormones[method]
    }

    var body: some View {
        List {
            ForEach(0..<SUPPORTED_HORMONE_UPPER_QUANTITY_LIMIT, id: \.self) { index in
                if index < quantity, let sdk = container.sdk {
                    let vm = HormoneCellViewModel(cellIndex: index, sdk: sdk, isPad: container.isPad)
                    Button {
                        handleRowTap(at: index)
                    } label: {
                        HormoneRow(viewModel: vm)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color(vm.backgroundColor))
                    .accessibilityIdentifier("HormoneCell_\(index)")
                }
            }
            .id(container.refreshTick) // force re-evaluation after mutations
        }
        .listStyle(.plain)
        .accessibilityIdentifier("hormonesList")
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    container.goToSettings()
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityIdentifier("settingsGearButton")
            }
        }
        .confirmationDialog(
            confirmationTitle,
            isPresented: confirmationBinding,
            titleVisibility: .visible,
            presenting: tapTarget
        ) { target in
            Button(changeButtonText(for: target)) {
                target.change()
                container.triggerRefresh()
            }
            Button(ActionStrings.Edit) {
                container.goToHormoneDetail(target.index)
            }
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .alert(
            AlertStrings.disclaimerAlertStrings.title,
            isPresented: $showDisclaimer
        ) {
            Button(ActionStrings.Dismiss) {
                container.sdk?.settings.setMentionedDisclaimer(to: true)
            }
        } message: {
            Text(AlertStrings.disclaimerAlertStrings.message)
        }
        .onAppear {
            container.refreshBadges()
            if container.sdk?.settings.mentionedDisclaimer.value == false {
                showDisclaimer = true
            }
        }
    }

    // MARK: - Tap handling

    private var confirmationTitle: String {
        guard let target = tapTarget else { return "" }
        return target.currentSite
    }

    private var confirmationBinding: Binding<Bool> {
        Binding(
            get: { tapTarget != nil },
            set: { if !$0 { tapTarget = nil } }
        )
    }

    private func changeButtonText(for target: TapTarget) -> String {
        if let suggested = target.suggestedSite, !suggested.isEmpty {
            return "\(ActionStrings.Change) → \(suggested)"
        }
        return ActionStrings.Change
    }

    private func handleRowTap(at index: Index) {
        guard let sdk = container.sdk else { return }
        sdk.sites.reloadContext()
        guard let hormone = sdk.hormones[index] else {
            container.goToHormoneDetail(index)
            return
        }
        // Empty hormone: skip the confirmation dialog, go straight to detail.
        guard hormone.hasSite || !hormone.date.isDefault() else {
            container.goToHormoneDetail(index)
            return
        }
        let nextSite = sdk.sites.suggested
        let change: () -> Void = {
            let command = sdk.commandFactory.createChangeHormoneCommand(hormone, now: PDNow())
            command.execute()
            container.notifications?.requestExpiredHormoneNotification(for: hormone)
            container.widget?.set()
        }
        tapTarget = TapTarget(
            index: index,
            currentSite: hormone.siteName.isEmpty ? SiteStrings.NewSite : hormone.siteName,
            suggestedSite: nextSite?.name,
            change: change
        )
    }
}
