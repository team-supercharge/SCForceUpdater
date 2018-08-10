//
//  SCForceUpdater.swift
//  forceupdate-ios
//
//  Created by Bruno Muniz on 8/2/18.
//  Copyright © 2018 Bruno Muniz. All rights reserved.
//

import Foundation
import UIKit

final public class SCForceUpdater {
    // MARK: - Properties
    private var itunesAppId: String = ""
    private var networkManager: SCNetworkManager?
    private var alertController: UIAlertController?
    private var alwaysUseMainBundle: Bool = false
    static var displayName: String {
        guard let name = Bundle.main.object(forInfoDictionaryKey: Constants.Others.displayName) as? String else {
            fatalError(Constants.Errors.displayName)
        }

        return name
    }

    // MARK: - Singleton
    public static let sharedUpdater = SCForceUpdater()
}

// MARK: - Public
extension SCForceUpdater {
    public func set(itunesAppId: String, baseURL: String, versionAPIEndpoint: String) {
        self.itunesAppId = itunesAppId
        self.networkManager = SCNetworkManager(baseURL, versionAPIEndpoint: versionAPIEndpoint)
    }

    public func checkForUpdate(with completion: (([AnyHashable: Any]?) -> Void)? = nil) {
        networkManager?.fetchCurrentVersion(completion: { [weak self] jsonObject in
            self?.handleResponse(jsonObject)
            completion?(jsonObject)
        })
    }

    public var bundle: Bundle {
        return alwaysUseMainBundle ? Bundle.main : Bundle(for: type(of: self))
    }
}

// MARK: - Private
extension SCForceUpdater {
    private func handleResponse(_ jsonObject: [AnyHashable: Any]?) {
        guard let jsonObject = jsonObject,
            let version = jsonObject[Constants.Others.lastVersionResponseKey] as? String,
            let type = jsonObject[Constants.Others.updateTypeResponseKey] as? String else {
                return
        }

        if version.isEqualOrOlderThan(version: Bundle.main.versionNumber()) {
            return
        }

        if type == Constants.AlertType.soft {
            let dontDisplayAgain = UserDefaults.standard.object(forKey: version)

            if  dontDisplayAgain != nil {
                return
            }
        }

        displayUpdateAlertFor(version: version, hard: type == Constants.AlertType.hard)
    }

    private func displayUpdateAlertFor(version: String, hard: Bool) {
        if alertController != nil {
            return
        }

        var title: String
        var message: String
        var cancelButtonTitle: String

        if hard {
            title = Constants.Hard.title.localized
            message = Constants.Hard.message.localized
            cancelButtonTitle = Constants.Hard.update.localized
        } else {
            title = Constants.Soft.title.localized
            message = Constants.Soft.message.localized
            cancelButtonTitle = Constants.Soft.update.localized
        }

        let noThanksButtonTitle = Constants.Soft.noThanks.localized
        let laterButtonTitle = Constants.Soft.later.localized
        let entireMessage = String(format: message, SCForceUpdater.displayName, version)

        DispatchQueue.main.async { [weak self] in
            self?.alertController = UIAlertController(title: title, message: entireMessage, preferredStyle: .alert)
            self?.alertController?.addAction(UIAlertAction(title: cancelButtonTitle,
                                                           style: .cancel,
                                                           handler: { action in

                                                            guard let appUrl = self?.iTunesAppURL() else { return }

                                                            if #available(iOS 10.0, *) {
                                                                UIApplication.shared.open(appUrl,
                                                                                          options: [:],
                                                                                          completionHandler: nil)
                                                            } else {
                                                                UIApplication.shared.openURL(appUrl)
                                                            }

                                                            self?.alertController = nil
            }))

            if !hard {
                self?.alertController?.addAction(UIAlertAction(title: noThanksButtonTitle,
                                                               style: .default,
                                                               handler: { action in
                                                                guard let defaultKeys = self?.defaultKeysFor(version: version) else { return }

                                                                let defaults = UserDefaults.standard
                                                                defaults.set("true", forKey: defaultKeys)
                                                                defaults.synchronize()

                                                                self?.alertController = nil
                                                                return
                }))

                self?.alertController?.addAction(UIAlertAction(title: laterButtonTitle,
                                                               style: .default,
                                                               handler: { action in
                                                                self?.alertController = nil
                                                                return
                }))
            }
        }

        DispatchQueue.main.async {
            self.alertController?.show()
        }
    }

    private func iTunesAppURL() -> URL? {
        return URL(string: String(format: "itms-apps://itunes.apple.com/app/id%@?mt=8", itunesAppId))
    }

    private func defaultKeysFor(version: String) -> String? {
        return "dismiss-update-\(version)"
    }
}
