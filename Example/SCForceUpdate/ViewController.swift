//
//  ViewController.swift
//  SCForceUpdate
//
//  Created by Bruno Muniz on 08/07/2018.
//  Copyright (c) 2018 Bruno Muniz. All rights reserved.
//

import UIKit
import SCForceUpdate

final class ViewController: UIViewController {
    // MARK: - Actions
    @IBAction private func checkForUpdates() {
        SCForceUpdater.sharedUpdater.checkForUpdate()
    }
}
