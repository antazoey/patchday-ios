//
//  SettingsView.swift
//  PatchDay
//
//  SwiftUI replacement for SettingsViewController. Writes directly to the
//  PatchData SDK — `SettingsViewModel`/`SettingsReflector`/`SettingsSaver`
//  exist only to coordinate UIKit widgets and are not used here.
//

import SwiftUI
import PDKit
import PatchData
import WidgetKit

struct SettingsView: View {

    @EnvironmentObject private var container: AppContainer

    @State private var deliveryMethod: String = ""
    @State private var quantity: String = ""
    @State private var expirationInterval: String = ""
    @State private var notificationsEnabled: Bool = true
    @State private var notificationsMinutesBefore: Double = 0
    @State private var useStaticExpirationTime: Bool = false

    @State private var pendingDeliveryMethod: DeliveryMethod?
    @State private var pendingQuantity: Int?
    @State private var didPrime = false

    @State private var iCloudSyncEnabled: Bool = false
    @State private var iCloudAccountStatus: CloudKitAccountStatusChecker.Status = .unknown
    @State private var lastSyncDate: Date?
    @State private var showRelaunchAlert: Bool = false

    var body: some View {
        Form {
            Section(NSLocalizedString("Schedule", comment: "")) {
                Picker(
                    NSLocalizedString("Delivery method", comment: ""),
                    selection: $deliveryMethod
                ) {
                    ForEach(SettingsOptions.deliveryMethods, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("deliveryMethodButton")
                .onChange(of: deliveryMethod) { _, newValue in
                    let next = SettingsOptions.getDeliveryMethod(for: newValue)
                    let current = container.sdk?.settings.deliveryMethod.value
                    guard next != current else { return }
                    pendingDeliveryMethod = next
                }

                Picker(
                    NSLocalizedString("Expiration interval", comment: ""),
                    selection: $expirationInterval
                ) {
                    ForEach(SettingsOptions.expirationIntervals, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("expirationIntervalButton")
                .onChange(of: expirationInterval) { _, newValue in
                    guard let settings = container.sdk?.settings else { return }
                    let current = SettingsOptions.getExpirationInterval(for: settings.expirationInterval)
                    guard newValue != current else { return }
                    settings.setExpirationInterval(to: newValue)
                }

                Picker(
                    NSLocalizedString("Quantity", comment: ""),
                    selection: $quantity
                ) {
                    ForEach(SettingsOptions.quantities, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("settingsQuantityButton")
                .onChange(of: quantity) { _, newValue in
                    guard let asInt = Int(newValue) else { return }
                    let current = container.sdk?.settings.quantity.rawValue ?? 0
                    guard asInt != current else { return }
                    if asInt < current {
                        pendingQuantity = asInt
                    } else {
                        applyQuantity(asInt)
                    }
                }
            }

            Section(NSLocalizedString("Notifications", comment: "")) {
                Toggle(
                    NSLocalizedString("Notifications enabled", comment: ""),
                    isOn: $notificationsEnabled
                )
                    .accessibilityIdentifier("notificationsSwitch")
                    .onChange(of: notificationsEnabled) { _, value in
                        container.sdk?.settings.setNotifications(to: value)
                        if value {
                            container.notifications?.requestAllExpiredHormoneNotifications()
                        } else {
                            container.notifications?.cancelAllExpiredHormoneNotifications()
                            notificationsMinutesBefore = 0
                            container.sdk?.settings.setNotificationsMinutesBefore(to: 0)
                        }
                    }

                if notificationsEnabled {
                    let prefix = NSLocalizedString("Notify minutes before:", comment: "")
                    VStack(alignment: .leading) {
                        Text("\(prefix) \(Int(notificationsMinutesBefore))")
                            .font(.subheadline)
                            .accessibilityIdentifier("notificationsMinutesBeforeValueLabel")
                        Slider(
                            value: $notificationsMinutesBefore,
                            in: 0...Double(DefaultSettings.MAX_SUPPORTED_NOTIFICATIONS_MINUTES_BEFORE),
                            step: 1,
                            onEditingChanged: { editing in
                                guard !editing else { return }
                                let value = Int(notificationsMinutesBefore)
                                container.notifications?.cancelAllExpiredHormoneNotifications()
                                container.sdk?.settings.setNotificationsMinutesBefore(to: value)
                                container.notifications?.requestAllExpiredHormoneNotifications()
                            }
                        )
                        .accessibilityIdentifier("notificationsMinutesBeforeSlider")
                    }
                }
            }

            Section {
                // UI shows the inverse of the stored `useStaticExpirationTime`
                // setting. Most people want static expiration times (so the
                // suggested expiration matches the original application time);
                // exposing the off-by-default opposite reads cleaner than
                // "Use static expiration time" and keeps the storage key
                // backwards-compatible.
                Toggle(
                    NSLocalizedString("Dynamic expiration time", comment: ""),
                    isOn: Binding(
                        get: { !useStaticExpirationTime },
                        set: { useStaticExpirationTime = !$0 }
                    )
                )
                    .accessibilityIdentifier("dynamicExpirationTimeSwitch")
                    .onChange(of: useStaticExpirationTime) { _, value in
                        // Skip the hydration write — prime() assigns this
                        // state from the SDK on appear, which would
                        // otherwise persist a no-op write every time the
                        // user navigates to Settings.
                        guard didPrime,
                            value != container.sdk?.settings.useStaticExpirationTime.value
                        else { return }
                        container.sdk?.settings.setUseStaticExpirationTime(to: value)
                    }
            } footer: {
                Text(NSLocalizedString(
                    "When on, suggested expiration times shift to the current time of day each time you apply a hormone. Off keeps your original applied time.",
                    comment: "Setting footer"
                ))
            }

            Section {
                Toggle(
                    NSLocalizedString("Sync with iCloud", comment: ""),
                    isOn: $iCloudSyncEnabled
                )
                    .accessibilityIdentifier("iCloudSyncSwitch")
                    .disabled(
                        iCloudAccountStatus == .noAccount
                            || iCloudAccountStatus == .restricted
                    )
                    .onChange(of: iCloudSyncEnabled) { _, value in
                        // Skip the hydration write — prime() assigns this
                        // state from UserDefaults on appear, which would
                        // otherwise fire a spurious relaunch alert every
                        // time the user navigates to Settings.
                        let stored = UserDefaults.standard.bool(
                            forKey: PDLocalSettingsKey.iCloudSyncEnabled.rawValue
                        )
                        guard value != stored else { return }
                        UserDefaults.standard.set(
                            value, forKey: PDLocalSettingsKey.iCloudSyncEnabled.rawValue
                        )
                        showRelaunchAlert = true
                    }
                if let helperText = iCloudUnavailableHelperText {
                    Text(helperText)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(NSLocalizedString("iCloud account", comment: ""))
                    Spacer()
                    Text(accountStatusLabel)
                        .foregroundColor(.secondary)
                }
                if iCloudSyncEnabled, let date = lastSyncDate {
                    HStack {
                        Text(NSLocalizedString("Last synced", comment: ""))
                        Spacer()
                        Text(date, style: .relative)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text(NSLocalizedString("iCloud", comment: ""))
            } footer: {
                Text(NSLocalizedString(
                    "When on, your hormones, pills, sites, and most settings sync across your devices using your iCloud account. PatchDay never sees your data. Turning sync off stops this device from syncing but does not delete your iCloud records — to remove those, go to iOS Settings → [Your Name] → iCloud → Manage Storage → PatchDay.",
                    comment: "iCloud setting footer"
                ))
            }

            #if DEBUG
            Section {
                NavigationLink(NSLocalizedString("Developer tools", comment: "")) {
                    DeveloperToolsView()
                }
                .accessibilityIdentifier("developerToolsLink")
            }
            #endif
        }
        .navigationTitle(PDTitleStrings.SettingsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            NSLocalizedString("Change delivery method?", comment: ""),
            isPresented: deliveryAlertBinding,
            presenting: pendingDeliveryMethod
        ) { method in
            Button(ActionStrings.Continue, role: .destructive) {
                applyDeliveryMethod(method)
            }
            Button(ActionStrings.Cancel, role: .cancel) {
                deliveryMethod = SettingsOptions.getDeliveryMethodString(
                    for: container.sdk?.settings.deliveryMethod.value ?? .Patches
                )
            }
        } message: { _ in
            Text(NSLocalizedString(
                "Switching the delivery method will reset your sites and quantity.",
                comment: ""
            ))
        }
        .alert(
            NSLocalizedString("Reduce quantity?", comment: ""),
            isPresented: quantityAlertBinding,
            presenting: pendingQuantity
        ) { value in
            Button(ActionStrings.Continue, role: .destructive) {
                applyQuantity(value)
            }
            Button(ActionStrings.Cancel, role: .cancel) {
                quantity = String(container.sdk?.settings.quantity.rawValue ?? 1)
            }
        } message: { _ in
            Text(NSLocalizedString(
                "Reducing quantity removes the extra hormones from your schedule.",
                comment: ""
            ))
        }
        .alert(
            NSLocalizedString("Relaunch required", comment: ""),
            isPresented: $showRelaunchAlert
        ) {
            Button(NSLocalizedString("OK", comment: "Button"), role: .cancel) { }
        } message: {
            Text(NSLocalizedString(
                "Quit and reopen PatchDay to apply the iCloud sync change.",
                comment: ""
            ))
        }
        .onAppear(perform: prime)
    }

    // MARK: - Helpers

    private var deliveryAlertBinding: Binding<Bool> {
        Binding(
            get: { pendingDeliveryMethod != nil },
            set: { if !$0 { pendingDeliveryMethod = nil } }
        )
    }

    private var quantityAlertBinding: Binding<Bool> {
        Binding(
            get: { pendingQuantity != nil },
            set: { if !$0 { pendingQuantity = nil } }
        )
    }

    private func prime() {
        guard !didPrime, let settings = container.sdk?.settings else { return }
        didPrime = true
        deliveryMethod = SettingsOptions.getDeliveryMethodString(for: settings.deliveryMethod.value)
        quantity = String(settings.quantity.rawValue)
        expirationInterval = SettingsOptions.getExpirationInterval(for: settings.expirationInterval)
        notificationsEnabled = settings.notifications.value
        notificationsMinutesBefore = Double(settings.notificationsMinutesBefore.value)
        useStaticExpirationTime = settings.useStaticExpirationTime.value
        iCloudSyncEnabled = UserDefaults.standard.bool(
            forKey: PDLocalSettingsKey.iCloudSyncEnabled.rawValue
        )
        lastSyncDate = UserDefaults.standard.object(
            forKey: PDLocalSettingsKey.lastICloudSyncDate.rawValue
        ) as? Date
        CloudKitAccountStatusChecker().check { status in
            iCloudAccountStatus = status
        }
    }

    private var accountStatusLabel: String {
        switch iCloudAccountStatus {
        case .available: return NSLocalizedString("Signed in", comment: "")
        case .noAccount: return NSLocalizedString("Not signed in", comment: "")
        case .restricted: return NSLocalizedString("Restricted", comment: "")
        case .unknown: return NSLocalizedString("Checking…", comment: "")
        }
    }

    private var iCloudUnavailableHelperText: String? {
        switch iCloudAccountStatus {
        case .noAccount:
            return NSLocalizedString(
                "Sign in to iCloud in the Settings app to enable sync.",
                comment: ""
            )
        case .restricted:
            return NSLocalizedString(
                "iCloud is restricted on this device. Check your device's restrictions to enable sync.",
                comment: ""
            )
        case .available, .unknown:
            return nil
        }
    }

    private func applyDeliveryMethod(_ method: DeliveryMethod) {
        container.sdk?.settings.setDeliveryMethod(to: method)
        if let settings = container.sdk?.settings {
            deliveryMethod = SettingsOptions.getDeliveryMethodString(for: settings.deliveryMethod.value)
            quantity = String(settings.quantity.rawValue)
            expirationInterval = SettingsOptions.getExpirationInterval(for: settings.expirationInterval)
        }
        container.refreshBadges()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func applyQuantity(_ value: Int) {
        container.sdk?.settings.setQuantity(to: value)
        container.refreshBadges()
        WidgetCenter.shared.reloadAllTimelines()
    }

}
