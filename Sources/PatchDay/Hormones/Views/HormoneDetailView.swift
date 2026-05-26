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
                    Picker(PDTitleStrings.SiteTitle, selection: $state.selectedSiteName) {
                        ForEach(siteNames, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: state.selectedSiteName) { _ in state.isDirty = true }
                    .accessibilityIdentifier("hormoneSiteSelectorStack")

                    Button(ActionStrings._Type) {
                        state.isTypingNewSite = true
                        state.typedSiteName = ""
                    }
                    .accessibilityIdentifier("typeSiteButton")
                }

                Button(ActionStrings.Autofill) {
                    autofill()
                }
                .disabled(state.isTypingNewSite)
                .accessibilityIdentifier("autofillButton")
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
        state.selectedSiteName = hormone.siteName.isEmpty
            ? (siteNames.first ?? SiteStrings.NewSite)
            : hormone.siteName
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
