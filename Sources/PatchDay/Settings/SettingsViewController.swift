//
//  SettingsViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/20/17.

import UIKit
import PDKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    override public var description: String {
        "The view controller for configuring Application settings."
    }

    private var viewModel: SettingsViewModelProtocol?
    private lazy var log = PDLog<SettingsViewController>()

    // Containers
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var settingsStack: UIStackView!
    @IBOutlet private weak var settingsView: UIView!
    @IBOutlet private weak var expirationMinutesSliderContainer: UIView!
    @IBOutlet private weak var notificationsSwitchContainer: UIView!

    // StackViews
    @IBOutlet private weak var deliveryMethodStack: UIStackView!
    @IBOutlet private weak var expirationIntervalStack: UIStackView!
    @IBOutlet private weak var quantityStack: UIStackView!
    @IBOutlet weak var useStaticExpirationTimeStack: UIStackView!
    @IBOutlet private weak var notificationsStack: UIStackView!
    @IBOutlet private weak var notificationsMinutesBeforeStack: UIStackView!

    // Labels
    @IBOutlet private weak var deliveryMethodLabel: UILabel!
    @IBOutlet private weak var expirationIntervalLabel: UILabel!

    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var notificationsLabel: UILabel!
    @IBOutlet private weak var notificationsMinutesBeforeLabel: UILabel!
    @IBOutlet private weak var notificationsMinutesBeforeValueLabel: UILabel!

    // Pickers
    @IBOutlet private weak var deliveryMethodPicker: DeliveryMethodPicker!
    @IBOutlet private weak var expirationIntervalPicker: ExpirationIntervalSettingsPicker!
    @IBOutlet private weak var quantityPicker: QuantityPicker!

    // Buttons
    @IBOutlet private weak var deliveryMethodButton: SettingsPickerActivator!
    @IBOutlet private weak var expirationIntervalButton: SettingsPickerActivator!
    @IBOutlet private weak var quantityButton: SettingsPickerActivator!
    @IBOutlet private weak var quantityArrowButton: SettingsPickerActivator!

    // Icons
    @IBOutlet private weak var deliveryMethodIcon: UIImageView!
    @IBOutlet private weak var expirationIntervalIcon: UIImageView!
    @IBOutlet private weak var quantityIcon: UIImageView!
    @IBOutlet weak var staticExpirationTimeIcon: UIImageView!
    @IBOutlet private weak var notificationsIcon: UIImageView!
    @IBOutlet private weak var notificationsMinutesBeforeIcon: UIImageView!

    // Other Controls
    @IBOutlet weak var useStaticExpirationTimeSwitch: UISwitch!
    @IBOutlet private weak var notificationsSwitch: UISwitch!
    @IBOutlet private weak var notificationsMinutesBeforeSlider: UISlider!

    // Views
    @IBOutlet private weak var deliveryMethodSideView: UIView!
    @IBOutlet private weak var expirationIntervalSideView: UIView!

    @IBOutlet private weak var quantitySideView: UIView!
    @IBOutlet private weak var notificationsSideView: UIView!
    @IBOutlet private weak var notificationsMinutesBeforeSideView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        willEnterForeground()
        title = PDTitleStrings.SettingsTitle
        setTopConstraint()
        loadButtonDisabledStates()
        setPickers()
    }

    override func viewDidAppear(_ animated: Bool) {
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
        assignSelfAsDelegateForPickers()
        let viewModel = initViewModel()
        viewModel.reflect()
        applyTheme()
        loadButtonDisabledStates()
    }

    private var controlsStruct: SettingsControls {
        SettingsControls(
            deliveryMethodButton: deliveryMethodButton,
            quantityButton: quantityButton,
            quantityArrowButton: quantityArrowButton,
            expirationIntervalButton: expirationIntervalButton,
            notificationsSwitch: notificationsSwitch,
            notificationsMinutesBeforeSlider: notificationsMinutesBeforeSlider,
            notificationsMinutesBeforeValueLabel: notificationsMinutesBeforeValueLabel,
            useStaticExpirationTimeSwitch: useStaticExpirationTimeSwitch
        )
    }

    private var pickers: SettingsPickerList {
        SettingsPickerList(
            quantityPicker: quantityPicker,
            deliveryMethodPicker: deliveryMethodPicker,
            expirationIntervalPicker: expirationIntervalPicker
        )
    }

    static func create() -> UIViewController {
        let storyboard = UIStoryboard.createSettingsStoryboard()
        return storyboard.instantiateViewController(withIdentifier: ViewControllerIds.Settings)
    }

    // MARK: - Actions

    @IBAction func notificationsMinutesBeforeValueChanged(_ sender: Any) {
        let newValue = notificationsMinutesBeforeSlider.value
        let titleString = viewModel?.handleNewNotificationsMinutesValue(newValue)
        notificationsMinutesBeforeValueLabel.text = titleString
    }

    /// The settings buttons with pickers i.e. `deliveryMethodButton`, `quantityButton` all point here.
    @IBAction func settingButtonTapped(_ sender: SettingsPickerActivator) {
        guard let setting = sender.getSettingFromButtonRestorationId() else { return }
        handlePickerActivation(setting)
    }

    @IBAction func useStaticExpirationTimeSwitched(_ sender: Any) {
        viewModel?.setUseStaticExpirationTime(useStaticExpirationTimeSwitch.isOn)
    }

    @IBAction func notificationsSwitched(_ sender: Any) {
        reflectNotificationSwitchInNotificationButtons()
        viewModel?.setNotifications(notificationsSwitch.isOn)
    }

    // MARK: - Picker Delegate Functions

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        DefaultNumberOfPickerComponents
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        (pickerView as? SettingsPicking)?.count ?? 0
    }

    func pickerView(
        _ pickerView: UIPickerView,
        attributedTitleForRow row: Int,
        forComponent component: Int
    ) -> NSAttributedString? {
        (pickerView as? SettingsPicker)?[row]
    }

    private func initViewModel() -> SettingsViewModel {
        let viewModel = SettingsViewModel(controls: controlsStruct)
        self.viewModel = viewModel
        return viewModel
    }

    private func handlePickerActivation(_ setting: PDSetting) {
        guard let viewModel = viewModel else { return }
        guard let picker = pickers.select(setting) else { return }
        viewModel.activatePicker(picker)
    }

    // MARK: - View loading and altering

    private func reflectNotificationSwitchInNotificationButtons() {
        if notificationsSwitch.isOn {
            enableNotificationButtons()
        } else {
            disableNotificationButtons()
        }
    }

    private func enableNotificationButtons() {
        notificationsMinutesBeforeSlider.isEnabled = true
        notificationsMinutesBeforeValueLabel.textColor = PDColors[.Text]
    }

    private func disableNotificationButtons() {
        let disabledValue = 0
        notificationsMinutesBeforeSlider.isEnabled = false
        notificationsMinutesBeforeSlider.value = Float(disabledValue)
        notificationsMinutesBeforeValueLabel.textColor = UIColor.lightGray
        notificationsMinutesBeforeValueLabel.text = String(disabledValue)
    }

    private func loadButtonDisabledStates() {
        quantityButton.setTitleColor(UIColor.lightGray, for: .disabled)
    }

    private func setTopConstraint() {
        guard AppDelegate.isPad else { return }
        topConstraint.constant = 100
    }

    private func applyTheme() {
        let textColor = PDColors[.Text]
        view.backgroundColor = UIColor.systemBackground
        deliveryMethodIcon.image = deliveryMethodIcon.image?.withTintColor(textColor)
        expirationIntervalIcon.image = expirationIntervalIcon.image?.withTintColor(textColor)
        quantityIcon.image = quantityIcon.image?.withTintColor(textColor)
        staticExpirationTimeIcon.image = staticExpirationTimeIcon.image?.withTintColor(textColor)
        notificationsIcon.image = notificationsIcon.image?.withTintColor(textColor)
        let tintedImage = notificationsMinutesBeforeIcon.image?.withTintColor(textColor)
        notificationsMinutesBeforeIcon.image = tintedImage
        view.setNeedsDisplay()
    }

    private func assignSelfAsDelegateForPickers() {
        deliveryMethodPicker.delegate = self
        deliveryMethodPicker.dataSource = self
        expirationIntervalPicker.delegate = self
        expirationIntervalPicker.dataSource = self
        quantityPicker.delegate = self
        quantityPicker.dataSource = self
    }

    private func setPickers() {
        guard let viewModel = viewModel else { return }
        deliveryMethodPicker.activator = deliveryMethodButton
        deliveryMethodPicker.indexer = viewModel
        quantityPicker.activator = quantityButton
        quantityPicker.indexer = viewModel
        expirationIntervalPicker.activator = expirationIntervalButton
        expirationIntervalPicker.indexer = viewModel
    }
}

extension SettingsViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { settingsStack }
}
