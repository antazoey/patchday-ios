//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PillsTable: TableViewWrapper<PillCell> {

    private let pills: PillScheduling?

    init(_ table: UITableView, pills: PillScheduling?) {
        self.pills = pills
        super.init(table, primaryCellReuseId: CellReuseIds.Pill)
    }

    func getCell(at index: Index)-> PillCell {
        if let pill = pills?.at(index) {
            return dequeueCell()?.configure(pill, pillIndex: index) ?? PillCell()
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
                getCell(at: i).loadBackground()
            }
        }
        table.reloadData()
    }
}
