//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class HormonesTable: TableViewWrapper<HormoneCell> {

    private var _cells: [HormoneCell] = []

    init(_ table: UITableView) {
        super.init(table, primaryCellReuseId: CellReuseIds.Hormone)
    }
    
    var cells: [HormoneCell] {
        _cells
    }

    func reflectModel(sdk: PatchDataSDK?, styles: Styling?) {
        _cells = []
        guard let sdk = sdk else { return }
        guard let styles = styles else { return }
        for row in 0..<SupportedHormoneUpperQuantityLimit {
            if let cell = dequeueCell() {
                cell.configure(at: row, sdk: sdk, styles: styles)
                _cells.append(cell)
            }
        }
    }

    func getCellRowHeight(viewHeight: CGFloat) -> CGFloat {
        viewHeight * 0.24
    }

    func applyTheme(_ theme: AppTheme?) {
        table.backgroundColor = theme?[.bg]
        table.separatorColor = theme?[.border]
    }
}
