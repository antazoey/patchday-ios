//
//  SitesListView.swift
//  PatchDay
//
//  SwiftUI replacement for SitesViewController. Supports reorder + delete
//  via native List edit mode, plus an add toolbar button.
//

import SwiftUI
import PDKit

struct SitesListView: View {

    @EnvironmentObject private var container: AppContainer
    @State private var editMode: EditMode = .inactive

    private var sites: [Bodily] {
        container.sdk?.sites.all ?? []
    }

    private var nextIndex: Int {
        container.sdk?.sites.nextIndex ?? -1
    }

    var body: some View {
        List {
            ForEach(Array(sites.enumerated()), id: \.element.id) { index, site in
                Button {
                    if editMode == .inactive {
                        container.goToSiteDetail(index)
                    }
                } label: {
                    SiteRow(site: site, isNextSite: index == nextIndex)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("SiteCell_\(index)")
            }
            .onMove(perform: moveSites)
            .onDelete(perform: deleteSites)
            .id(container.refreshTick)
        }
        .listStyle(.plain)
        .accessibilityIdentifier("sitesList")
        .environment(\.editMode, $editMode)
        .navigationTitle(PDTitleStrings.SitesTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(editMode == .inactive ? ActionStrings.Edit : ActionStrings.Done) {
                    withAnimation { editMode = editMode == .inactive ? .active : .inactive }
                }
                .accessibilityIdentifier("editSitesButton")
            }
            if editMode == .active {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(ActionStrings.Reset) { resetSites() }
                        .accessibilityIdentifier("resetSitesButton")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addNew) {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("insertNewSiteButton")
            }
        }
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

    private func addNew() {
        guard let sdk = container.sdk else { return }
        sdk.sites.insertNew(name: SiteStrings.NewSite) { site in
            container.triggerRefresh()
            container.goToSiteDetail(site.order)
        }
    }

    private func resetSites() {
        guard let sdk = container.sdk else { return }
        sdk.sites.reset()
        editMode = .inactive
        container.triggerRefresh()
    }
}
