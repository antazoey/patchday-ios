//
//  SitesListView.swift
//  PatchDay
//
//  SwiftUI replacement for SitesViewController. Reorder + delete via native
//  List edit mode, an add row with Add Existing / New Location, and per-site
//  Edit / Duplicate actions. Outside edit mode, runs of same-named sites
//  collapse into one "Name ×N" row that expands on tap.
//

import SwiftUI
import PDKit

struct SitesListView: View {

    @EnvironmentObject private var container: AppContainer
    @State private var editMode: EditMode = .inactive
    @State private var siteActionIndex: Int?
    @State private var showSiteActions = false
    @State private var showAddOptions = false
    @State private var showExistingPicker = false
    @State private var expandedGroups: Set<Int> = []

    private var sites: [Bodily] {
        container.sdk?.sites.all ?? []
    }

    private var nextIndex: Int {
        container.sdk?.sites.nextIndex ?? -1
    }

    /// A run of consecutive sites that share a name, collapsed into one row.
    private struct SiteRun: Identifiable {
        let name: String
        let memberIndices: [Int]
        var startIndex: Int { memberIndices.first ?? 0 }
        var count: Int { memberIndices.count }
        var id: Int { startIndex }
    }

    private var siteGroups: [SiteRun] {
        var runs: [SiteRun] = []
        let all = sites
        var i = 0
        while i < all.count {
            let name = all[i].name
            var members = [i]
            var j = i + 1
            while j < all.count && all[j].name == name {
                members.append(j)
                j += 1
            }
            runs.append(SiteRun(name: name, memberIndices: members))
            i = j
        }
        return runs
    }

    var body: some View {
        List {
            if editMode == .active {
                ForEach(Array(sites.enumerated()), id: \.element.id) { index, site in
                    Button {
                        // Tap is inert in edit mode; reorder/delete drive this state.
                    } label: {
                        SiteRow(site: site, isNextSite: index == nextIndex)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("SiteCell_\(index)")
                }
                .onMove(perform: moveSites)
                .onDelete(perform: deleteSites)
                .id(container.refreshTick)
            } else {
                ForEach(siteGroups) { run in
                    if run.count == 1 {
                        individualRow(at: run.startIndex, indented: false)
                    } else {
                        groupHeader(run)
                        if expandedGroups.contains(run.startIndex) {
                            ForEach(run.memberIndices, id: \.self) { index in
                                individualRow(at: index, indented: true)
                            }
                        }
                    }
                }
                .id(container.refreshTick)

                // Wrap the ghost row in a Button so XCUI sees a button element
                // with our identifier.
                Button { showAddOptions = true } label: {
                    GhostSiteRow(nextOrderNumber: sites.count + 1)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("GhostSiteCell")
            }
        }
        .listStyle(.plain)
        .accessibilityIdentifier("sitesList")
        .environment(\.editMode, $editMode)
        .navigationTitle(PDTitleStrings.SitesTitle)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            siteActionTitle,
            isPresented: $showSiteActions,
            titleVisibility: .visible
        ) {
            Button(ActionStrings.Edit) {
                if let index = siteActionIndex { container.goToSiteDetail(index) }
            }
            .accessibilityIdentifier("editSiteAction")
            Button(NSLocalizedString("Duplicate", comment: "Clone a site slot")) {
                if let index = siteActionIndex { cloneSite(index) }
            }
            .accessibilityIdentifier("duplicateSiteAction")
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .confirmationDialog(
            NSLocalizedString("Add a site", comment: "Add-site action sheet title"),
            isPresented: $showAddOptions,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("Add Existing", comment: "Clone a location already in use")) {
                showExistingPicker = true
            }
            .accessibilityIdentifier("addExistingSiteAction")
            Button(NSLocalizedString("New Location", comment: "Create a brand-new site")) {
                addNew()
            }
            .accessibilityIdentifier("newSiteAction")
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .confirmationDialog(
            NSLocalizedString("Add existing location", comment: "Pick a location to duplicate"),
            isPresented: $showExistingPicker,
            titleVisibility: .visible
        ) {
            ForEach(existingLocationNames, id: \.self) { name in
                Button(name.isEmpty ? SiteStrings.NewSite : name) {
                    addExistingLocation(named: name)
                }
                .accessibilityIdentifier("existingLocation_\(name)")
            }
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(editMode == .inactive ? ActionStrings.Edit : ActionStrings.Done) {
                    withAnimation { editMode = editMode == .inactive ? .active : .inactive }
                }
                .accessibilityIdentifier("editSitesButton")
            }
            if editMode == .active {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("Presets", comment: "Site scheme presets")) {
                        container.goToSitePresets()
                    }
                    .accessibilityIdentifier("sitePresetsButton")
                }
            }
        }
    }

    // MARK: - Rows

    @ViewBuilder
    private func individualRow(at index: Int, indented: Bool) -> some View {
        if let site = sites.tryGet(at: index) {
            Button {
                siteActionIndex = index
                showSiteActions = true
            } label: {
                SiteRow(site: site, isNextSite: index == nextIndex)
                    .padding(.leading, indented ? 20 : 0)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("SiteCell_\(index)")
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    deleteSite(at: index)
                } label: {
                    Text(ActionStrings.Delete)
                }
                .accessibilityIdentifier("deleteSite_\(index)")
            }
        }
    }

    @ViewBuilder
    private func groupHeader(_ run: SiteRun) -> some View {
        let expanded = expandedGroups.contains(run.startIndex)
        let isNext = run.memberIndices.contains(nextIndex)
        Button {
            withAnimation {
                if expanded {
                    expandedGroups.remove(run.startIndex)
                } else {
                    expandedGroups.insert(run.startIndex)
                }
            }
        } label: {
            HStack {
                Image(systemName: expanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 32, alignment: .leading)
                Text(run.name.isEmpty ? SiteStrings.NewSite : run.name)
                    .font(.body)
                Text("×\(run.count)")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("siteGroupCount_\(run.startIndex)")
                Spacer()
                if isNext && !expanded {
                    nextBadge
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("siteGroup_\(run.startIndex)")
    }

    private var nextBadge: some View {
        Text(NSLocalizedString("Next", comment: "Next site indicator"))
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color(PDColors[.NewItem])))
            .accessibilityIdentifier("nextSiteBadge")
    }

    // MARK: - Helpers

    /// Title for the per-site action sheet — names the tapped site.
    private var siteActionTitle: String {
        guard let index = siteActionIndex, let site = sites.tryGet(at: index) else {
            return PDTitleStrings.SitesTitle
        }
        return site.name.isEmpty ? SiteStrings.NewSite : site.name
    }

    /// Distinct names of locations already in the schedule, offered when adding
    /// another slot of an existing location.
    private var existingLocationNames: [String] {
        container.sdk?.sites.uniqueNames ?? []
    }

    private func moveSites(from source: IndexSet, to destination: Int) {
        guard let sdk = container.sdk, let first = source.first else { return }
        let target = destination > first ? destination - 1 : destination
        let nextIndexBeforeMove = sdk.sites.nextIndex
        sdk.sites.reorder(at: first, to: target)
        if first == nextIndexBeforeMove {
            sdk.settings.setSiteIndex(to: target)
        } else if target == nextIndexBeforeMove {
            sdk.settings.setSiteIndex(to: first)
        }
        container.triggerRefresh()
    }

    private func deleteSites(at offsets: IndexSet) {
        guard let sdk = container.sdk else { return }
        for index in offsets.sorted(by: >) {
            sdk.sites.delete(at: index)
        }
        container.triggerRefresh()
    }

    private func deleteSite(at index: Int) {
        guard let sdk = container.sdk else { return }
        sdk.sites.delete(at: index)
        container.triggerRefresh()
    }

    private func addNew() {
        guard let sdk = container.sdk else { return }
        sdk.sites.insertNew(name: SiteStrings.NewSite) { site in
            container.triggerRefresh()
            container.goToSiteDetail(site.order)
        }
    }

    /// Duplicate an existing slot (same name + image) straight into the
    /// schedule, without the create-a-new-location detour. Lets a user add
    /// another rotation slot for a site that shares a name.
    private func cloneSite(_ index: Int) {
        guard let sdk = container.sdk else { return }
        sdk.sites.clone(at: index)
        container.triggerRefresh()
    }

    /// Add another slot of an existing named location by duplicating the first
    /// site that carries that name.
    private func addExistingLocation(named name: String) {
        guard let sdk = container.sdk,
            let index = sdk.sites.all.firstIndex(where: { $0.name == name }) else { return }
        cloneSite(index)
    }
}
