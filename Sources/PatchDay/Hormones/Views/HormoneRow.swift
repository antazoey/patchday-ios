//
//  HormoneRow.swift
//  PatchDay
//
//  SwiftUI replacement for HormoneCell. Matches the original layered layout:
//  the site image fills the row (aspect-fit), the date sits at the
//  bottom-center, the overnight moon sits top-right, and an overdue "!"
//  badge floats in the top-left corner. Row height is supplied by the
//  parent list so the row can scale to ~24% of screen height like the
//  pre-SwiftUI UIKit cell did.
//

import SwiftUI
import PDKit

struct HormoneRow: View {

    let viewModel: HormoneCellViewModelProtocol
    let rowHeight: CGFloat

    var body: some View {
        ZStack {
            siteImage
                .frame(maxWidth: .infinity)
                .frame(height: rowHeight)

            VStack {
                HStack(alignment: .top) {
                    if let badge = viewModel.badgeValue {
                        Text(badge)
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(width: 26, height: 26)
                            .background(Circle().fill(Color.red))
                            .padding(.leading, 12)
                            .padding(.top, 11)
                    }
                    Spacer()
                    if viewModel.moonIcon != nil {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.indigo)
                            .padding(.trailing, 18)
                            .padding(.top, 14)
                    }
                }
                Spacer()
                if let date = viewModel.dateString {
                    Text(date)
                        .font(Font(viewModel.dateFont))
                        .foregroundColor(Color(viewModel.dateLabelColor))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .padding(.horizontal, 36)
                        .padding(.bottom, 11)
                }
            }
            .frame(height: rowHeight)
        }
        .frame(maxWidth: .infinity)
        .frame(height: rowHeight)
        .accessibilityIdentifier(viewModel.cellId)
    }

    @ViewBuilder
    private var siteImage: some View {
        // A slot within Quantity whose hormone record isn't present yet (e.g.
        // mid-iCloud-import, or before anything's applied) falls back to the
        // empty-patch placeholder for the delivery method — never a blank cell.
        // Dateless/empty hormones already resolve to that same placeholder.
        let params = viewModel.hormone.map { SiteImageDeterminationParameters(hormone: $0) }
            ?? SiteImageDeterminationParameters(deliveryMethod: viewModel.deliveryMethod)
        Image(uiImage: SiteImages[params])
            .resizable()
            .scaledToFit()
            .transition(.opacity)
            .id(params.imageId)
    }
}
