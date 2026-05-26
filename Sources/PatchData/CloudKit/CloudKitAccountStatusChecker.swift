//
//  CloudKitAccountStatusChecker.swift
//  PatchData
//
//  Read-only iCloud account state for the Settings UI.
//

import Foundation
import CloudKit

public final class CloudKitAccountStatusChecker {

    public enum Status {
        case available
        case noAccount
        case restricted
        case unknown
    }

    private let containerIdentifier: String

    public init(containerIdentifier: String = "iCloud.Yingthi.PatchDay") {
        self.containerIdentifier = containerIdentifier
    }

    public func check(_ completion: @escaping (Status) -> Void) {
        CKContainer(identifier: containerIdentifier).accountStatus { status, _ in
            DispatchQueue.main.async {
                switch status {
                case .available: completion(.available)
                case .noAccount: completion(.noAccount)
                case .restricted: completion(.restricted)
                case .couldNotDetermine, .temporarilyUnavailable: completion(.unknown)
                @unknown default: completion(.unknown)
                }
            }
        }
    }
}
