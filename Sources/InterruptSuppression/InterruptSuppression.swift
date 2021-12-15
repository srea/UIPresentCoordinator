//
//  InterruptSuppression.swift
//  UI Queue
//
//  Created by srea on 2021/12/12.
//

import Foundation
import UIKit

public protocol InterruptSuppression {
    var classTypes: [AnyClass] { get }
    var classNames: [String] { get }
}

extension InterruptSuppression {

    func addClassIfAvailable(list: inout [AnyClass], className: String) {
        guard let classType = NSClassFromString(className) else {
            return
        }
        list.append(classType)
    }
}

public struct SystemAlertInterruptSuppression: InterruptSuppression {

    private(set) public var classTypes: [AnyClass] = []
    private(set) public var classNames: [String] = []

    public init() {
        addClassIfAvailable(list: &classTypes, className: "UIAlertController")
        addClassIfAvailable(list: &classTypes, className: "SwiftUI.PlatformAlertController")
        classNames.append("PresentationHostingController")
        // addClassIfAvailable(list: &classNames, className: "SKStoreReviewViewController")
        // addClassIfAvailable(list: &classNames, className: "SKStoreReviewPresentationWindow")
    }
}

public struct UserDefineInterruptSuppression: InterruptSuppression {
    public var classTypes: [AnyClass] = []
    public var classNames: [String] = []

    public init(objects: [AnyClass] = [], names: [String] = []) {
        classTypes.append(contentsOf: objects)
        classNames.append(contentsOf: names)
    }
}

class PresentationHostingController: UIViewController {

}
