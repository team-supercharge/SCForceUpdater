//
//  AppDelegate.swift
//  SCForceUpdate
//
//  Created by Bruno Muniz on 08/07/2018.
//  Copyright (c) 2018 Bruno Muniz. All rights reserved.
//

import UIKit
import SCForceUpdate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        SCForceUpdater.sharedUpdater.set(itunesAppId: "iTunesAppId",
                                         baseURL: "http://localhost:4567",
                                         versionAPIEndpoint: "versions/ios")
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SCForceUpdater.sharedUpdater.checkForUpdate()
    }
}
