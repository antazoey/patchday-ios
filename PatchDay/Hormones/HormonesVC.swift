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
    @IBOutlet weak var hormonalTable: UITableView!
    
    let viewModel = HormonesViewModel()
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadAppTabs(source: self)
        viewModel.reflectThemeInTabBar()
        setDelegates()
        loadTitle()
        loadBarButtons()
        updateFromBackground()
    }
    
    private func setDelegates() {
        hormonalTable.dataSource = self
        hormonalTable.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(
            withDuration: 1.0, delay: 0.0,
            options: UIView.AnimationOptions.curveEaseIn,
            animations: { self.view.alpha = 1.0 },
            completion: nil
        )
        applyTheme()
        viewModel.presentDisclaimerAlert()
        loadTitle()
        hormonalTable.reloadData()
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
        let hormoneIndex = indexPath.row
        if let hormone = viewModel.hormones?.at(hormoneIndex),
            let cell = hormonalTable.dequeueHormoneCell() {

            return cell.configure(viewModel: viewModel, hormone: hormone, hormoneIndex: hormoneIndex)
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mone = viewModel.hormones?.at(indexPath.row) {
            segueToHormoneVC(mone)
        }
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

    private func segueToHormoneVC(_ hormone: Hormonal) {
        app?.nav.goToHormoneDetails(hormone, source: self)
    }

    private func loadTitle() {
        title = viewModel.mainViewControllerTitle
    }
    
    private func applyTheme() {
        if let styles = app?.styles {
            hormonesView.backgroundColor = styles.theme[.bg]
            hormonalTable.backgroundColor = styles.theme[.bg]
            hormonalTable.separatorColor = styles.theme[.border]
        }
    }
}

extension UITableView {
    
    func dequeueHormoneCell() -> HormoneCell? {
         dequeueReusableCell(withIdentifier: "HormoneCellReuseId") as? HormoneCell
    }
}
