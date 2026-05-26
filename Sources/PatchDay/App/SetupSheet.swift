//
//  SetupSheet.swift
//  PatchDay
//
//  One-time post-install / post-update sheet that surfaces iCloud sync
//  and notifications. The user can enable either, both, or skip. Once
//  dismissed (either via Done or Skip), `didShowICloudSetup` is set so
//  the sheet never reappears.
//

import SwiftUI
import UserNotifications
import PDKit
import PatchData

struct SetupSheet: View {

    @EnvironmentObject private var container: AppContainer
    @Environment(\.dismiss) private var dismiss

    @State private var enableICloud: Bool = false
    @State private var enableNotifications: Bool = false
    @State private var iCloudStatus: CloudKitAccountStatusChecker.Status = .unknown

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(NSLocalizedString("Welcome to PatchDay", comment: ""))
                        .font(.title2)
                    Text(NSLocalizedString(
                        "PatchDay can sync your schedule across your devices with iCloud and remind you when something is due. You can change these any time in Settings.",
                        comment: "Setup sheet intro"
                    ))
                    .font(.body)
                    .foregroundColor(.secondary)
                }

                Section {
                    Toggle(
                        NSLocalizedString("Sync with iCloud", comment: ""),
                        isOn: $enableICloud
                    )
                        .accessibilityIdentifier("setupSheetICloudSwitch")
                        .disabled(iCloudStatus != .available)
                    if iCloudStatus == .noAccount {
                        Text(NSLocalizedString(
                            "Sign in to iCloud in the Settings app to enable sync.",
                            comment: ""
                        ))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } else if iCloudStatus == .restricted {
                        Text(NSLocalizedString(
                            "iCloud is restricted on this device.",
                            comment: ""
                        ))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                } footer: {
                    Text(NSLocalizedString(
                        "Your data stays in your iCloud account. PatchDay never sees it.",
                        comment: ""
                    ))
                }

                Section {
                    Toggle(
                        NSLocalizedString("Enable notifications", comment: ""),
                        isOn: $enableNotifications
                    )
                        .accessibilityIdentifier("setupSheetNotificationsSwitch")
                } footer: {
                    Text(NSLocalizedString(
                        "Get notified when a hormone is about to expire or a pill is due.",
                        comment: ""
                    ))
                }
            }
            .navigationTitle(NSLocalizedString("Set up PatchDay", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("Done", comment: "")) { commit() }
                        .accessibilityIdentifier("setupSheetDoneButton")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Skip", comment: "")) { skip() }
                        .accessibilityIdentifier("setupSheetSkipButton")
                }
            }
            .onAppear(perform: prime)
        }
    }

    private func prime() {
        enableICloud = UserDefaults.standard.bool(
            forKey: PDLocalSettingsKey.iCloudSyncEnabled.rawValue
        )
        enableNotifications = container.sdk?.settings.notifications.value ?? false
        CloudKitAccountStatusChecker().check { status in
            iCloudStatus = status
        }
    }

    private func commit() {
        UserDefaults.standard.set(
            enableICloud, forKey: PDLocalSettingsKey.iCloudSyncEnabled.rawValue
        )
        if enableNotifications {
            container.sdk?.settings.setNotifications(to: true)
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            ) { granted, _ in
                if granted {
                    DispatchQueue.main.async {
                        container.notifications?.requestAllExpiredHormoneNotifications()
                    }
                }
            }
        } else {
            container.sdk?.settings.setNotifications(to: false)
        }
        markShown()
        dismiss()
    }

    private func skip() {
        markShown()
        dismiss()
    }

    private func markShown() {
        UserDefaults.standard.set(
            true, forKey: PDLocalSettingsKey.didShowICloudSetup.rawValue
        )
    }
}
