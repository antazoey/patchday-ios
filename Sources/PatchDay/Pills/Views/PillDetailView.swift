//
//  PillDetailView.swift
//  PatchDay
//
//  Full SwiftUI replacement for PillDetailViewController. Supports name,
//  notify, 1–4 times-of-day pickers, and the expiration-interval picker
//  with conditional X-Days controls.
//

import SwiftUI
import PDKit

struct PillDetailView: View {

    @EnvironmentObject private var container: AppContainer
    let pillIndex: Index

    @State private var name: String = ""
    @State private var notify: Bool = true
    @State private var times: [Date] = [Date()]
    @State private var interval: PillExpirationIntervalSetting = .EveryDay
    @State private var daysOne: Int = DefaultPillAttributes.XDAYS_INT
    @State private var daysTwo: Int = DefaultPillAttributes.XDAYS_INT
    @State private var didPrime = false
    @State private var isDirty = false
    @State private var showUnsavedAlert = false
    @State private var startedAsNewPill = false

    private var pill: Swallowable? {
        container.sdk?.pills[pillIndex]
    }

    private var title: String {
        guard let pill = pill else { return PDTitleStrings.PillTitle }
        return pill.isNew ? PDTitleStrings.NewPillTitle : PDTitleStrings.EditPillTitle
    }

    var body: some View {
        Form {
            Section(NSLocalizedString("Name", comment: "")) {
                TextField(NSLocalizedString("Pill name", comment: ""), text: $name)
                    .autocapitalization(.words)
                    .accessibilityIdentifier("pillNameTextField")
                    .onChange(of: name) { _ in if didPrime { isDirty = true } }
                Picker(NSLocalizedString("Preset", comment: ""), selection: $name) {
                    ForEach(PillStrings.DefaultPills + PillStrings.ExtraPills, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("pillNamePresetPicker")
            }

            Section(NSLocalizedString("Schedule", comment: "")) {
                Picker(NSLocalizedString("Interval", comment: ""), selection: $interval) {
                    ForEach(PillExpirationInterval.options, id: \.self) { option in
                        Text(PillStrings.Intervals.getStringFromInterval(option)).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("pillScheduleButton")
                .onChange(of: interval) { _ in if didPrime { isDirty = true } }

                if interval == .FirstXDays || interval == .LastXDays {
                    Stepper(
                        value: $daysOne,
                        in: PillExpirationIntervalXDays.daysRange
                    ) {
                        Text(daysOneLabel + ": \(daysOne)")
                    }
                    .accessibilityIdentifier("pillDaysOneScheduleButton")
                } else if interval == .XDaysOnXDaysOff {
                    Stepper(
                        value: $daysOne,
                        in: PillExpirationIntervalXDays.daysRange
                    ) {
                        Text("\(NSLocalizedString("Days on", comment: "")): \(daysOne)")
                    }
                    .accessibilityIdentifier("pillDaysOneScheduleButton")
                    Stepper(
                        value: $daysTwo,
                        in: PillExpirationIntervalXDays.daysRange
                    ) {
                        Text("\(NSLocalizedString("Days off", comment: "")): \(daysTwo)")
                    }
                    .accessibilityIdentifier("pillDaysTwoScheduleButton")
                }
            }

            Section(NSLocalizedString("Times", comment: "")) {
                Stepper(
                    value: timesCountBinding,
                    in: 1...MAX_PILL_TIMES_PER_DAY
                ) {
                    Text("\(NSLocalizedString("Times per day", comment: "")): \(times.count)")
                }
                .accessibilityIdentifier("pillTimesCountStepper")
                ForEach(times.indices, id: \.self) { index in
                    DatePicker(
                        "\(NSLocalizedString("Time", comment: "")) \(index + 1)",
                        selection: Binding(
                            get: { times[index] },
                            set: { times[index] = $0 }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .accessibilityIdentifier("pillTimePicker_\(index)")
                }
            }

            Section {
                Toggle(NSLocalizedString("Notify when due", comment: ""), isOn: $notify)
                    .accessibilityIdentifier("pillNotifySwitch")
                    .onChange(of: notify) { _ in if didPrime { isDirty = true } }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(ActionStrings.Back) { handleBack() }
                    .accessibilityIdentifier("pillBackButton")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(ActionStrings.Save) { save() }
                    .accessibilityIdentifier("pillSaveButton")
            }
        }
        .confirmationDialog(
            NSLocalizedString("Unsaved changes", comment: "Alert title"),
            isPresented: $showUnsavedAlert,
            titleVisibility: .visible
        ) {
            Button(ActionStrings.Save) { save() }
            Button(
                NSLocalizedString("Discard", comment: "Discard unsaved changes"),
                role: .destructive
            ) { discardAndPop() }
            Button(ActionStrings.Cancel, role: .cancel) {}
        }
        .onAppear(perform: prime)
    }

    // MARK: - Helpers

    private var daysOneLabel: String {
        switch interval {
        case .FirstXDays:
            return NSLocalizedString("First X days", comment: "")
        case .LastXDays:
            return NSLocalizedString("Last X days", comment: "")
        default:
            return NSLocalizedString("Days", comment: "")
        }
    }

    private var timesCountBinding: Binding<Int> {
        Binding(
            get: { times.count },
            set: { newCount in
                let clamped = max(1, min(MAX_PILL_TIMES_PER_DAY, newCount))
                if clamped > times.count {
                    let last = times.last ?? Date()
                    times.append(contentsOf: Array(repeating: last, count: clamped - times.count))
                } else if clamped < times.count {
                    times = Array(times.prefix(clamped))
                }
            }
        )
    }

    private func prime() {
        guard !didPrime, let pill = pill else { return }
        startedAsNewPill = pill.isNew
        name = pill.name
        notify = pill.notify
        interval = pill.expirationIntervalSetting
        daysOne = pill.expirationInterval.daysOne ?? DefaultPillAttributes.XDAYS_INT
        daysTwo = pill.expirationInterval.daysTwo ?? DefaultPillAttributes.XDAYS_INT
        let parsed = pill.times
        if !parsed.isEmpty {
            times = parsed
        } else {
            times = DateFactory.createTimesFromCommaSeparatedString(
                DefaultPillAttributes.TIME, now: nil
            )
        }
        didPrime = true
    }

    private func handleBack() {
        if isDirty || startedAsNewPill {
            showUnsavedAlert = true
        } else {
            container.popPills()
        }
    }

    private func discardAndPop() {
        if startedAsNewPill {
            container.sdk?.pills.delete(at: pillIndex)
            container.triggerRefresh()
        }
        container.popPills()
    }

    private func save() {
        guard let pills = container.sdk?.pills, let pill = pill else {
            container.popPills()
            return
        }
        let attrs = pill.attributes
        attrs.name = name
        attrs.notify = notify
        attrs.isCreated = true
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString(times)
        attrs.expirationInterval.value = interval
        if interval == .FirstXDays || interval == .LastXDays {
            attrs.expirationInterval.daysOne = daysOne
        } else if interval == .XDaysOnXDaysOff {
            attrs.expirationInterval.daysOne = daysOne
            attrs.expirationInterval.daysTwo = daysTwo
        }
        pills.set(by: pill.id, with: attrs)
        if let updated = container.sdk?.pills[pillIndex] {
            container.notifications?.requestDuePillNotification(updated)
        }
        container.badge?.reflect()
        container.widget?.set()
        container.triggerRefresh()
        container.popPills()
    }
}
