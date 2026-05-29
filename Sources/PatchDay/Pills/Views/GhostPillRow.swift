//
//  GhostPillRow.swift
//  PatchDay
//
//  "Add pill" placeholder row at the bottom of the Pills list — replaces
//  the toolbar plus button so adding a new pill is a single tap from the
//  list itself, matching the ghost-add UX on the Hormones tab.
//

import SwiftUI
import PDKit

struct GhostPillRow: View {

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "pills.fill")
                .font(.system(size: 28))
                .foregroundColor(.secondary)
            Text(NSLocalizedString("Add pill", comment: "Ghost add-pill row"))
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.accentColor)
        }
        .padding(.vertical, 12)
        .opacity(0.55)
    }
}
