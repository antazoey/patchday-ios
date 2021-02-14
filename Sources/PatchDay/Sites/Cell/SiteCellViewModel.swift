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
        return "\(site.order + 1)."
    }

    /// Should hide if not the the next index.
    func getVisibilityBools(cellIsInEditMode: Bool) -> (showNext: Bool, showOrder: Bool) {
        guard let index = props.site?.order else { return (false, !cellIsInEditMode) }
        return (props.nextSiteIndex == index && !cellIsInEditMode, !cellIsInEditMode)
    }
}
