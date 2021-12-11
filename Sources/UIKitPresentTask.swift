//
//  PresentingInfo.swift
//  UI Present Coordinator
//
//  Created by srea on 2021/12/02.
//

import UIKit

public enum UIKitPresentTask {
    case view(UIKitViewTask)
    case window(UIKitWIndowTask)

    func show() {
        switch self {
        case .view(let task):
            task.show()
        case .window(let task):
            task.show()
        }
    }
}

public protocol UIKitTask {
    func show()
}

public struct UIKitViewTask: UIKitTask {
    public let controller: UIViewController
    public let animated: Bool
    public let completion: (() -> Void)?

    public func show() {
        guard let topViewController = UIWindow.key?.topViewController() else {
            return
        }
        topViewController.present(controller, animated: animated, completion: completion)
    }

}

public struct UIKitWIndowTask: UIKitTask {
    public let window: UIWindow

    public func show() {
        window.isHidden = false
    }
}
