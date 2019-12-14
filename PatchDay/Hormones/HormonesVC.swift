//
//  ViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 1/8/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import Foundation
import PDKit


class HormonesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var hormonesView: UIView!
    @IBOutlet weak var hormonesTable: UITableView!
    
    var viewModel: HormonesViewModel?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = HormonesViewModel(table: hormonesTable, source: self)
        loadTitle()
        loadBarButtons()
        updateFromBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fadeInView()
        applyTheme()
        viewModel?.presentDisclaimerAlert()
        loadTitle()
        viewModel?.hormonesTable.reloadData()
        super.viewDidAppear(false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.tabs?.reflectHormoneCharacteristics()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.getCellRowHeight(viewHeight: view.frame.height)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.HormoneMaxCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let hormone = viewModel.hormones?.at(indexPath.row),
            let cell = hormonalTable.dequeueCell() {

            return cell.configure(viewModel: viewModel, hormone: hormone, hormoneIndex: indexPath.row)
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.goToHormoneDetails(hormoneIndex: indexPath.row, hormonesViewController: self)
    }
    
    // MARK: - Actions
    
    @objc func settingsTapped() {
        viewModel.nav?.goToSettings(source: self)
    }

    func updateFromBackground() {
        viewModel.watchHormonesForChanges(selector: #selector(hormonalTable.reloadData))
    }
    
    // MARK: - Private

    private func loadBarButtons() {
        let settingsButton = UIBarButtonItem()
        settingsButton.image = PDImages.settingsIcon
        settingsButton.target = self
        settingsButton.action = #selector(settingsTapped)
        navigationItem.rightBarButtonItems = [settingsButton]
    }

    private func loadTitle() {
        title = viewModel.mainViewControllerTitle
    }
    
    private func applyTheme() {
        if let theme = viewModel.styles?.theme {
            hormonesView.backgroundColor = theme[.bg]
            hormonalTable.backgroundColor = theme[.bg]
            hormonalTable.separatorColor = theme[.border]
        }
    }

    private func fadeInView() {
        UIView.animate(
            withDuration: 1.0, delay: 0.0,
            options: UIView.AnimationOptions.curveEaseIn,
            animations: { self.view.alpha = 1.0 },
            completion: nil
        )
    }
}