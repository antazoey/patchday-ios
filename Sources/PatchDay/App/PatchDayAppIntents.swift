//
//  PatchDayAppIntents.swift
//  PatchDay
//
//  Siri / Shortcuts support via App Intents. These are thin hooks: the actual
//  schedule logic lives in the SDK (PDCommandFactory.changeAllHormones /
//  changeHormone, hormones.next, pills.nextDue) and AppContainer orchestrates
//  the app-level side effects. The intents only read/format and call those.
//
//  Phrases (each also requires the app name, e.g. "...in PatchDay"):
//    "What is my next patch?" / "What is my next hormone due?"
//    "What is my next pill due?"
//    "I am changing my <site> patch now"
//    "I am changing all my patches now"
//

import AppIntents
import PDKit

// MARK: - Shared responder (reads the SDK, formats one sentence)

enum SiriResponder {

    @MainActor
    static func nextPatchSentence() -> String {
        guard let hormone = AppContainer.shared.sdk?.hormones.next else {
            return NSLocalizedString("You have no patches scheduled.", comment: "Siri")
        }
        let site = hormone.siteName.isEmpty ? SiteStrings.NewSite : hormone.siteName
        guard let expiration = hormone.expiration else {
            return String(
                format: NSLocalizedString("Your next patch is on %@.", comment: "Siri"), site
            )
        }
        let when = expiration.formatted(date: .abbreviated, time: .shortened)
        if hormone.isExpired {
            return String(
                format: NSLocalizedString("Your patch on %@ is due now.", comment: "Siri"), site
            )
        }
        return String(
            format: NSLocalizedString("Your next patch, on %@, is due %@.", comment: "Siri"),
            site, when
        )
    }

    @MainActor
    static func nextPillSentence() -> String {
        guard let pill = AppContainer.shared.sdk?.pills.nextDue else {
            return NSLocalizedString("You have no pills scheduled.", comment: "Siri")
        }
        guard let due = pill.due else {
            return String(
                format: NSLocalizedString("Your next pill is %@.", comment: "Siri"), pill.name
            )
        }
        let when = due.formatted(date: .abbreviated, time: .shortened)
        return String(
            format: NSLocalizedString("Your next pill, %@, is due %@.", comment: "Siri"),
            pill.name, when
        )
    }

    @MainActor
    static func currentPatchesSentence() -> String {
        let all = AppContainer.shared.sdk?.hormones.all ?? []
        let placed = all.filter { $0.hasSite || !$0.date.isDefault() }
        guard !placed.isEmpty else {
            return NSLocalizedString("You don't have any patches applied right now.", comment: "Siri")
        }
        let parts = placed.map { hormone -> String in
            let site = hormone.siteName.isEmpty ? SiteStrings.NewSite : hormone.siteName
            return hormone.isExpired
                ? String(format: NSLocalizedString("%@ (due now)", comment: "Siri"), site)
                : site
        }
        if placed.count == 1 {
            return String(
                format: NSLocalizedString("You have one patch, on %@.", comment: "Siri"), parts[0]
            )
        }
        return String(
            format: NSLocalizedString("You have %d patches: %@.", comment: "Siri"),
            placed.count, parts.joined(separator: ", ")
        )
    }
}

// MARK: - Site entity (lets Siri resolve "my left abdomen patch")

struct PatchSiteEntity: AppEntity {
    let id: String // the site name

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Patch Site" }
    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(id)") }
    static var defaultQuery = PatchSiteQuery()
}

struct PatchSiteQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [PatchSiteEntity] {
        identifiers.map { PatchSiteEntity(id: $0) }
    }

    @MainActor
    func suggestedEntities() async throws -> [PatchSiteEntity] {
        (AppContainer.shared.sdk?.sites.uniqueNames ?? []).map { PatchSiteEntity(id: $0) }
    }
}

// MARK: - Query intents

struct NextPatchIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Patch Due"
    static var description = IntentDescription("Tells you which patch is due next, and when.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: IntentDialog(stringLiteral: SiriResponder.nextPatchSentence()))
    }
}

struct NextPillIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Pill Due"
    static var description = IntentDescription("Tells you which pill is due next, and when.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: IntentDialog(stringLiteral: SiriResponder.nextPillSentence()))
    }
}

struct CurrentPatchesIntent: AppIntent {
    static var title: LocalizedStringResource = "Current Patches"
    static var description = IntentDescription("Lists the patches you currently have applied.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: IntentDialog(stringLiteral: SiriResponder.currentPatchesSentence()))
    }
}

// MARK: - Action intents

struct ChangePatchIntent: AppIntent {
    static var title: LocalizedStringResource = "Change Patch"
    static var description = IntentDescription("Changes the patch on a given site to its next site.")

    @Parameter(title: "Site")
    var site: PatchSiteEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Changing a patch overwrites its applied date + site, so confirm first.
        try await requestConfirmation(
            result: .result(dialog: "Change your \(site.id) patch now?")
        )
        if AppContainer.shared.changePatch(onSiteNamed: site.id) != nil {
            return .result(dialog: "Changed your \(site.id) patch.")
        }
        return .result(dialog: "You don't have a patch on \(site.id).")
    }
}

struct ChangeNextPatchIntent: AppIntent {
    static var title: LocalizedStringResource = "Change Next Patch"
    static var description = IntentDescription("Changes the next patch due to its next site.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let next = AppContainer.shared.sdk?.hormones.next else {
            return .result(dialog: "You have no patches to change.")
        }
        let site = next.siteName.isEmpty ? SiteStrings.NewSite : next.siteName
        try await requestConfirmation(
            result: .result(dialog: "Change your \(site) patch now?")
        )
        if AppContainer.shared.changeNextPatch() != nil {
            return .result(dialog: "Changed your \(site) patch.")
        }
        return .result(dialog: "You have no patches to change.")
    }
}

struct ChangeAllPatchesIntent: AppIntent {
    static var title: LocalizedStringResource = "Change All Patches"
    static var description = IntentDescription("Changes all of your patches to their next sites.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await requestConfirmation(
            result: .result(dialog: "Change all your patches now?")
        )
        let changed = AppContainer.shared.changeAllPatches()
        if changed.isEmpty {
            return .result(dialog: "You have no patches to change.")
        }
        return .result(dialog: "Changed all \(changed.count) patches.")
    }
}

// MARK: - "Hey Siri" phrases

struct PatchDayShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NextPatchIntent(),
            phrases: [
                "What is my next patch in \(.applicationName)",
                "When is my next patch due in \(.applicationName)",
                "What is my next hormone due in \(.applicationName)"
            ],
            shortTitle: "Next Patch",
            systemImageName: "cross.case"
        )
        AppShortcut(
            intent: CurrentPatchesIntent(),
            phrases: [
                "What are my current patches in \(.applicationName)",
                "What are my patches in \(.applicationName)",
                "What patches do I have in \(.applicationName)",
                "List my patches in \(.applicationName)"
            ],
            shortTitle: "Current Patches",
            systemImageName: "list.bullet"
        )
        AppShortcut(
            intent: NextPillIntent(),
            phrases: [
                "What is my next pill due in \(.applicationName)",
                "When is my next pill in \(.applicationName)"
            ],
            shortTitle: "Next Pill",
            systemImageName: "pills"
        )
        AppShortcut(
            intent: ChangeNextPatchIntent(),
            phrases: [
                "I am changing my next patch now in \(.applicationName)",
                "Change my next patch in \(.applicationName)"
            ],
            shortTitle: "Change Next Patch",
            systemImageName: "arrow.right.circle"
        )
        AppShortcut(
            intent: ChangeAllPatchesIntent(),
            phrases: [
                "I am changing all my patches now in \(.applicationName)",
                "Change all my patches in \(.applicationName)"
            ],
            shortTitle: "Change All Patches",
            systemImageName: "arrow.triangle.2.circlepath"
        )
        AppShortcut(
            intent: ChangePatchIntent(),
            phrases: [
                "I am changing my \(\.$site) patch now in \(.applicationName)",
                "Change my \(\.$site) patch in \(.applicationName)"
            ],
            shortTitle: "Change Patch",
            systemImageName: "arrow.right.circle"
        )
    }
}
