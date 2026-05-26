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

    var body: some View {
        Form {
            Section(NSLocalizedString("Schedule", comment: "")) {
                Picker(NSLocalizedString("Delivery method", comment: ""),
                       selection: $deliveryMethod) {
                    ForEach(SettingsOptions.deliveryMethods, id: \.self) { Text($0).tag($0) }
                }
                .accessibilityIdentifier("deliveryMethodButton")
                .onChange(of: deliveryMethod) { newValue in
                    let next = SettingsOptions.getDeliveryMethod(for: newValue)
                    let current = container.sdk?.settings.deliveryMethod.value
                    guard next != current else { return }
                    pendingDeliveryMethod = next
                }

                Picker(NSLocalizedString("Expiration interval", comment: ""),
                       selection: $expirationInterval) {
                    ForEach(SettingsOptions.expirationIntervals, id: \.self) { Text($0).tag($0) }
                }
                .accessibilityIdentifier("expirationIntervalButton")
                .onChange(of: expirationInterval) { newValue in
                    guard let settings = container.sdk?.settings else { return }
                    let current = SettingsOptions.getExpirationInterval(for: settings.expirationInterval)
                    guard newValue != current else { return }
                    settings.setExpirationInterval(to: newValue)
                }

                Picker(NSLocalizedString("Quantity", comment: ""),
                       selection: $quantity) {
                    ForEach(SettingsOptions.quantities, id: \.self) { Text($0).tag($0) }
                }
                .accessibilityIdentifier("settingsQuantityButton")
                .onChange(of: quantity) { newValue in
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
            .accessibilityIdentifier("settingsScheduleSection")

            Section(NSLocalizedString("Notifications", comment: "")) {
                Toggle(NSLocalizedString("Notifications enabled", comment: ""),
                       isOn: $notificationsEnabled)
                    .accessibilityIdentifier("notificationsSwitch")
                    .onChange(of: notificationsEnabled) { value in
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
                    VStack(alignment: .leading) {
                        Text("\(NSLocalizedString("Notify minutes before:", comment: "")) \(Int(notificationsMinutesBefore))")
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
            .accessibilityIdentifier("settingsNotificationsSection")

            Section {
                Toggle(NSLocalizedString("Use static expiration time", comment: ""),
                       isOn: $useStaticExpirationTime)
                    .accessibilityIdentifier("useStaticExpirationTimeSwitch")
                    .onChange(of: useStaticExpirationTime) { value in
                        container.sdk?.settings.setUseStaticExpirationTime(to: value)
                    }
            } footer: {
                Text(NSLocalizedString(
                    "When on, suggested expiration times always match the original application time.",
                    comment: "Setting footer"
                ))
            }
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
        .onAppear(perform: prime)
    }

    // MARK: - Helpers

    private var deliveryAlertBinding: Binding<Bool> {
        Binding(get: { pendingDeliveryMethod != nil },
                set: { if !$0 { pendingDeliveryMethod = nil } })
    }

    private var quantityAlertBinding: Binding<Bool> {
        Binding(get: { pendingQuantity != nil },
                set: { if !$0 { pendingQuantity = nil } })
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
    }

    private func applyDeliveryMethod(_ method: DeliveryMethod) {
        container.sdk?.settings.setDeliveryMethod(to: method)
        if let settings = container.sdk?.settings {
            quantity = String(settings.quantity.rawValue)
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
