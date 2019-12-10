//
// Created by Juliya Smith on 12/4/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit

class TableViewWrapper<T> where T: TableCell {

    let table: UITableView
    let primaryCellReuseId: String

    init(_ table: UITableView, primaryCellReuseId: String) {
        self.table = table
        self.primaryCellReuseId = primaryCellReuseId
    }

    var cellCount: Int {
        table.numberOfRows(inSection: 0)
    }

    @objc func reload() {
        table.reloadData()
    }

    func dequeueCell() -> T? {
        let cellId = primaryCellReuseId
        return table.dequeueReusableCell(withIdentifier: cellId) as? T
    }
}
