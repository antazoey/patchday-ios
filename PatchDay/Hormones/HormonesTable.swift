//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit


class HormonesTable: TableViewWrapper<HormoneCell> {

    init(_ table: UIKit.UITableView) {
        super.init(table, primaryCellReuseId: CellReuseIds.Hormone)
    }

    func applyTheme(_ theme: AppTheme?) {
        table.backgroundColor = theme?[.bg]
        table.separatorColor = theme?[.border]
    }
}
