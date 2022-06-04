//
//  HormonesViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 1/8/17.

import UIKit
import Foundation
import PDKit

class HormonesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var hormonesView: UIView!
    @IBOutlet weak var hormonesTableView: UITableView!

    var viewModel: HormonesViewModelProtocol!
    private static let siteImageHistory = SiteImageHistory()

    override func viewDidLoad() {
        super.viewDidLoad()
        willEnterForeground()
        assignSelfAsTableDelegate()
        loadTitle()
        loadBarButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        fadeInView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        willEnterForeground()
        super.viewDidAppear(animated)
    }

    @objc func willEnterForeground() {
        initViewModel()
        viewModel.presentDisclaimerAlertIfFirstLaunch()
        loadTitle()
        viewModel.table.reloadData()
        applyTheme()
        viewModel.setWidget()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.tabs?.reflectHormones()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.table.getCellRowHeight(viewHeight: view.frame.height)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SUPPORTED_HORMONE_UPPER_QUANTITY_LIMIT
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel[indexPath.row] as! UITableViewCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.handleRowTapped(at: indexPath.row, self) {
            self.initViewModel()
            self.hormonesTableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    // MARK: - Actions

    @objc func settingsTapped() {
        viewModel.nav?.goToSettings(source: self)
    }

    // MARK: - Private

    private func initViewModel() {
        let style = getStyle()
        viewModel = HormonesViewModel(
            siteImageHistory: HormonesViewController.siteImageHistory,
            hormonesTableView: hormonesTableView,
            style: style
        )
        viewModel.loadAppTabs(source: self)
    }

    private func assignSelfAsTableDelegate() {
        hormonesTableView.dataSource = self
        hormonesTableView.delegate = self
    }

    private func loadBarButtons() {
        let settingsButton = PDViewFactory.createIconBarButtonItem(PDIcons.settingsIcon)
        settingsButton.target = self
        settingsButton.action = #selector(settingsTapped)
        settingsButton.accessibilityIdentifier = "settingsGearButton"
        navigationItem.rightBarButtonItems = [settingsButton]
        let backItem = PDViewFactory.createTextBarButtonItem(PDTitleStrings.HormonesTitle)
        navigationItem.backBarButtonItem = backItem
    }

    private func loadTitle() {
        guard title != viewModel.title else { return }
        title = viewModel.title
    }

    private func fadeInView() {
        UIView.animate(
            withDuration: 1.0, delay: 0.0,
            options: UIView.AnimationOptions.curveEaseIn,
            animations: { self.view.alpha = 1.0 },
            completion: nil
        )
    }

    @objc func updateFromBackground() {
        hormonesTableView.reloadData()
    }

    private func applyTheme() {
        hormonesView.backgroundColor = UIColor.systemBackground
        view.backgroundColor = UIColor.systemBackground
    }
}
