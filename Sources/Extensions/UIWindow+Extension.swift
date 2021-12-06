//
//  UIWindow+Extension.swift
//  UI Present Coordinator
//
//  Created by srea on 2021/12/02.
//

import UIKit

internal extension UIWindow {
    static var key: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState != .unattached }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .first(where: \.isKeyWindow)
    }
    
    func topViewController() -> UIViewController? {
        var top = rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}
