//
//  SiteSchemePresetsView.swift
//  PatchDay
//
//  Reached from Sites → Edit → Presets. Offers ready-made site schemes (the
//  delivery-method default plus common rotations like Abdomen L×3 → R×3) and
//  applies the chosen one, replacing the current sites.
//

import SwiftUI
import PDKit

/// A named, ordered set of site names. Repeated names become repeated slots.
struct SiteScheme: Identifiable {
    let label: String
    let names: [SiteName]
    let isDefault: Bool
    var id: String { label }
}

enum SiteSchemes {

    /// The schemes offered for a delivery method. The default is always first.
    /// The Abdomen/Glute rotations only apply to Patches.
    static func all(for method: DeliveryMethod) -> [SiteScheme] {
        var schemes = [
            SiteScheme(
                label: NSLocalizedString("Default", comment: "Default site scheme"),
                names: SiteStrings.getSiteNames(for: method),
                isDefault: true
            )
        ]
        guard method == .Patches else { return schemes }
        let la = SiteStrings.LeftAbdomen
        let ra = SiteStrings.RightAbdomen
        let lg = SiteStrings.LeftGlute
        let rg = SiteStrings.RightGlute
        schemes += [
            SiteScheme(
                label: NSLocalizedString("Abdomen (L×3 → R×3)", comment: ""),
                names: [la, la, la, ra, ra, ra],
                isDefault: false
            ),
            SiteScheme(
                label: NSLocalizedString("Abdomen (L, R)", comment: ""),
                names: [la, ra],
                isDefault: false
            ),
            SiteScheme(
                label: NSLocalizedString("Glutes (L, R)", comment: ""),
                names: [lg, rg],
                isDefault: false
            ),
            SiteScheme(
                label: NSLocalizedString("Glutes (L×3 → R×3)", comment: ""),
                names: [lg, lg, lg, rg, rg, rg],
                isDefault: false
            )
        ]
        return schemes
    }
}

struct SiteSchemePresetsView: View {

    @EnvironmentObject private var container: AppContainer

    private var deliveryMethod: DeliveryMethod {
        container.sdk?.settings.deliveryMethod.value ?? .Patches
    }

    private var schemes: [SiteScheme] {
        SiteSchemes.all(for: deliveryMethod)
    }

    private var currentNames: [SiteName] {
        container.sdk?.sites.all.map { $0.name } ?? []
    }

    var body: some View {
        List(schemes) { scheme in
            Button {
                apply(scheme)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(scheme.label)
                            .foregroundColor(.primary)
                        Text(summary(scheme.names))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if scheme.isDefault {
                        Text(NSLocalizedString("Default", comment: "Default badge"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    if isActive(scheme) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                            .accessibilityHidden(true)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("siteScheme_\(scheme.label)")
            .accessibilityAddTraits(isActive(scheme) ? [.isSelected] : [])
        }
        .listStyle(.plain)
        .navigationTitle(NSLocalizedString("Presets", comment: "Site scheme presets title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func isActive(_ scheme: SiteScheme) -> Bool {
        currentNames == scheme.names
    }

    /// Collapse consecutive duplicate names into "name ×n" for a compact summary.
    private func summary(_ names: [SiteName]) -> String {
        var parts: [String] = []
        var i = 0
        while i < names.count {
            let name = names[i]
            var run = 1
            while i + run < names.count && names[i + run] == name { run += 1 }
            parts.append(run > 1 ? "\(name) ×\(run)" : name)
            i += run
        }
        return parts.joined(separator: ", ")
    }

    private func apply(_ scheme: SiteScheme) {
        guard let sdk = container.sdk else { return }
        sdk.sites.setSites(to: scheme.names)
        container.triggerRefresh()
        container.popSites()
    }
}
