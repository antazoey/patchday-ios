//
//  GhostHormoneRow.swift
//  PatchDay
//
//  Greyed-out "tap to add" placeholder for hormone slots beyond the user's
//  current Quantity setting. Only used for the Patches delivery method;
//  injection / gel users default to a single ongoing dose and don't need
//  the affordance.
//

import SwiftUI
import PDKit

struct GhostHormoneRow: View {

    let rowHeight: CGFloat

    var body: some View {
        Image(uiImage: SiteImages.placeholderPatch)
            .resizable()
            .scaledToFit()
            .opacity(0.35)
            .frame(maxWidth: .infinity)
            .frame(height: rowHeight)
    }
}
