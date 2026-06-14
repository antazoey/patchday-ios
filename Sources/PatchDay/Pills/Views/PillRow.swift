//
//  PillRow.swift
//  PatchDay
//
//  SwiftUI replacement for PillCell.
//

import SwiftUI
import PDKit

struct PillRow: View {

    let pill: Swallowable

    private var cellViewModel: PillCellViewModel {
        PillCellViewModel(pill: pill)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(pill.name)
                    .font(.headline)
                Text("Last taken: \(cellViewModel.lastTakenText)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Due: \(cellViewModel.dueDateText)")
                    .font(.subheadline)
                    .foregroundColor(pill.isDue ? .red : .secondary)
                HStack(spacing: 5) {
                    Image(systemName: pill.isDone ? "checkmark.circle.fill" : "circle.lefthalf.filled")
                        .foregroundColor(pill.isDone ? .green : .accentColor)
                    Text("\(NSLocalizedString("Taken today", comment: "Pill doses taken today")): \(cellViewModel.timesQuotientText)")
                        .foregroundColor(.primary)
                }
                .font(.subheadline.weight(.medium))
            }
            Spacer(minLength: 0)
            // Fill the right-side whitespace with a pill glyph so the row
            // doesn't look empty on the right, and so the previously-dead
            // tappable area gets visible content underneath.
            Image(systemName: "pills.fill")
                .font(.system(size: 56))
                .foregroundColor(pill.isDue ? .red.opacity(0.5) : .secondary.opacity(0.4))
                .padding(.trailing, 8)
        }
        .padding(.vertical, 6)
        // Make the entire row a tap target (the Spacer alone has no
        // shape so the parent Button's hit-test ignored it).
        .contentShape(Rectangle())
        // Match the pre-SwiftUI PillCell.RowHeight (170pt) so a 1–2 pill
        // schedule doesn't collapse to a tiny strip at the top of the list.
        .frame(minHeight: 170)
    }
}
