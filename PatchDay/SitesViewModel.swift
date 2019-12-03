//
//  SitesViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/13/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SitesViewModel: CodeBehindDependencies {

    var sitesCount: Int {
        sdk?.sites.count ?? 0
    }

    var sitesOptionsCount: Int {
        sdk?.sites.names.count ?? 0
    }

    func isValidSiteIndex(_ index: Index) -> Bool {
        sdk?.sites.at(index) != nil
    }

    func resetSites() {
        if let sites = sdk?.sites {
            sites.reset()
        }
    }

    func deleteSite(at index: Index) {
        if let sites = sdk?.sites {
            sites.delete(at: index)
        }
    }
    
    func getSitesTitle() -> String {
        if let method = sdk?.defaults.deliveryMethod.value {
            return VCTitleStrings.getSitesTitle(for: method)
        }
        return VCTitleStrings.siteTitle
    }

    func createCellProps(_ siteIndex: Index, _ isEditing: Bool) -> SiteCellProperties {
        var props = SiteCellProperties(nextSiteIndex: siteIndex, isEditing: isEditing)
        if let sites = sdk?.sites {
            props.nextSiteIndex = sites.nextIndex
            props.totalSiteCount = sites.count
            if let site = sites.at(siteIndex) {
                props.site = site
            }
            if let theme = styles?.theme {
                props.theme = theme
            }
        }
    }
}
