//
// Created by Juliya Smith on 12/4/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class SitesTable: TableViewWrapper<SiteCell> {

    private let sites: HormoneSiteScheduling?
    private let stylist: Styling?

    init(_ table: UITableView, sites: HormoneSiteScheduling?, stylist: Styling?) {
        self.sites = sites
        self.stylist = stylist
        super.init(table, primaryCellReuseId: CellReuseIds.Site)
    }

    convenience init(_ table: UITableView) {
        self.init(table, sites: app?.sdk.sites, appTheme: app?.styles.theme)
    }

    func getCell(at index: Index, isEditing: Bool)-> SiteCell {
        let props = createCellProps(index, isEditing)
        return dequeueCell()?.configure(props: props) ?? SiteCell()
    }

    func prepareCellsForEditMode(editingState: SiteCellEditingState) {
        table.isEditing = editingState == .Editing
        for i in 0..<cellCount {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = getCell(at: indexPath.row, isEditing: table.isEditing)
            cell.handleEditingStateChange(cellIndex: i, editingState: editingState)
        }
    }

    func deleteCell(indexPath: IndexPath) {
        table.deleteRows(at: [indexPath], with: .fade)
        table.reloadData()
        if indexPath.row < cellCount {
            resetCellColors(startIndex: indexPath.row)
        }
    }

    private func createCellProps(_ siteIndex: Index, _ isEditing: Bool) -> SiteCellProperties {
        var props = SiteCellProperties(nextSiteIndex: siteIndex, isEditing: isEditing)
        if let sites = sites {
            props.nextSiteIndex = sites.nextIndex
            props.totalSiteCount = sites.count
            if let site = sites.at(siteIndex) {
                props.site = site
            }
            if let theme = stylist?.theme {
                props.theme = theme
            }
        }
        return props
    }

    private func resetCellColors(startIndex: Index) {
        for i in startIndex..<cellCount {
            let nextIndexPath = IndexPath(row: i, section: 0)
            let cell = getCell(at: nextIndexPath.row, isEditing: false)
            cell.backgroundColor = stylist?.getCellColor(at: i)
        }
    }
}
