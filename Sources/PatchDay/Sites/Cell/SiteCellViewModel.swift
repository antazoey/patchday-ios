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
        var name = self.props.site?.name
        if name == "" {
            name = SiteStrings.NewSite
        }
        return name ?? SiteStrings.NewSite
    }

    var orderText: String {
        guard let site = props.site else {
            return ""
        }
        return "\(site.order + 1)."
    }

    /// Should hide if not the the next index.
    func getVisibilityBools(cellIsInEditMode: Bool) -> (showNext: Bool, showOrder: Bool) {
        guard let index = props.site?.order else { return (false, !cellIsInEditMode) }
        return (self.props.nextSiteIndex == index && !cellIsInEditMode, !cellIsInEditMode)
    }
}
