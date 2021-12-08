//
//  UIPresentCoordinator.swift
//  UI Present Coordinator
//
//  Created by srea on 2021/12/01.
//

import UIKit
import Combine
import SwiftUI

public protocol UIPresentCoordinatable {
    
    // SwiftUI
    func enqueue(_ task: SwiftUIPresentTask)
    func dequeue() -> Alert
    func dequeue() -> AnyView

    // UIKit
    func enqueue(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    
    func suspend()
    func resume()

    func flush()
}

public final class UIPresentCoordinator: ObservableObject, UIPresentCoordinatable {
    
    public static let shared = UIPresentCoordinator.init()

    public var suspendInterruptDefaultAlert: Bool = true
    
    public var waitingItems: Int {
        queue.count()
    }

    private var isSuspended: Bool = false
    private var isPresenting: Bool = false
    private var queue = Queue<PresentingType>()
    
    private weak var storeKitWindow: AnyObject?

    public init() {
        UIViewController.present_coordinator_swizzle()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowDidBecomeVisible(notification:)),
                                               name: UIWindow.didBecomeVisibleNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowDidBecomeHidden(notification:)),
                                               name: UIWindow.didBecomeHiddenNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func windowDidBecomeVisible(notification: Notification) {
        guard let window = notification.object else {
            return
        }
        let className = String(describing: type(of: window))
        
        if className.contains("SKStoreReviewPresentationWindow") {
            storeKitWindow = notification.object as AnyObject
        }
    }
    
    @objc func windowDidBecomeHidden(notification: Notification) {
        guard let window = notification.object else {
            return
        }
        _ = String(describing: type(of: window))
    }

    public func flush() {
        queue.clearAll()
    }

    public func dismissed(_ viewController: UIViewController) {
        guard isPresenting else {
            handleNextQueue()
            return
        }

        isPresenting = false

        // for SwiftUI State Hidden
        if case .swiftUI(let task) = queue.dequeue() {
            task.hide()
        }

        handleNextQueue()
    }
    
    private func handleNextQueue() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            guard self.storeKitWindow == nil else {
                return
            }
            guard !self.isSuspended else {
                return
            }
            guard !self.isPresenting else {
                return
            }
            guard let item = self.queue.peek() else {
                return
            }
            guard let topViewController = UIWindow.key?.topViewController() else {
                return
            }

            if self.suspendInterruptDefaultAlert && topViewController is UIAlertController {
                return
            }

            self.isPresenting = true

            item.show()
        }
    }
    
    public func suspend() {
        isSuspended = true
    }
    
    public func resume() {
        isSuspended = false
        handleNextQueue()
    }

}

/// Enqueue
extension UIPresentCoordinator {
    public func enqueue(_ task: SwiftUIPresentTask) {
        // FIXME: 同一TASKが入るとだめ
        queue.enqueue(.swiftUI(task))
        handleNextQueue()
    }

    public func enqueue(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        queue.enqueue(.uiKit(.init(controller: viewController, animated: animated, completion: completion)))
        handleNextQueue()
    }
}

/// Dequeue
extension UIPresentCoordinator {
    public func dequeue() -> AnyView {
        guard case .swiftUI(let alert) = queue.peek() else {
            fatalError()
        }
        guard case .view(let task) = alert else {
            fatalError()
        }
        guard let ui = task.content else {
            fatalError()
        }
        return ui
    }

    public func dequeue() -> Alert {
        guard case .swiftUI(let alert) = queue.peek() else {
            fatalError()
        }
        guard case .alert(let task) = alert else {
            fatalError()
        }
        guard let ui = task.content else {
            fatalError()
        }
        return ui
    }
}
