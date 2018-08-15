//
//  BundleExtension.swift
//  Pods-SCForceUpdater
//
//  Created by Bruno Muniz on 8/2/18.
//

extension Bundle {
    public func versionNumber() -> String {
        guard let version = object(forInfoDictionaryKey: Constants.Others.versionNumber) as? String else {
            fatalError(Constants.Errors.versionNumber)
        }

        return version
    }

    public func buildNumber() -> String {
        guard let build = object(forInfoDictionaryKey: Constants.Others.buildNumber) as? String else {
            fatalError(Constants.Errors.buildNumber)
        }

        return build
    }
}
