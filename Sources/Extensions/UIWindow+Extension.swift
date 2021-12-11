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

extension UIWindow {

    private static var _present_coordinator_at_once = true

    internal static var _present_coordinator_isHidden_Internal: Set<Int> = .init()

    internal static func present_coordinator_swizzle() {
        guard Self._present_coordinator_at_once else {
            return
        }
        Self._present_coordinator_at_once = false
        let swizzleMethod = { (original: Selector, swizzled: Selector) in
            guard let originalMethod = class_getInstanceMethod(UIWindow.self, original),
                  let swizzledMethod = class_getInstanceMethod(UIWindow.self, swizzled) else {
                return
            }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        swizzleMethod(#selector(setter: UIWindow.isHidden),
                      #selector(setter: UIWindow._present_coordinator_isHidden))
    }

    @objc open var _present_coordinator_isHidden: Bool {
        get {
            self._present_coordinator_isHidden
        }
        set {
            guard !newValue else {
                self._present_coordinator_isHidden = newValue
                UIWindow._present_coordinator_isHidden_Internal.remove(hash)
                return
            }

            if UIWindow._present_coordinator_isHidden_Internal.contains(hash) {
                self._present_coordinator_isHidden = false
            } else {
                UIPresentCoordinator.shared.enqueue(.init(window: self))
                UIWindow._present_coordinator_isHidden_Internal.insert(hash)
            }
        }
    }
}
