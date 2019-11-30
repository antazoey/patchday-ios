//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PillsTable {

    private let table: UITableView

    init(_ table: UITableView) {
        self.table = table
    }

    func getCellForRowAt(_ index: Index) -> PillCell? {
        table.dequeuePillCell()
    }

    func deleteCell(at indexPath: IndexPath, pillsCount: Int) {
        //viewModel.pills?.delete(at: indexPath.row)
        table.deleteRows(at: [indexPath], with: .fade)
        table.reloadData()
        //setBadge()
        let start = indexPath.row
        let count = pillsCount ?? (start + 1)
        let end = count - 1
        if start <= end {
            for i in start...end {
                getCellForRowAt(i)?.loadBackground()
            }
        }
    }
}
