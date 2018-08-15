//
//  Constants.swift
//  forceupdate-ios
//
//  Created by Bruno Muniz on 8/3/18.
//  Copyright © 2018 Bruno Muniz. All rights reserved.
//

enum Constants {
    enum Hard {
        static let title = "sc.force-updater.hard.title"
        static let message = "sc.force-updater.hard.message"
        static let update = "sc.force-updater.hard.update"
    }

    enum Soft {
        static let title = "sc.force-updater.soft.title"
        static let message = "sc.force-updater.soft.message"
        static let update = "sc.force-updater.soft.update"
        static let later = "sc.force-updater.soft.later"
        static let noThanks = "sc.force-updater.soft.no-thanks"
    }

    enum Errors {
        static let jsonParsing = "[SCForceUpdater] Error: issue(s) parsing JSON"
        static let dataLack = "[SCForceUpdater] Error: Did not receive data"
        static let displayName = "[SCForceUpdater] Error: CFBundleDisplayName is nil"
        static let buildNumber = "[SCForceUpdater] Error: build number is nil"
        static let versionNumber = "[SCForceUpdater] Error: version number is nil"
    }

    enum AlertType {
        static let soft = "soft"
        static let hard = "hard"
    }

    enum Others {
        static let displayName = "CFBundleDisplayName"
        static let buildNumber = "CFBundleVersion"
        static let versionNumber = "CFBundleShortVersionString"
        static let lastVersionResponseKey = "last_version"
        static let updateTypeResponseKey = "update_type"
    }
}
