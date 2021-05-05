//
//  SettingsSaver.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.

import Foundation
import PDKit

class SettingsSaver: CodeBehindDependencies<SettingsSaver> {

    private let controls: SettingsControls

    init(controls: SettingsControls) {
        self.controls = controls
        super.init()
    }

    init(_ controls: SettingsControls, _ dependencies: DependenciesProtocol) {
        self.controls = controls
        super.init(
            sdk: dependencies.sdk,
            tabs: dependencies.tabs,
            notifications: dependencies.notifications,
            alerts: dependencies.alerts,
            nav: dependencies.nav,
            badge: dependencies.badge,
            widget: dependencies.widget
        )
    }

    public func save(_ key: PDSetting, selectedRow: Index) {
        notifications?.cancelAllExpiredHormoneNotifications()
        switch key {
            case .DeliveryMethod: saveDeliveryMethodChange(selectedRow)
            case .Quantity: saveQuantity(selectedRow)
            case .ExpirationInterval: saveExpirationInterval(selectedRow)
            case .XDays: saveXDays(selectedRow)
            default: log.error("Error: No picker for key \(key)")
        }
        notifications?.requestAllExpiredHormoneNotifications()
    }

    private func saveDeliveryMethodChange(_ selectedRow: Index) {
        guard let sdk = sdk else { return }
        let newMethod = SettingsOptions.getDeliveryMethod(at: selectedRow)
        let currentMethod = sdk.settings.deliveryMethod.value
        guard newMethod != currentMethod else { return }
        if sdk.isFresh {
            sdk.settings.setDeliveryMethod(to: newMethod)
        } else {
            presentDeliveryMethodMutationAlert(choice: newMethod, controls: controls)
        }

        controls.reflect(method: newMethod)
        let defaultQuantity = DefaultQuantities.Hormone[newMethod]
        controls.quantityButton.setTitle("\(defaultQuantity)")
    }

    private func presentDeliveryMethodMutationAlert(
        choice: DeliveryMethod, controls: SettingsControls
    ) {
        // Put view logic here that reflects the state of the delivery method in the Settings view.
        let decline = { (_ originalMethod: DeliveryMethod, _ originalQuantity: Int) -> Void in
            let originalTitle = SettingsOptions.getDeliveryMethodString(for: originalMethod)
            controls.deliveryMethodButton.setTitleForNormalAndDisabled(originalTitle)
            controls.quantityButton.setTitleForNormalAndDisabled("\(originalQuantity)")
            switch originalMethod {
                case .Patches:
                    controls.quantityButton.isEnabled = true
                    controls.quantityArrowButton.isEnabled = true
                case .Gel, .Injections:
                    controls.quantityButton.isEnabled = false
                    controls.quantityArrowButton.isEnabled = false
            }
        }
        let handlers = DeliveryMethodMutationAlertActionHandler(decline: decline)
        guard let alerts = alerts else { return }
        let alert = alerts.createDeliveryMethodMutationAlert(
            newDeliveryMethod: choice, handlers: handlers
        )
        alert.present()
    }

    private func saveQuantity(_ selectedRow: Index) {
        let decline: (Int) -> Void = {
            oldQuantity in self.controls.quantityButton.setTitle("\(oldQuantity)")
        }
        let newQuantity = SettingsOptions.getQuantity(at: selectedRow).rawValue
        setQuantity(to: newQuantity, decline: decline)
    }

    private func setQuantity(to newQuantity: Int, decline: @escaping (Int) -> Void) {
        guard let sdk = sdk else { return }
        let oldQuantity = sdk.settings.quantity.rawValue
        if newQuantity >= oldQuantity {
            sdk.settings.setQuantity(to: newQuantity)
            return
        }
        let continueAction: (_ newQuantity: Int) -> Void = {
            (newQuantity) in
            sdk.hormones.delete(after: newQuantity)
            sdk.settings.setQuantity(to: newQuantity)
            self.tabs?.reflectHormones()
            self.notifications?.cancelRangeOfExpiredHormoneNotifications(
                from: newQuantity - 1, to: oldQuantity - 1
            )
        }
        let handler = QuantityMutationAlertActionHandler(
            cont: continueAction,
            decline: decline,
            setQuantity: sdk.settings.setQuantity
        )
        presentQuantityMutationAlert(
            oldQuantity: oldQuantity,
            newQuantity: newQuantity,
            handlers: handler
        )
    }

    private func presentQuantityMutationAlert(
        oldQuantity: Int,
        newQuantity: Int,
        handlers: QuantityMutationAlertActionHandling
    ) {
        if newQuantity > oldQuantity {
            handlers.setQuantityWithoutAlert(newQuantity: newQuantity)
            return
        }
        guard let alerts = alerts else { return }
        let alert = alerts.createQuantityMutationAlert(
            handlers: handlers, oldQuantity: oldQuantity, newQuantity: newQuantity
        )
        alert.present()
    }

    private func saveExpirationInterval(_ selectedRow: Index) {
        guard let newInterval = SettingsOptions.expirationIntervals.tryGet(at: selectedRow) else {
            return
        }
        sdk?.settings.setExpirationInterval(to: newInterval)
    }

    private func saveXDays(_ selectedRow: Index) {
        guard let newDays = SettingsOptions.xDaysValues.tryGet(at: selectedRow) else { return }
        sdk?.settings.setXDays(to: newDays)
    }
}
