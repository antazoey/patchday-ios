//
//  HormoneRow.swift
//  PatchDay
//
//  SwiftUI replacement for HormoneCell. Matches the original layered layout:
//  the site image fills the row at 160pt tall (aspect-fit), the date sits at
//  the bottom-center, the overnight moon sits top-right, and an overdue "!"
//  badge floats in the top-left corner.
//

import SwiftUI
import PDKit

struct HormoneRow: View {

    let viewModel: HormoneCellViewModelProtocol

    private let rowHeight: CGFloat = 160

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
                    if let moon = viewModel.moonIcon {
                        Image(uiImage: moon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 28)
                            .padding(.trailing, 16)
                            .padding(.top, 11)
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
        if let hormone = viewModel.hormone {
            let params = SiteImageDeterminationParameters(hormone: hormone)
            Image(uiImage: SiteImages[params])
                .resizable()
                .scaledToFit()
                .transition(.opacity)
                .id(params.imageId)
        } else {
            Color.clear
        }
    }
}
