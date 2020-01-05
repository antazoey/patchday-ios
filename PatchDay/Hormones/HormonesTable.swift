//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class HormonesTable: TableViewWrapper<HormoneCell> {

    init(_ table: UITableView) {
        super.init(table, primaryCellReuseId: CellReuseIds.Hormone)
    }

    func getCell(for hormone: Hormonal, at index: Index, viewModel: HormonesViewModel) -> HormoneCell {
        if let cell = dequeueCell() {
            return cell.configure(viewModel: viewModel, hormone: hormone, row: index)
        }
        return HormoneCell()
    }

    func getCellRowHeight(viewHeight: CGFloat) -> CGFloat {
        viewHeight * 0.24
    }

    func applyTheme(_ theme: AppTheme?) {
        table.backgroundColor = theme?[.bg]
        table.separatorColor = theme?[.border]
    }
}
