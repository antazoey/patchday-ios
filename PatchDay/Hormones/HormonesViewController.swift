//
//  HormonesViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 1/8/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import Foundation
import PDKit

class HormonesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet var hormonesView: UIView!
	@IBOutlet weak var hormonesTableView: UITableView!

	var viewModel: HormonesViewModel!

	override func viewDidLoad() {
		super.viewDidLoad()
		initViewModel()
		assignSelfAsTableDelegate()
		loadTitle()
		loadBarButtons()
		applyTheme()
	}

	override func viewDidAppear(_ animated: Bool) {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(willEnterForeground),
			name: UIApplication.willEnterForegroundNotification,
			object: nil
		)
		super.viewDidAppear(false)
	}
	
	@objc func willEnterForeground() {
		initViewModel()
		fadeInView()
		viewModel.presentDisclaimerAlertIfFirstLaunch()
		loadTitle()
		viewModel.table.reloadData()
		viewModel.updateSiteImages()
		applyTheme()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		viewModel.tabs?.reflectHormoneCharacteristics()
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		viewModel.table.getCellRowHeight(viewHeight: view.frame.height)
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		SupportedHormoneUpperQuantityLimit
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		viewModel[indexPath.row]
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		viewModel.handleRowTapped(at: indexPath.row, self)
	}

	// MARK: - Actions

	@objc func settingsTapped() {
		viewModel.nav?.goToSettings(source: self)
	}

	// MARK: - Private

	private func initViewModel() {
		viewModel = HormonesViewModel(hormonesTableView: hormonesTableView, style: getStyle())
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
		navigationItem.rightBarButtonItems = [settingsButton]

		let backItem = PDViewFactory.createTextBarButtonItem(PDTitleStrings.HormonesTitle)
		navigationItem.backBarButtonItem = backItem
	}

	private func loadTitle() {
		title = viewModel.mainViewControllerTitle
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
