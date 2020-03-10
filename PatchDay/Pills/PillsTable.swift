//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class PillsTable: TableViewWrapper<PillCell> {

    private let pills: PillScheduling?
    private let styles: Styling?

    init(_ table: UITableView, pills: PillScheduling?, styles: Styling?) {
        self.pills = pills
        self.styles = styles
        super.init(table, primaryCellReuseId: CellReuseIds.Pill)
        applyTheme()
        table.allowsSelectionDuringEditing = true
    }

    func getCell(at index: Index)-> PillCell {
        guard let pill = pills?.at(index) else { return PillCell() }
        let params = PillCellConfigurationParameters(pill: pill, index: index, styles: styles)
        return dequeueCell()?.configure(params) ?? PillCell()
    }

    func deleteCell(at indexPath: IndexPath, pillsCount: Int) {
        table.deleteRows(at: [indexPath], with: .fade)
        let start = indexPath.row
        let count = pillsCount
        let end = count - 1
        if start <= end {
            for i in start...end {
                getCell(at: i).loadBackground()
            }
        }
        table.reloadData()
    }
    
    private func applyTheme() {
        if let styles = styles {
            table.backgroundColor = styles.theme[.bg]
            table.separatorColor = styles.theme[.border]
        }
    }
}
