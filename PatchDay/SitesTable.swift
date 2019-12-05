//
// Created by Juliya Smith on 12/4/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SitesTable: TableViewWrapper<SiteCell> {

    private let sites: HormoneSiteScheduling?
    private let appTheme: AppTheme?

    init(_ table: UITableView, sites: HormoneSiteScheduling?, appTheme: AppTheme?) {
        self.sites = sites
        self.appTheme = appTheme
        super.init(table, primaryCellReuseId: CellReuseIds.Site)
    }

    func getCell(at index: Index, isEditing: Bool)-> SiteCell {
        let props = createCellProps(index, isEditing)
        return dequeueCell()?.configure(props: props) ?? SiteCell()
    }

    private func createCellProps(_ siteIndex: Index, _ isEditing: Bool) -> SiteCellProperties {
        var props = SiteCellProperties(nextSiteIndex: siteIndex, isEditing: isEditing)
        if let sites = sites {
            props.nextSiteIndex = sites.nextIndex
            props.totalSiteCount = sites.count
            if let site = sites.at(siteIndex) {
                props.site = site
            }
            if let theme = appTheme {
                props.theme = theme
            }
        }
        return props
    }
}
