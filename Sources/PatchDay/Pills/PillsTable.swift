//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PillsTable: TableViewWrapper<PillCell>, PillsTableProtocol {

    private let pills: PillScheduling?

    init(_ table: UITableView, pills: PillScheduling?) {
        self.pills = pills
        super.init(table, primaryCellReuseId: CellReuseIds.Pill)
        applyTheme()
        table.allowsSelectionDuringEditing = true
    }

    subscript(index: Index) -> PillCellProtocol {
        guard let pill = pills?[index] else { return PillCell() }
        let params = PillCellConfigurationParameters(pill: pill, index: index)
        return dequeueCell()?.configure(params) ?? PillCell()
    }

    func deleteCell(at indexPath: IndexPath, pillsCount: Int) {
        table.deleteRows(at: [indexPath], with: .fade)
        let start = indexPath.row
        let count = pillsCount
        let end = count - 1
        if start <= end {
            for i in start...end {
                self[i].loadBackground()
            }
        }
        table.reloadData()
    }

    func setBackgroundView(isEnabled: Bool) {
        if isEnabled {
            table.backgroundView = nil
            table.separatorStyle = .singleLine
        } else {
            table.separatorStyle = .none
            let label = UILabel()
            label.numberOfLines = 2
            label.textColor = PDColors[.Text]
            let comment = "Text for an empty table view."
            let body = "Pills are currently disabled.\n Use the switch at the top to enable."
            label.text = NSLocalizedString(body, comment: comment)
            label.textAlignment = .center
            table.backgroundView = label
        }
    }

    private func applyTheme() {
        table.backgroundColor = UIColor.systemBackground
        table.separatorColor = PDColors[.Border]
    }
}
