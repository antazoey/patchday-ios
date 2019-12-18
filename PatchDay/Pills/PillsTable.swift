//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PillsTable: TableViewWrapper<PillCell> {

    private let pills: PillScheduling?
    private let theme: AppTheme?

    init(_ table: UITableView, pills: PillScheduling?, theme: AppTheme?) {
        self.pills = pills
        self.theme = theme
        super.init(table, primaryCellReuseId: CellReuseIds.Pill)
        applyTheme()
        table.allowsSelectionDuringEditing = true
    }

    func getCell(at index: Index)-> PillCell {
        if let pill = pills?.at(index) {
            let params = PillCellConfigurationParameters(pill: pill, index: index, theme: theme)
            return dequeueCell()?.configure(params) ?? PillCell()
        }
        return PillCell()
    }

    func deleteCell(at indexPath: IndexPath, pillsCount: Int) {
        table.deleteRows(at: [indexPath], with: .fade)
        let start = indexPath.row
        let count = pillsCount
        let end = count - 1
        if start <= end {
            for i in start...end {
                getCell(at: i).loadBackground(theme)
            }
        }
        table.reloadData()
    }
    
    private func applyTheme() {
        if let theme = theme {
            table.backgroundColor = theme[.bg]
            table.separatorColor = theme[.border]
        }
    }
}
