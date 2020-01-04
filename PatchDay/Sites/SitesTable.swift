//
// Created by Juliya Smith on 12/4/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class SitesTable: TableViewWrapper<SiteCell> {

    var sites: HormoneSiteScheduling?
    var stylist: Styling?

    let RowHeight: CGFloat = 55.0

    init(_ table: UITableView) {
        super.init(table, primaryCellReuseId: CellReuseIds.Site)
        table.backgroundColor = stylist?.theme[.bg]
        table.separatorColor = stylist?.theme[.border]
        table.allowsSelectionDuringEditing = true
    }

    func reloadCells() {
        reloadData()
        table.isEditing = false
        let range = 0..<(sites?.count ?? 0)
        let indexPathsToReload = range.map({ (value: Int) -> IndexPath in IndexPath(row: value, section: 0)})
        table.reloadRows(at: indexPathsToReload, with: .automatic)
        resetCellColors(startIndex: 0)
    }

    func getCell(at index: Index)-> SiteCell {
        let props = createCellProps(index)
        return dequeueCell()?.configure(props: props) ?? SiteCell()
    }

    func prepareCellsForEditMode(editingState: SiteTableActionState) {
        table.isEditing = editingState == .Editing
        for i in 0..<cellCount {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = getCell(at: indexPath.row)
            cell.reflectActionState(cellIndex: i, actionState: editingState)
        }
    }

    func deleteCell(indexPath: IndexPath) {
        table.deleteRows(at: [indexPath], with: .fade)
        table.reloadData()
        if indexPath.row < cellCount {
            resetCellColors(startIndex: indexPath.row)
        }
    }

    private func createCellProps(_ siteIndex: Index) -> SiteCellProperties {
        var props = SiteCellProperties(nextSiteIndex: siteIndex)
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
            let cell = getCell(at: nextIndexPath.row)
            cell.backgroundColor = stylist?.getCellColor(at: i)
        }
    }
}
