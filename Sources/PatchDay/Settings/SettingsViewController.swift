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

    private var viewModel: SettingsViewModel?
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
    @IBOutlet weak var xDaysStack: UIStackView!
    @IBOutlet private weak var quantityStack: UIStackView!
    @IBOutlet private weak var notificationsStack: UIStackView!
    @IBOutlet private weak var notificationsMinutesBeforeStack: UIStackView!

    // Labels
    @IBOutlet private weak var deliveryMethodLabel: UILabel!
    @IBOutlet private weak var expirationIntervalLabel: UILabel!

    @IBOutlet weak var xDaysLabel: UILabel!
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var notificationsLabel: UILabel!
    @IBOutlet private weak var notificationsMinutesBeforeLabel: UILabel!
    @IBOutlet private weak var notificationsMinutesBeforeValueLabel: UILabel!

    // Pickers
    @IBOutlet private weak var deliveryMethodPicker: SettingsPickerView!
    @IBOutlet private weak var expirationIntervalPicker: SettingsPickerView!
    @IBOutlet private weak var quantityPicker: SettingsPickerView!

    // Buttons
    @IBOutlet private weak var deliveryMethodButton: UIButton!
    @IBOutlet private weak var expirationIntervalButton: UIButton!
    @IBOutlet weak var xDaysButton: UIButton!
    @IBOutlet private weak var quantityButton: UIButton!
    @IBOutlet private weak var quantityArrowButton: UIButton!

    // Icons
    @IBOutlet private weak var deliveryMethodIcon: UIImageView!
    @IBOutlet private weak var expirationIntervalIcon: UIImageView!
    @IBOutlet weak var xDaysIcon: UIImageView!
    @IBOutlet private weak var quantityIcon: UIImageView!
    @IBOutlet private weak var notificationsIcon: UIImageView!
    @IBOutlet private weak var notificationsMinutesBeforeIcon: UIImageView!

    // Other Controls
    @IBOutlet private weak var notificationsSwitch: UISwitch!
    @IBOutlet private weak var notificationsMinutesBeforeSlider: UISlider!

    // Views
    @IBOutlet private weak var deliveryMethodSideView: UIView!
    @IBOutlet private weak var expirationIntervalSideView: UIView!

    @IBOutlet weak var xDaysSideView: UIView!
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
        quantityPicker.isHidden = true
        assignSelfAsDelegateForPickers()
        initViewModel()
        viewModel?.reflector.reflect()
        applyTheme()
        loadButtonDisabledStates()
    }

    private var controlsStruct: SettingsControls {
        SettingsControls(
            deliveryMethodButton: self.deliveryMethodButton,
            quantityButton: self.quantityButton,
            quantityArrowButton: self.quantityArrowButton,
            expirationIntervalButton: self.expirationIntervalButton,
            notificationsSwitch: self.notificationsSwitch,
            notificationsMinutesBeforeSlider: self.notificationsMinutesBeforeSlider,
            notificationsMinutesBeforeValueLabel: self.notificationsMinutesBeforeValueLabel
        )
    }

    static func create() -> UIViewController {
        let storyboard = UIStoryboard.createSettingsStoryboard()
        return storyboard.instantiateViewController(withIdentifier: ViewControllerIds.Settings)
    }

    // MARK: - Actions

    @IBAction func notificationsMinutesBeforeValueChanged(_ sender: Any) {
        let newValue = notificationsMinutesBeforeSlider.value.rounded()
        viewModel?.handleNewNotificationsValue(newValue)
        notificationsMinutesBeforeValueLabel.text = String(newValue)
    }

    /// The settings buttons with pickers i.e. `deliveryMethodButton`, `quantityButton` all point here.
    @IBAction func selectSettingButtonTapped(_ sender: UIButton) {
        guard let setting = sender.tryGetSettingFromButtonMetadata() else { return }
        handlePickerActivation(setting)
    }

    @IBAction func notificationsSwitched(_ sender: Any) {
        reflectNotificationSwitchInNotificationButtons()
        viewModel?.sdk?.settings.setNotifications(to: notificationsSwitch.isOn)
    }

    // MARK: - Picker Delegate Functions

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        DefaultNumberOfPickerComponents
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let settingsPicker = pickerView as? SettingsPickerView else { return 0 }
        return settingsPicker.options?.count ?? 0
    }

    func pickerView(
        _ pickerView: UIPickerView,
        attributedTitleForRow row: Int,
        forComponent component: Int
    ) -> NSAttributedString? {
        let settingsPicker = pickerView as? SettingsPickerView
        let title = settingsPicker?.options?.tryGet(at: row) ?? ""
        let textColor = PDColors[.Text]
        return NSAttributedString(
            string: title, attributes: [NSAttributedString.Key.foregroundColor: textColor]
        )
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let settingsPicker = pickerView as? SettingsPickerView else { return }
        let title = settingsPicker.options?.tryGet(at: row) ?? ""
        settingsPicker.activator.setTitle(title)
    }

    private func initViewModel() {
        self.viewModel = SettingsViewModel(controls: controlsStruct)
    }

    private func handlePickerActivation(_ setting: PDSetting) {
        guard let viewModel = viewModel else { return }
        guard let picker = selectPicker(setting: setting) else { return }
        viewModel.activatePicker(picker)
    }

    // MARK: - View loading and altering

    private func reflectNotificationSwitchInNotificationButtons() {
        notificationsSwitch.isOn ? enableNotificationButtons() : disableNotificationButtons()
    }

    private func enableNotificationButtons() {
        notificationsMinutesBeforeSlider.isEnabled = true
        notificationsMinutesBeforeValueLabel.textColor = PDColors[.Text]
    }

    private func disableNotificationButtons() {
        let disabledValue = 0
        viewModel?.sdk?.settings.setNotificationsMinutesBefore(to: disabledValue)
        notificationsMinutesBeforeSlider.isEnabled = false
        notificationsMinutesBeforeValueLabel.textColor = UIColor.lightGray
        notificationsMinutesBeforeValueLabel.text = String(disabledValue)
        notificationsMinutesBeforeSlider.value = Float(disabledValue)
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
        xDaysIcon.image = xDaysIcon.image?.withTintColor(textColor)
        quantityIcon.image = quantityIcon.image?.withTintColor(textColor)
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

    private func selectPicker(setting: PDSetting) -> SettingsPickerView? {
        var picker: SettingsPickerView?
        switch setting {
            case.Quantity: picker = quantityPicker
            case .DeliveryMethod: picker = deliveryMethodPicker
            case .ExpirationInterval: picker = expirationIntervalPicker
            default:
                log.error("No picker for given setting \(setting)")
                return nil
        }
        if let picker = picker {
            deselectOtherPickers(besides: picker)
        }
        return picker
    }

    private func deselectOtherPickers(besides selectedPicker: UIPickerView) {
        let pickers = [quantityPicker, deliveryMethodPicker, expirationIntervalPicker]
        for picker in pickers where picker != selectedPicker {
            picker?.close(setSelectedRow: false)
        }
    }

    private func setPickers() {
        guard let viewModel = self.viewModel else { return }
        setPicker(
            deliveryMethodPicker,
            .DeliveryMethod,
            deliveryMethodButton, { viewModel.deliveryMethodStartIndex }
        )
        setPicker(
            expirationIntervalPicker,
            .ExpirationInterval,
            expirationIntervalButton, { viewModel.expirationIntervalStartIndex }
        )
        setPicker(
            quantityPicker,
            .Quantity,
            quantityButton, { viewModel.quantityStartIndex }
        )
    }

    private func setPicker(
        _ picker: SettingsPickerView,
        _ setting: PDSetting,
        _ button: UIButton,
        _ getStartRow: @escaping () -> (Index)
    ) {
        picker.setting = setting
        picker.activator = button
        picker.getStartRow = getStartRow
        picker.options = SettingsOptions[setting]
    }
}

extension SettingsViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { settingsStack }
}
