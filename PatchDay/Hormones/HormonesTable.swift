//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class HormonesTable: TableViewWrapper<HormoneCell>, HormonesTableProtocol {

    private var _cells: [HormoneCellProtocol] = []
    private let sdk: PatchDataSDK?
    private let style: UIUserInterfaceStyle

    init(_ table: UITableView, _ sdk: PatchDataSDK?, _ style: UIUserInterfaceStyle) {
        self.sdk = sdk
        self.style = style
        super.init(table, primaryCellReuseId: CellReuseIds.Hormone)
    }

    var cells: [HormoneCellProtocol] {
        _cells
    }

    func reflectModel() {
        _cells = []
        guard let sdk = sdk else { return }
        for row in 0..<SupportedHormoneUpperQuantityLimit {
            if let cell = dequeueCell() {
                let isPad = AppDelegate.isPad
                let viewModel = HormoneCellViewModel(cellIndex: row, sdk: sdk, isPad: isPad)
                cell.configure(viewModel)
                _cells.append(cell)
            }
        }
        applyTheme()
    }

    func getCellRowHeight(viewHeight: CGFloat) -> CGFloat {
        viewHeight * 0.24
    }

    func applyTheme() {
        table.backgroundColor = UIColor.systemBackground
        table.separatorColor = PDColors[.Border]
    }
}
