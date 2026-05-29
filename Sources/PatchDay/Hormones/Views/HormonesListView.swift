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
    @State private var pendingAddIndex: Int?
    @State private var pendingRemoveIndex: Int?

    private struct TapTarget: Identifiable {
        let id = UUID()
        let index: Index
        let currentSite: SiteName
        let suggestedSite: SiteName?
        /// `nil` when the hormone is empty / has no real applied state to
        /// "change from". The dialog hides the Change button in that case
        /// and only offers Edit + Remove + Cancel.
        let change: (() -> Void)?
    }

    private var quantity: Int {
        container.sdk?.settings.quantity.rawValue ?? 0
    }

    private var deliveryMethod: DeliveryMethod {
        container.sdk?.settings.deliveryMethod.value ?? .Patches
    }

    /// Show ghost-add cells only when the user can usefully grow the
    /// schedule — patches benefit (people often have 2 and 3 going at
    /// once); injections and gel default to a single ongoing dose.
    private var ghostCellsEnabled: Bool {
        deliveryMethod == .Patches
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
                            // Re-evaluate the row body every minute so the
                            // expiration state (date color, overdue badge,
                            // moon icon) flips automatically when a patch
                            // crosses its expiration without the user
                            // having to back out and re-enter the tab.
                            TimelineView(.periodic(from: .now, by: 60)) { _ in
                                HormoneRow(viewModel: vm, rowHeight: rowHeight)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("HormoneCell_\(index)")
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color(vm.backgroundColor))
                        .contextMenu {
                            if quantity > 1 {
                                Button(role: .destructive) {
                                    pendingRemoveIndex = index
                                } label: {
                                    Label(
                                        NSLocalizedString("Remove patch", comment: ""),
                                        systemImage: "trash"
                                    )
                                }
                            }
                        }
                    } else if ghostCellsEnabled, index == quantity {
                        // Only render the ghost in the immediate next slot
                        // (e.g. position 3 when quantity is 2). Tapping it
                        // bumps quantity by one; the new ghost then shifts
                        // down a row until quantity hits the upper limit.
                        GhostHormoneRow(rowHeight: rowHeight)
                            .contentShape(Rectangle())
                            .onTapGesture { pendingAddIndex = index }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .accessibilityIdentifier("GhostHormoneCell_\(index)")
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
            if let change = target.change {
                Button(changeButtonText(for: target)) {
                    change()
                    container.triggerRefresh()
                }
            }
            Button(ActionStrings.Edit) {
                container.goToHormoneDetail(target.index)
            }
            // Cross-platform path for removing a patch — long-press +
            // contextMenu is unreliable on iPad / Mac Catalyst, so the
            // Remove option lives here too. Only offered when the user
            // would still have at least one slot afterward.
            if quantity > 1 {
                Button(NSLocalizedString("Remove patch", comment: ""), role: .destructive) {
                    let index = target.index
                    tapTarget = nil
                    pendingRemoveIndex = index
                }
            }
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .alert(
            addPatchAlertTitle,
            isPresented: addAlertBinding,
            presenting: pendingAddIndex
        ) { _ in
            Button(NSLocalizedString("Add", comment: "Add hormone confirm")) {
                applyAddPatch()
            }
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .alert(
            NSLocalizedString("Remove this patch from your schedule?", comment: ""),
            isPresented: removeAlertBinding,
            presenting: pendingRemoveIndex
        ) { _ in
            Button(NSLocalizedString("Remove", comment: ""), role: .destructive) {
                applyRemovePatch()
            }
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .onAppear {
            container.refreshBadges()
        }
    }

    private var addPatchAlertTitle: String {
        guard let index = pendingAddIndex else { return "" }
        return String(
            format: NSLocalizedString("Add a %d%@ patch?", comment: "e.g. Add a 3rd patch?"),
            index + 1,
            ordinalSuffix(for: index + 1)
        )
    }

    private var addAlertBinding: Binding<Bool> {
        Binding(get: { pendingAddIndex != nil }, set: { if !$0 { pendingAddIndex = nil } })
    }

    private var removeAlertBinding: Binding<Bool> {
        Binding(get: { pendingRemoveIndex != nil }, set: { if !$0 { pendingRemoveIndex = nil } })
    }

    private func applyAddPatch() {
        guard let index = pendingAddIndex else { return }
        container.sdk?.settings.setQuantity(to: index + 1)
        container.triggerRefresh()
    }

    private func applyRemovePatch() {
        guard let index = pendingRemoveIndex else { return }
        container.sdk?.settings.removeHormoneSlot(at: index)
        container.triggerRefresh()
    }

    private func ordinalSuffix(for n: Int) -> String {
        let mod100 = n % 100
        if (11...13).contains(mod100) { return "th" }
        switch n % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
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
        // Empty hormone: show the dialog with Edit + Remove + Cancel (no
        // Change, since there's nothing applied yet) so iPad / Mac users
        // can still reach Remove without long-press.
        guard hormone.hasSite || !hormone.date.isDefault() else {
            tapTarget = TapTarget(
                index: index,
                currentSite: SiteStrings.NewSite,
                suggestedSite: nil,
                change: nil
            )
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
