//
//  AlertControllerExtension.swift
//  Pods-Example
//
//  Created by Bruno Muniz on 8/8/18.
//

import UIKit
import ObjectiveC

private var alertWindowAssociationKey: UInt8 = 0

extension UIAlertController {

    var alertWindow: UIWindow? {
        get {
            return objc_getAssociatedObject(self, &alertWindowAssociationKey) as? UIWindow
        }
        set(newValue) {
            objc_setAssociatedObject(self, &alertWindowAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func show() {
        self.alertWindow = UIWindow(frame: UIScreen.main.bounds)
        self.alertWindow?.rootViewController = UIViewController()
        self.alertWindow?.windowLevel = UIWindowLevelAlert + 1
        self.alertWindow?.makeKeyAndVisible()
        self.alertWindow?.rootViewController?.present(self, animated: true, completion: nil)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.alertWindow?.isHidden = true
        self.alertWindow = nil
    }
}
