//
//  SiteCellViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/9/20.

import Foundation
import PDKit

class SiteCellViewModel: SiteCellViewModelProtocol {

    private let props: SiteCellProperties

    init(_ props: SiteCellProperties) {
        self.props = props
    }

    var siteNameText: String {
        if let site = props.site {
            return site.name == "" ? SiteStrings.NewSite : site.name
        }
        return SiteStrings.NewSite
    }

    var orderText: String {
        guard let site = props.site else { return "" }
        let order = site.order
        return "\(order + 1)."
    }

    /// Should hide if not the the next index.
    func getVisibilityBools(
        cellIsInEditMode: Bool) -> (hideNext: Bool, hideOrder: Bool, hideArrow: Bool
    ) {
        let index = props.site?.order ?? 0
        let nextSiteIndex = props.nextSiteIndex
        let hideNext = nextSiteIndex != index || cellIsInEditMode
        let hideOrder = cellIsInEditMode
        let hideArrow = !hideNext || cellIsInEditMode
        return (hideNext, hideOrder, hideArrow)
    }
}
