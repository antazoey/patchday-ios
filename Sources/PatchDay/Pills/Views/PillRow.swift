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
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(pill.name)
                    .font(.headline)
                Text("Last taken: \(cellViewModel.lastTakenText)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Due: \(cellViewModel.dueDateText)")
                    .font(.subheadline)
                    .foregroundColor(pill.isDue ? .red : .secondary)
                Text(cellViewModel.timesQuotientText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
        // Match the pre-SwiftUI PillCell.RowHeight (170pt) so a 1–2 pill
        // schedule doesn't collapse to a tiny strip at the top of the list.
        .frame(minHeight: 170)
    }
}
