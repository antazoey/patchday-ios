//
//  HormoneDetailView.swift
//  PatchDay
//
//  SwiftUI replacement for HormoneDetailViewController. Edits a single
//  hormone's applied date and site. Reuses HormoneDetailViewModel for all
//  business logic (save, autofill, new-site alert) — this view is purely
//  presentation and binding.
//

import SwiftUI
import PDKit

struct HormoneDetailView: View {

    @EnvironmentObject private var container: AppContainer
    @Environment(\.dismiss) private var dismiss

    let hormoneIndex: Index

    @StateObject private var state = DetailState()

    @State private var showUnsavedAlert = false
    @State private var showNewSiteAlert = false
    @State private var pendingNewSiteName = ""
    @State private var showSiteOptions = false
    @State private var showSiteList = false

    /// We mirror the existing HormoneSelectionState into @State because SwiftUI
    /// needs Published-style changes to drive re-render. The underlying VM
    /// keeps its own selections in sync via the bindings below.
    @MainActor
    final class DetailState: ObservableObject {
        @Published var selectedDate = Date()
        @Published var selectedSiteName: String = ""
        @Published var typedSiteName: String = ""
        @Published var isTypingNewSite = false
        @Published var isDirty = false
        var didPrime = false
        // Snapshot of what prime() assigned to selectedSiteName, so the
        // site picker's onChange can tell hydration-fired writes apart
        // from real user edits.
        var initialSiteName: String = ""
    }

    private var viewStrings: HormoneViewStrings? {
        guard let hormone = hormone else { return nil }
        return HormoneStrings.create(hormone)
    }

    var body: some View {
        Form {
            Section(viewStrings?.dateAndTimePlacedText ?? "") {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { state.selectedDate },
                        set: { date in
                            state.selectedDate = date
                            state.isDirty = true
                        }
                    ),
                    in: ...Date.distantFuture,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .accessibilityIdentifier("hormoneDatePicker")

                LabeledContent(viewStrings?.expirationText ?? "", value: expirationText)
                    .accessibilityIdentifier("hormoneExpirationLabel")
            }

            Section(PDTitleStrings.SiteTitle) {
                if state.isTypingNewSite {
                    TextField(SiteStrings.NewSite, text: $state.typedSiteName)
                        .autocapitalization(.words)
                        .onSubmit { commitTypedSite() }
                        .accessibilityIdentifier("selectHormoneSiteTextField")
                    HStack {
                        Button(ActionStrings.Done) { commitTypedSite() }
                            .accessibilityIdentifier("hormoneSiteDoneButton")
                        Spacer()
                        Button(ActionStrings.Cancel, role: .cancel) {
                            state.isTypingNewSite = false
                            state.typedSiteName = ""
                        }
                        .accessibilityIdentifier("hormoneSiteTypeCancelButton")
                    }
                } else {
                    // Tap-to-act site row. Replaces the previous picker +
                    // separate Type button with one entry point that
                    // opens a Type / Select / Auto choice.
                    Button {
                        showSiteOptions = true
                    } label: {
                        HStack {
                            Text(PDTitleStrings.SiteTitle)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(state.selectedSiteName)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .accessibilityIdentifier("hormoneSiteSelectorStack")
                    .onChange(of: state.selectedSiteName) { _, newValue in
                        // Track real user edits (made via the Select / Auto
                        // dialogs or autofill) but skip prime()'s hydration
                        // by comparing against the initial snapshot.
                        if newValue != state.initialSiteName {
                            state.isDirty = true
                        }
                    }
                }
            }

            if !state.isTypingNewSite {
                Section {
                    Button(NSLocalizedString("Change", comment: "Apply site + date together")) {
                        autofill()
                    }
                    .accessibilityIdentifier("hormoneChangeButton")
                }
            }
        }
        .navigationTitle(PDTitleStrings.EditHormoneTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(ActionStrings.Back) { handleBack() }
                    .accessibilityIdentifier("hormoneBackButton")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(ActionStrings.Save) { save() }
                    .accessibilityIdentifier("saveHormoneButton")
                    .disabled(!state.isDirty)
            }
        }
        .alert(
            AlertStrings.newSiteAlertStrings.title,
            isPresented: $showNewSiteAlert
        ) {
            Button(AlertStrings.newSiteAlertStrings.positiveActionTitle) {
                addNewSite(pendingNewSiteName)
            }
            Button(AlertStrings.newSiteAlertStrings.negativeActionTitle, role: .cancel) {}
        }
        .confirmationDialog(
            PDTitleStrings.SiteTitle,
            isPresented: $showSiteOptions,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("Type", comment: "Type new site action")) {
                state.isTypingNewSite = true
                state.typedSiteName = ""
            }
            Button(NSLocalizedString("Select", comment: "Pick site from list")) {
                showSiteList = true
            }
            Button(autoSiteButtonText) {
                autoPickSiteOnly()
            }
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .confirmationDialog(
            NSLocalizedString("Choose a site", comment: ""),
            isPresented: $showSiteList,
            titleVisibility: .visible
        ) {
            ForEach(siteNames, id: \.self) { name in
                Button(name) {
                    state.selectedSiteName = name
                }
            }
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .confirmationDialog(
            NSLocalizedString("Unsaved changes", comment: "Alert title"),
            isPresented: $showUnsavedAlert,
            titleVisibility: .visible
        ) {
            Button(ActionStrings.Save) {
                save()
            }
            Button(
                NSLocalizedString("Discard", comment: "Discard unsaved changes"),
                role: .destructive
            ) {
                container.popHormones()
            }
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .onAppear(perform: prime)
    }

    // MARK: - Helpers

    private var siteNames: [String] {
        guard let sdk = container.sdk else { return [] }
        return sdk.sites.names.map { $0.isEmpty ? SiteStrings.NewSite : $0 }
    }

    private var hormone: Hormonal? {
        container.sdk?.hormones[hormoneIndex]
    }

    private var expirationText: String {
        guard let hormone = hormone else { return PlaceholderStrings.DotDotDot }
        let interval = hormone.expirationInterval
        guard let date = DateFactory.createExpirationDate(
            expirationInterval: interval, to: state.selectedDate
        ) else { return PlaceholderStrings.DotDotDot }
        return HormoneStrings.getExpirationDateText(expiration: date)
    }

    private func prime() {
        guard !state.didPrime else { return }
        state.didPrime = true
        guard let hormone = hormone else { return }
        if !hormone.date.isDefault() {
            state.selectedDate = hormone.date
        }
        let resolved = hormone.siteName
        // `hormone.siteName` returns "New Site" when the hormone has no real
        // site assigned, but the Picker's options are the actual configured
        // sites — "New Site" isn't in that list, so the Picker would render
        // empty. Fall back to the first available site name in that case.
        let initial: String
        if resolved.isEmpty || resolved == SiteStrings.NewSite || !siteNames.contains(resolved) {
            initial = siteNames.first ?? SiteStrings.NewSite
        } else {
            initial = resolved
        }
        state.initialSiteName = initial
        state.selectedSiteName = initial
    }

    private func commitTypedSite() {
        let trimmed = state.typedSiteName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            state.isTypingNewSite = false
            return
        }
        pendingNewSiteName = trimmed
        showNewSiteAlert = true
    }

    private func addNewSite(_ name: String) {
        guard let sdk = container.sdk else { return }
        sdk.sites.insertNew(name: name) { _ in }
        state.selectedSiteName = name
        state.isTypingNewSite = false
        state.typedSiteName = ""
        state.isDirty = true
    }

    private func autofill() {
        guard let sdk = container.sdk else { return }
        if let suggested = sdk.sites.suggested {
            state.selectedSiteName = suggested.name.isEmpty ? SiteStrings.NewSite : suggested.name
        }
        state.selectedDate = Date()
        state.isDirty = true
    }

    /// Set the site (only) to the next suggested. Used by the "Auto"
    /// option in the site-action dialog. The date is left alone — for
    /// the full "site + date" action use the bottom-of-section Change
    /// button (autofill).
    private func autoPickSiteOnly() {
        guard let sdk = container.sdk else { return }
        guard let suggested = sdk.sites.suggested else { return }
        state.selectedSiteName = suggested.name.isEmpty ? SiteStrings.NewSite : suggested.name
    }

    private var autoSiteButtonText: String {
        guard let sdk = container.sdk, let suggested = sdk.sites.suggested else {
            return NSLocalizedString("Auto", comment: "Auto-pick site")
        }
        let name = suggested.name.isEmpty ? SiteStrings.NewSite : suggested.name
        return "\(NSLocalizedString("Auto", comment: ""))  → \(name)"
    }

    private func save() {
        guard let sdk = container.sdk, let hormone = hormone else {
            container.popHormones()
            return
        }
        sdk.hormones.setDate(by: hormone.id, with: state.selectedDate)
        if let site = sdk.sites.all.first(where: { $0.name == state.selectedSiteName }) {
            sdk.hormones.setSite(by: hormone.id, with: site)
        } else if !state.selectedSiteName.isEmpty {
            sdk.hormones.setSiteName(by: hormone.id, with: state.selectedSiteName)
        }
        container.notifications?.requestExpiredHormoneNotification(for: hormone)
        if hormone.expiresOvernight {
            container.notifications?.requestOvernightExpirationNotification(for: hormone)
        }
        container.badge?.reflect()
        container.widget?.set()
        container.triggerRefresh()
        container.popHormones()
    }

    private func handleBack() {
        if state.isDirty {
            showUnsavedAlert = true
        } else {
            container.popHormones()
        }
    }
}
