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
    let onTake: () -> Void

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
            Button(action: onTake) {
                Text(ActionStrings.Take)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor.opacity(0.15)))
            }
            .buttonStyle(.plain)
            .disabled(pill.isDone)
            .accessibilityIdentifier("pillTakeButton")
        }
        .padding(.vertical, 6)
    }
}
