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
        // Match the pre-SwiftUI 3.x heuristic: each row is ~24% of the
        // available screen height. With 2–3 patches (the common case) the
        // list fills the screen instead of leaving a lot of empty space,
        // and 4+ patches scroll with a peek of the next row visible.
        GeometryReader { proxy in
            let rowHeight = max(160, proxy.size.height * 0.24)
            List {
                ForEach(0..<SUPPORTED_HORMONE_UPPER_QUANTITY_LIMIT, id: \.self) { index in
                    if index < quantity, let sdk = container.sdk {
                        let vm = HormoneCellViewModel(cellIndex: index, sdk: sdk, isPad: container.isPad)
                        Button {
                            handleRowTap(at: index)
                        } label: {
                            HormoneRow(viewModel: vm, rowHeight: rowHeight)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("HormoneCell_\(index)")
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color(vm.backgroundColor))
                    }
                }
                .id(container.refreshTick) // force re-evaluation after mutations
            }
            .listStyle(.plain)
        }
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
        .onAppear {
            container.refreshBadges()
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
