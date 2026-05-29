//
//  GhostSiteRow.swift
//  PatchDay
//
//  "Add site" placeholder row at the bottom of the Sites list — replaces
//  the toolbar plus button so adding a new site is a single tap from the
//  list itself, matching the ghost-add UX on the Hormones and Pills tabs.
//

import SwiftUI
import PDKit

struct GhostSiteRow: View {

    let nextOrderNumber: Int

    var body: some View {
        HStack {
            Text("\(nextOrderNumber).")
                .font(.body.monospacedDigit())
                .foregroundColor(.secondary)
                .frame(width: 32, alignment: .leading)
            Text(NSLocalizedString("Add site", comment: "Ghost add-site row"))
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
            Image(systemName: "plus.circle.fill")
                .font(.title3)
                .foregroundColor(.accentColor)
        }
        .padding(.vertical, 4)
        .opacity(0.55)
    }
}
