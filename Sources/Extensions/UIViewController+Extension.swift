//
//  UIViewController+Extension.swift
//  UI Present Coordinator
//
//  Created by srea on 2021/12/02.
//

import UIKit

extension UIViewController {

    private static let coordinator = UIPresentCoordinator.shared
    private static var _present_coordinator_at_once = true

    internal static func present_coordinator_swizzle() {
        guard Self._present_coordinator_at_once else {
            return
        }
        Self._present_coordinator_at_once = false
        let swizzleMethod = { (original: Selector, swizzled: Selector) in
            guard let originalMethod = class_getInstanceMethod(UIViewController.self, original),
                  let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzled) else {
                      return
                  }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        swizzleMethod(#selector(UIViewController.viewDidDisappear(_:)),
                      #selector(UIViewController._present_coordinator_viewDidDisappear(_:)))
        swizzleMethod(#selector(UIViewController.present(_:animated:completion:)),
                      #selector(UIViewController._present_coordinator_present(_:animated:completion:force:)))
    }

    public func presentQueue(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        Self.coordinator.enqueue(.view(.init(controller: viewController,
                                             animated: animated,
                                             completion: completion)))
    }

    internal func presentForce(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        self._present_coordinator_present(viewController, animated: animated, completion: completion, force: true)
    }

    @objc private func _present_coordinator_present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil, force: Bool = false) {
        if !force && Self.coordinator.shouldEnqueue(object: viewController) {
            Self.coordinator.enqueue(.view(.init(controller: viewController,
                                                 animated: animated,
                                                 completion: completion)))
        } else {
            self._present_coordinator_present(viewController, animated: animated, completion: completion)
        }
    }

    @objc private func _present_coordinator_viewDidDisappear(_ animated: Bool) {
        self._present_coordinator_viewDidDisappear(animated)
        guard isBeingDismissed else {
            return
        }
        Self.coordinator.dismissed()
    }
}
