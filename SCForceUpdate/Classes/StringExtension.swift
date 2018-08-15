//
//  StringExtension.swift
//  Pods-SCForceUpdater
//
//  Created by Bruno Muniz on 8/2/18.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "SCForceUpdaterLocalizable",
                                 bundle: SCForceUpdater.sharedUpdater.bundle,
                                 comment: self)
    }

    public func compareTo(version: String) -> ComparisonResult {
        var result: ComparisonResult = .orderedSame

        if self != version {
            let thisVersion = components(separatedBy: ".")
            let compareVersion = version.components(separatedBy: ".")

            for index in 0..<thisVersion.count {
                guard let thisSegment = Int(thisVersion[index]),
                    let compareSegment = index < compareVersion.count ? Int(compareVersion[index]) : 0 else {
                    break
                }

                if thisSegment < compareSegment {
                    result = ComparisonResult.orderedAscending
                    break
                }

                if thisSegment > compareSegment {
                    result = ComparisonResult.orderedDescending
                    break
                }
            }

            if result == ComparisonResult.orderedSame && compareVersion.count > thisVersion.count {
                result = ComparisonResult.orderedAscending
            }
        }

        return result
    }

    public func isOlderThan(version: String) -> Bool {
        return compareTo(version: version) == ComparisonResult.orderedAscending
    }

    public func isNewerThan(version: String) -> Bool {
        return compareTo(version: version) == ComparisonResult.orderedDescending
    }

    public func isEqualTo(version: String) -> Bool {
        return compareTo(version: version) == ComparisonResult.orderedSame
    }

    public func isEqualOrOlderThan(version: String) -> Bool {
        return compareTo(version: version) != ComparisonResult.orderedDescending
    }

    public func isEqualOrNewerThan(version: String) -> Bool {
        return compareTo(version: version) != ComparisonResult.orderedAscending
    }
}
