//
//  SiteRow.swift
//  PatchDay
//
//  SwiftUI replacement for SiteCell.
//

import SwiftUI
import PDKit

struct SiteRow: View {

    let site: Bodily
    let isNextSite: Bool

    var body: some View {
        HStack {
            Text("\(site.order + 1).")
                .font(.body.monospacedDigit())
                .foregroundColor(.secondary)
                .frame(width: 32, alignment: .leading)
                .accessibilityIdentifier("siteOrderLabel_\(site.order)")

            Text(site.name.isEmpty ? SiteStrings.NewSite : site.name)
                .font(.body)
                .accessibilityIdentifier("siteNameLabel_\(site.order)")

            Spacer()

            if isNextSite {
                Text(NSLocalizedString("Next", comment: "Next site indicator"))
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.accentColor))
                    .accessibilityIdentifier("nextSiteBadge")
            }
        }
        .padding(.vertical, 4)
    }
}
